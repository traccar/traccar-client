import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:luminalink/models/models.dart';
import 'package:luminalink/services/auth_service.dart';
import 'package:luminalink/services/circle_service.dart';

/// Location service for LuminaLink
///
/// Manages location sharing with Firestore, integrating with the existing
/// background geolocation tracking. Handles privacy controls and circle-based
/// sharing.
class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final CircleService _circleService = CircleService();

  /// Get the locations collection reference
  CollectionReference get _locationsCollection =>
      _firestore.collection('locations');

  // ==========================================================================
  // LOCATION UPDATES
  // ==========================================================================

  /// Initialize location sharing with Firestore
  ///
  /// Sets up a listener for background geolocation updates and pushes them
  /// to Firestore for sharing with circles.
  Future<void> initializeLocationSharing() async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      developer.log('Cannot initialize location sharing: user not logged in');
      return;
    }

    // Listen to location updates from background geolocation
    bg.BackgroundGeolocation.onLocation(_handleLocationUpdate);

    developer.log('Location sharing initialized for user: $userId');
  }

  /// Handle location update from background geolocation
  Future<void> _handleLocationUpdate(bg.Location location) async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    try {
      // Check if location sharing is enabled
      final user = await _authService.getCurrentUser();
      if (user == null || !user.locationSharingEnabled) {
        developer.log('Location sharing disabled for user');
        return;
      }

      // Get user's circles to share with
      final circles = await _circleService.getMyCircles();
      final circleIds = circles.map((c) => c.id).toList();

      if (circleIds.isEmpty) {
        developer.log('No circles to share location with');
        return;
      }

      // Create location document
      final userLocation = UserLocation(
        userId: userId,
        latitude: location.coords.latitude,
        longitude: location.coords.longitude,
        accuracy: location.coords.accuracy,
        speed: location.coords.speed >= 0 ? location.coords.speed : null,
        heading: location.coords.heading >= 0 ? location.coords.heading : null,
        altitude: location.coords.altitude,
        timestamp: DateTime.parse(location.timestamp),
        isMoving: location.isMoving,
        batteryLevel: location.battery.level,
        isCharging: location.battery.isCharging,
        activityType: location.activity.type,
        sharedWith: circleIds,
      );

      // Update Firestore
      await _locationsCollection.doc(userId).set(
            userLocation.toMap(),
            SetOptions(merge: true),
          );

      developer.log('Location updated in Firestore for user: $userId');
    } catch (e) {
      developer.log('Failed to update location in Firestore', error: e);
    }
  }

  /// Manually update current location
  ///
  /// Forces a location update to Firestore immediately.
  Future<void> updateCurrentLocation() async {
    try {
      final location = await bg.BackgroundGeolocation.getCurrentPosition(
        samples: 1,
        persist: false,
      );
      await _handleLocationUpdate(location);
    } catch (e) {
      developer.log('Failed to get current location', error: e);
      rethrow;
    }
  }

  // ==========================================================================
  // LOCATION RETRIEVAL
  // ==========================================================================

  /// Get the current user's latest location
  Future<UserLocation?> getMyLocation() async {
    final userId = _authService.currentUserId;
    if (userId == null) return null;

    try {
      final doc = await _locationsCollection.doc(userId).get();
      if (!doc.exists) return null;
      return UserLocation.fromFirestore(doc);
    } catch (e) {
      developer.log('Failed to get user location', error: e);
      return null;
    }
  }

  /// Get a stream of the current user's location
  Stream<UserLocation?> getMyLocationStream() {
    final userId = _authService.currentUserId;
    if (userId == null) return Stream.value(null);

    return _locationsCollection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserLocation.fromFirestore(doc);
    });
  }

  /// Get locations for all members in a circle
  Future<Map<String, UserLocation>> getCircleMemberLocations(
    String circleId,
  ) async {
    final userId = _authService.currentUserId;
    if (userId == null) return {};

    try {
      // Verify user is member of circle
      final circle = await _circleService.getCircle(circleId);
      if (circle == null || !circle.isMember(userId)) {
        throw Exception('Not a member of this circle');
      }

      // Get locations for all members
      final locations = <String, UserLocation>{};

      // Query locations where sharedWith contains this circleId
      final querySnapshot = await _locationsCollection
          .where('sharedWith', arrayContains: circleId)
          .get();

      for (final doc in querySnapshot.docs) {
        locations[doc.id] = UserLocation.fromFirestore(doc);
      }

      return locations;
    } catch (e) {
      developer.log('Failed to get circle member locations', error: e);
      return {};
    }
  }

  /// Get a stream of locations for all members in a circle
  Stream<Map<String, UserLocation>> getCircleMemberLocationsStream(
    String circleId,
  ) async* {
    final userId = _authService.currentUserId;
    if (userId == null) {
      yield {};
      return;
    }

    try {
      // Verify user is member of circle (one-time check)
      final circle = await _circleService.getCircle(circleId);
      if (circle == null || !circle.isMember(userId)) {
        yield {};
        return;
      }

      // Stream locations where sharedWith contains this circleId
      await for (final snapshot in _locationsCollection
          .where('sharedWith', arrayContains: circleId)
          .snapshots()) {
        final locations = <String, UserLocation>{};
        for (final doc in snapshot.docs) {
          locations[doc.id] = UserLocation.fromFirestore(doc);
        }
        yield locations;
      }
    } catch (e) {
      developer.log('Error in location stream', error: e);
      yield {};
    }
  }

  /// Get locations for all members in all user's circles
  Future<Map<String, UserLocation>> getAllCircleMemberLocations() async {
    try {
      final circles = await _circleService.getMyCircles();
      final allLocations = <String, UserLocation>{};

      for (final circle in circles) {
        final locations = await getCircleMemberLocations(circle.id);
        allLocations.addAll(locations);
      }

      return allLocations;
    } catch (e) {
      developer.log('Failed to get all circle member locations', error: e);
      return {};
    }
  }

  /// Get a stream of locations for all members in all user's circles
  Stream<Map<String, UserLocation>> getAllCircleMemberLocationsStream() async* {
    final circles = await _circleService.getMyCircles();

    if (circles.isEmpty) {
      yield {};
      return;
    }

    // Combine streams from all circles
    final streamControllers = circles.map((circle) {
      return getCircleMemberLocationsStream(circle.id);
    }).toList();

    // Merge all streams
    await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
      final allLocations = <String, UserLocation>{};
      for (final streamController in streamControllers) {
        await for (final locations in streamController.take(1)) {
          allLocations.addAll(locations);
        }
      }
      yield allLocations;
    }
  }

  // ==========================================================================
  // PRIVACY CONTROLS
  // ==========================================================================

  /// Enable location sharing
  Future<void> enableLocationSharing() async {
    try {
      await _authService.updateLocationSharing(true);
      // Force an immediate location update
      await updateCurrentLocation();
      developer.log('Location sharing enabled');
    } catch (e) {
      developer.log('Failed to enable location sharing', error: e);
      rethrow;
    }
  }

  /// Disable location sharing
  ///
  /// Stops sharing location with circles and removes current location from Firestore.
  Future<void> disableLocationSharing() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    try {
      await _authService.updateLocationSharing(false);

      // Remove location from Firestore
      await _locationsCollection.doc(userId).delete();

      developer.log('Location sharing disabled');
    } catch (e) {
      developer.log('Failed to disable location sharing', error: e);
      rethrow;
    }
  }

  /// Check if location sharing is currently enabled
  Future<bool> isLocationSharingEnabled() async {
    try {
      final user = await _authService.getCurrentUser();
      return user?.locationSharingEnabled ?? false;
    } catch (e) {
      developer.log('Failed to check location sharing status', error: e);
      return false;
    }
  }

  // ==========================================================================
  // CLEANUP
  // ==========================================================================

  /// Clean up old location data
  ///
  /// Removes locations older than 24 hours (optional cleanup task).
  Future<void> cleanupOldLocations() async {
    try {
      final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));

      final snapshot = await _locationsCollection
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoffTime))
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      developer.log('Cleaned up ${snapshot.docs.length} old locations');
    } catch (e) {
      developer.log('Failed to cleanup old locations', error: e);
    }
  }
}
