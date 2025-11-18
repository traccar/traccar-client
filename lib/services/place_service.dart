import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luminalink/models/models.dart';
import 'package:luminalink/services/auth_service.dart';
import 'package:luminalink/services/circle_service.dart';

/// Service for managing Places (geofenced locations) in Firestore
///
/// Provides CRUD operations for places and geofence notifications.
class PlaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final CircleService _circleService = CircleService();

  /// Reference to the places collection
  CollectionReference<Map<String, dynamic>> get _placesCollection =>
      _firestore.collection('places');

  // ==========================================================================
  // CRUD OPERATIONS
  // ==========================================================================

  /// Create a new place
  ///
  /// Creates a geofenced location for a circle. Only circle members can create places.
  Future<Place> createPlace({
    required String name,
    String? description,
    required String circleId,
    required double latitude,
    required double longitude,
    double radius = 100.0,
    String? icon,
    String? color,
    bool notifyOnEnter = true,
    bool notifyOnExit = true,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Verify user is a member of the circle
      final circle = await _circleService.getCircle(circleId);
      if (circle == null || !circle.isMember(userId)) {
        throw Exception('You must be a member of the circle to create places');
      }

      final now = DateTime.now();
      final place = Place(
        id: '', // Will be set by Firestore
        name: name,
        description: description,
        circleId: circleId,
        createdBy: userId,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        icon: icon,
        color: color,
        notifyOnEnter: notifyOnEnter,
        notifyOnExit: notifyOnExit,
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await _placesCollection.add(place.toMap());
      developer.log('Created place: ${docRef.id}');

      return place.copyWith(id: docRef.id);
    } catch (e) {
      developer.log('Failed to create place', error: e);
      rethrow;
    }
  }

  /// Get a place by ID
  Future<Place?> getPlace(String placeId) async {
    try {
      final doc = await _placesCollection.doc(placeId).get();
      if (!doc.exists) {
        return null;
      }
      return Place.fromFirestore(doc);
    } catch (e) {
      developer.log('Failed to get place', error: e);
      return null;
    }
  }

  /// Get all places for a circle
  Future<List<Place>> getCirclePlaces(String circleId) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return [];
    }

    try {
      // Verify user is a member of the circle
      final circle = await _circleService.getCircle(circleId);
      if (circle == null || !circle.isMember(userId)) {
        return [];
      }

      final querySnapshot = await _placesCollection
          .where('circleId', isEqualTo: circleId)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
    } catch (e) {
      developer.log('Failed to get circle places', error: e);
      return [];
    }
  }

  /// Get a stream of places for a circle
  Stream<List<Place>> getCirclePlacesStream(String circleId) async* {
    final userId = _authService.currentUserId;
    if (userId == null) {
      yield [];
      return;
    }

    try {
      // Verify user is a member of the circle (one-time check)
      final circle = await _circleService.getCircle(circleId);
      if (circle == null || !circle.isMember(userId)) {
        yield [];
        return;
      }

      await for (final snapshot in _placesCollection
          .where('circleId', isEqualTo: circleId)
          .where('isActive', isEqualTo: true)
          .snapshots()) {
        yield snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
      }
    } catch (e) {
      developer.log('Error in places stream', error: e);
      yield [];
    }
  }

  /// Get all places for all user's circles
  Future<List<Place>> getAllMyPlaces() async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return [];
    }

    try {
      final circles = await _circleService.getMyCircles();
      final allPlaces = <Place>[];

      for (final circle in circles) {
        final places = await getCirclePlaces(circle.id);
        allPlaces.addAll(places);
      }

      return allPlaces;
    } catch (e) {
      developer.log('Failed to get all places', error: e);
      return [];
    }
  }

  /// Get a stream of all places for all user's circles
  Stream<List<Place>> getAllMyPlacesStream() async* {
    try {
      final circles = await _circleService.getMyCircles();

      if (circles.isEmpty) {
        yield [];
        return;
      }

      // For simplicity, we'll poll for updates
      // In a production app, you'd want to use a more sophisticated approach
      await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
        final allPlaces = <Place>[];
        for (final circle in circles) {
          final places = await getCirclePlaces(circle.id);
          allPlaces.addAll(places);
        }
        yield allPlaces;
      }
    } catch (e) {
      developer.log('Error in all places stream', error: e);
      yield [];
    }
  }

  /// Update a place
  ///
  /// Only the place creator or circle admins can update places.
  Future<void> updatePlace(
    String placeId, {
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    double? radius,
    String? icon,
    String? color,
    bool? notifyOnEnter,
    bool? notifyOnExit,
    bool? isActive,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final place = await getPlace(placeId);
      if (place == null) {
        throw Exception('Place not found');
      }

      // Verify user has permission to update
      final circle = await _circleService.getCircle(place.circleId);
      if (circle == null ||
          (place.createdBy != userId && !circle.isAdmin(userId))) {
        throw Exception(
            'Only the creator or circle admins can update this place');
      }

      final Map<String, dynamic> updates = {
        'updatedAt': Timestamp.now(),
      };

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (latitude != null) updates['latitude'] = latitude;
      if (longitude != null) updates['longitude'] = longitude;
      if (radius != null) updates['radius'] = radius;
      if (icon != null) updates['icon'] = icon;
      if (color != null) updates['color'] = color;
      if (notifyOnEnter != null) updates['notifyOnEnter'] = notifyOnEnter;
      if (notifyOnExit != null) updates['notifyOnExit'] = notifyOnExit;
      if (isActive != null) updates['isActive'] = isActive;

      await _placesCollection.doc(placeId).update(updates);
      developer.log('Updated place: $placeId');
    } catch (e) {
      developer.log('Failed to update place', error: e);
      rethrow;
    }
  }

  /// Delete a place
  ///
  /// Only the place creator or circle admins can delete places.
  Future<void> deletePlace(String placeId) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final place = await getPlace(placeId);
      if (place == null) {
        throw Exception('Place not found');
      }

      // Verify user has permission to delete
      final circle = await _circleService.getCircle(place.circleId);
      if (circle == null ||
          (place.createdBy != userId && !circle.isAdmin(userId))) {
        throw Exception(
            'Only the creator or circle admins can delete this place');
      }

      await _placesCollection.doc(placeId).delete();
      developer.log('Deleted place: $placeId');
    } catch (e) {
      developer.log('Failed to delete place', error: e);
      rethrow;
    }
  }

  // ==========================================================================
  // GEOFENCE CHECKING
  // ==========================================================================

  /// Check if a location is inside any of the user's circle places
  ///
  /// Returns a list of places that contain the given location.
  Future<List<Place>> getPlacesContainingLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      final allPlaces = await getAllMyPlaces();
      return allPlaces
          .where((place) => place.containsLocation(latitude, longitude))
          .toList();
    } catch (e) {
      developer.log('Failed to check geofences', error: e);
      return [];
    }
  }

  /// Check if a location is inside any places for a specific circle
  ///
  /// Returns a list of places in the circle that contain the given location.
  Future<List<Place>> getCirclePlacesContainingLocation(
    String circleId,
    double latitude,
    double longitude,
  ) async {
    try {
      final places = await getCirclePlaces(circleId);
      return places
          .where((place) => place.containsLocation(latitude, longitude))
          .toList();
    } catch (e) {
      developer.log('Failed to check circle geofences', error: e);
      return [];
    }
  }
}
