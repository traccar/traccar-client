import 'dart:async';
import 'dart:developer' as developer;
import 'package:luminalink/models/models.dart';
import 'package:luminalink/services/auth_service.dart';
import 'package:luminalink/services/place_service.dart';
import 'package:luminalink/services/notification_service.dart';
import 'package:luminalink/services/location_service.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

/// Service for monitoring geofences and triggering place notifications
///
/// Tracks user's current location and checks against defined places,
/// sending notifications when entering or exiting geofenced areas.
class GeofenceService {
  final AuthService _authService = AuthService();
  final PlaceService _placeService = PlaceService();
  final NotificationService _notificationService = NotificationService();
  final LocationService _locationService = LocationService();

  // Track which places the user is currently inside
  final Set<String> _currentPlaceIds = {};

  // Debounce timers to prevent notification spam
  final Map<String, Timer> _notificationTimers = {};

  bool _isMonitoring = false;
  StreamSubscription? _locationSubscription;

  // ==========================================================================
  // MONITORING
  // ==========================================================================

  /// Start monitoring geofences
  ///
  /// Listens to location updates and checks for place entries/exits.
  Future<void> startMonitoring() async {
    if (_isMonitoring) return;

    final userId = _authService.currentUserId;
    if (userId == null) {
      developer.log('Cannot start geofence monitoring: not authenticated');
      return;
    }

    try {
      // Check if location sharing is enabled
      final isLocationEnabled = await _locationService.isLocationSharingEnabled();
      if (!isLocationEnabled) {
        developer.log('Location sharing disabled, skipping geofence monitoring');
        return;
      }

      // Listen to location updates from background geolocation
      _locationSubscription = bg.BackgroundGeolocation.onLocation(_handleLocationUpdate);

      // Initialize current places (where user currently is)
      await _initializeCurrentPlaces();

      _isMonitoring = true;
      developer.log('Geofence monitoring started');
    } catch (e) {
      developer.log('Failed to start geofence monitoring', error: e);
    }
  }

  /// Stop monitoring geofences
  Future<void> stopMonitoring() async {
    if (!_isMonitoring) return;

    await _locationSubscription?.cancel();
    _locationSubscription = null;

    // Cancel all pending notification timers
    for (final timer in _notificationTimers.values) {
      timer.cancel();
    }
    _notificationTimers.clear();

    _currentPlaceIds.clear();
    _isMonitoring = false;

    developer.log('Geofence monitoring stopped');
  }

  /// Initialize the set of places user is currently inside
  Future<void> _initializeCurrentPlaces() async {
    try {
      // Get current location
      final myLocation = await _locationService.getMyLocation();
      if (myLocation == null) return;

      // Check which places contain current location
      final places = await _placeService.getPlacesContainingLocation(
        myLocation.latitude,
        myLocation.longitude,
      );

      // Add to current places without sending notifications
      _currentPlaceIds.clear();
      _currentPlaceIds.addAll(places.map((p) => p.id));

      developer.log('Initialized with ${_currentPlaceIds.length} current places');
    } catch (e) {
      developer.log('Failed to initialize current places', error: e);
    }
  }

  // ==========================================================================
  // LOCATION HANDLING
  // ==========================================================================

  /// Handle location update from background geolocation
  void _handleLocationUpdate(bg.Location location) {
    _checkGeofences(location.coords.latitude, location.coords.longitude);
  }

