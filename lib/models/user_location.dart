import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user's real-time location data
///
/// This model stores location updates that are shared with circle members.
/// Location data is temporary and typically stored for 24 hours before being purged.
class UserLocation {
  /// User ID this location belongs to
  final String userId;

  /// Latitude coordinate
  final double latitude;

  /// Longitude coordinate
  final double longitude;

  /// Location accuracy in meters
  final double accuracy;

  /// Speed in meters per second (nullable)
  final double? speed;

  /// Heading/bearing in degrees (0-360, nullable)
  final double? heading;

  /// Altitude in meters (nullable)
  final double? altitude;

  /// Timestamp when this location was recorded
  final DateTime timestamp;

  /// Whether the user is currently moving
  final bool isMoving;

  /// Battery level (0.0 to 1.0)
  final double batteryLevel;

  /// Whether the device is charging
  final bool isCharging;

  /// Activity type (walking, driving, stationary, etc.)
  final String? activityType;

  /// List of circle IDs this location is shared with
  final List<String> sharedWith;

  /// Address string (reverse geocoded, optional)
  final String? address;

  const UserLocation({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.speed,
    this.heading,
    this.altitude,
    required this.timestamp,
    this.isMoving = false,
    this.batteryLevel = 1.0,
    this.isCharging = false,
    this.activityType,
    this.sharedWith = const [],
    this.address,
  });

  /// Create a UserLocation from a Firestore document snapshot
  factory UserLocation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserLocation(
      userId: data['userId'] as String,
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      accuracy: (data['accuracy'] as num).toDouble(),
      speed: data['speed'] != null ? (data['speed'] as num).toDouble() : null,
      heading:
          data['heading'] != null ? (data['heading'] as num).toDouble() : null,
      altitude: data['altitude'] != null
          ? (data['altitude'] as num).toDouble()
          : null,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isMoving: data['isMoving'] as bool? ?? false,
      batteryLevel: (data['batteryLevel'] as num?)?.toDouble() ?? 1.0,
      isCharging: data['isCharging'] as bool? ?? false,
      activityType: data['activityType'] as String?,
      sharedWith: List<String>.from(data['sharedWith'] as List? ?? []),
      address: data['address'] as String?,
    );
  }

  /// Create a UserLocation from a map
  factory UserLocation.fromMap(Map<String, dynamic> data) {
    return UserLocation(
      userId: data['userId'] as String,
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      accuracy: (data['accuracy'] as num).toDouble(),
      speed: data['speed'] != null ? (data['speed'] as num).toDouble() : null,
      heading:
          data['heading'] != null ? (data['heading'] as num).toDouble() : null,
      altitude: data['altitude'] != null
          ? (data['altitude'] as num).toDouble()
          : null,
      timestamp: data['timestamp'] is Timestamp
          ? (data['timestamp'] as Timestamp).toDate()
          : data['timestamp'] as DateTime,
      isMoving: data['isMoving'] as bool? ?? false,
      batteryLevel: (data['batteryLevel'] as num?)?.toDouble() ?? 1.0,
      isCharging: data['isCharging'] as bool? ?? false,
      activityType: data['activityType'] as String?,
      sharedWith: List<String>.from(data['sharedWith'] as List? ?? []),
      address: data['address'] as String?,
    );
  }

  /// Convert UserLocation to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
      'altitude': altitude,
      'timestamp': Timestamp.fromDate(timestamp),
      'isMoving': isMoving,
      'batteryLevel': batteryLevel,
      'isCharging': isCharging,
      'activityType': activityType,
      'sharedWith': sharedWith,
      'address': address,
    };
  }

  /// Create a copy of this location with updated fields
  UserLocation copyWith({
    String? userId,
    double? latitude,
    double? longitude,
    double? accuracy,
    double? speed,
    double? heading,
    double? altitude,
    DateTime? timestamp,
    bool? isMoving,
    double? batteryLevel,
    bool? isCharging,
    String? activityType,
    List<String>? sharedWith,
    String? address,
  }) {
    return UserLocation(
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      altitude: altitude ?? this.altitude,
      timestamp: timestamp ?? this.timestamp,
      isMoving: isMoving ?? this.isMoving,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isCharging: isCharging ?? this.isCharging,
      activityType: activityType ?? this.activityType,
      sharedWith: sharedWith ?? this.sharedWith,
      address: address ?? this.address,
    );
  }

  /// Calculate how many seconds ago this location was recorded
  int get ageInSeconds {
    return DateTime.now().difference(timestamp).inSeconds;
  }

  /// Check if this location is considered "fresh" (less than 5 minutes old)
  bool get isFresh {
    return ageInSeconds < 300; // 5 minutes
  }

  /// Check if this location is considered "stale" (more than 30 minutes old)
  bool get isStale {
    return ageInSeconds > 1800; // 30 minutes
  }

  /// Get a human-readable "time ago" string
  String get timeAgo {
    final seconds = ageInSeconds;
    if (seconds < 60) return 'Just now';
    if (seconds < 3600) return '${seconds ~/ 60}m ago';
    if (seconds < 86400) return '${seconds ~/ 3600}h ago';
    return '${seconds ~/ 86400}d ago';
  }

  @override
  String toString() =>
      'UserLocation(userId: $userId, lat: $latitude, lng: $longitude, timestamp: $timestamp)';
}