  /// Check if user has entered or exited any geofences
  Future<void> _checkGeofences(double latitude, double longitude) async {
    try {
      // Get all places that contain the current location
      final containingPlaces = await _placeService.getPlacesContainingLocation(
        latitude,
        longitude,
      );

      final newPlaceIds = containingPlaces.map((p) => p.id).toSet();

      // Find places that were entered (in new set but not in current set)
      final enteredPlaceIds = newPlaceIds.difference(_currentPlaceIds);

      // Find places that were exited (in current set but not in new set)
      final exitedPlaceIds = _currentPlaceIds.difference(newPlaceIds);

      // Handle entered places
      for (final placeId in enteredPlaceIds) {
        final place = containingPlaces.firstWhere((p) => p.id == placeId);
        await _handlePlaceEntry(place);
      }

      // Handle exited places
      for (final placeId in exitedPlaceIds) {
        // Get place details from PlaceService
        final place = await _placeService.getPlace(placeId);
        if (place != null) {
          await _handlePlaceExit(place);
        }
      }

      // Update current places
      _currentPlaceIds
        ..clear()
        ..addAll(newPlaceIds);
    } catch (e) {
      developer.log('Failed to check geofences', error: e);
    }
  }

  /// Handle entering a place
  Future<void> _handlePlaceEntry(Place place) async {
    // Check if notifications are enabled for entry
    if (!place.notifyOnEnter) return;

    // Debounce to prevent spam
    if (_notificationTimers.containsKey('enter_${place.id}')) {
      return;
    }

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      developer.log('User entered place: ${place.name}');

      // Send notification to circle members
      await _notificationService.sendPlaceEntryNotification(
        placeId: place.id,
        placeName: place.name,
        userId: user.uid,
        userName: user.displayName,
        circleId: place.circleId,
      );

      // Show local notification to user
      await _notificationService.showLocalNotification(
        title: 'Arrived at ${place.name}',
        body: 'Your circle members have been notified',
        payload: 'place_entry:${place.id}',
      );

      // Set debounce timer (5 minutes)
      _notificationTimers['enter_${place.id}'] = Timer(
        const Duration(minutes: 5),
        () => _notificationTimers.remove('enter_${place.id}'),
      );
    } catch (e) {
      developer.log('Failed to handle place entry', error: e);
    }
  }

  /// Handle exiting a place
  Future<void> _handlePlaceExit(Place place) async {
    // Check if notifications are enabled for exit
    if (!place.notifyOnExit) return;

    // Debounce to prevent spam
    if (_notificationTimers.containsKey('exit_${place.id}')) {
      return;
    }

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      developer.log('User exited place: ${place.name}');

      // Send notification to circle members
      await _notificationService.sendPlaceExitNotification(
        placeId: place.id,
        placeName: place.name,
        userId: user.uid,
        userName: user.displayName,
        circleId: place.circleId,
      );

      // Show local notification to user
      await _notificationService.showLocalNotification(
        title: 'Left ${place.name}',
        body: 'Your circle members have been notified',
        payload: 'place_exit:${place.id}',
      );

      // Set debounce timer (5 minutes)
      _notificationTimers['exit_${place.id}'] = Timer(
        const Duration(minutes: 5),
        () => _notificationTimers.remove('exit_${place.id}'),
      );
    } catch (e) {
      developer.log('Failed to handle place exit', error: e);
    }
  }

  // ==========================================================================
  // MANUAL CHECKS
  // ==========================================================================

  /// Manually check current location against all geofences
  ///
  /// Useful for testing or force-refreshing geofence state.
  Future<List<Place>> checkCurrentLocation() async {
    try {
      final myLocation = await _locationService.getMyLocation();
      if (myLocation == null) return [];

      final places = await _placeService.getPlacesContainingLocation(
        myLocation.latitude,
        myLocation.longitude,
      );

      developer.log('Currently inside ${places.length} places');
      return places;
    } catch (e) {
      developer.log('Failed to check current location', error: e);
      return [];
    }
  }

  /// Get the list of places user is currently inside
  Set<String> getCurrentPlaceIds() {
    return Set.from(_currentPlaceIds);
  }

  /// Check if user is currently inside a specific place
  bool isInsidePlace(String placeId) {
    return _currentPlaceIds.contains(placeId);
  }

  // ==========================================================================
  // STATUS
  // ==========================================================================

  /// Check if geofence monitoring is active
  bool get isMonitoring => _isMonitoring;
}
