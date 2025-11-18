import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a Place (geofenced location) for arrival/departure notifications
///
/// Places allow circle members to receive alerts when someone enters or leaves
/// important locations like "Home", "School", "Work", etc.
class Place {
  /// Unique place ID
  final String id;

  /// Place name (e.g., "Home", "School", "Work")
  final String name;

  /// Optional description
  final String? description;

  /// Circle ID this place belongs to
  final String circleId;

  /// User ID who created this place
  final String createdBy;

  /// Latitude of the place center
  final double latitude;

  /// Longitude of the place center
  final double longitude;

  /// Radius in meters for geofence detection
  final double radius;

  /// Icon name for visual identification
  final String? icon;

  /// Color for the place marker (hex string like "#FF5733")
  final String? color;

  /// Whether to send notifications when members enter this place
  final bool notifyOnEnter;

  /// Whether to send notifications when members exit this place
  final bool notifyOnExit;

  /// Whether this place is currently active
  final bool isActive;

  /// When the place was created
  final DateTime createdAt;

  /// Last time place settings were updated
  final DateTime updatedAt;

  const Place({
    required this.id,
    required this.name,
    this.description,
    required this.circleId,
    required this.createdBy,
    required this.latitude,
    required this.longitude,
    this.radius = 100.0, // Default 100 meters
    this.icon,
    this.color,
    this.notifyOnEnter = true,
    this.notifyOnExit = true,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a Place from a Firestore document snapshot
  factory Place.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Place(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String?,
      circleId: data['circleId'] as String,
      createdBy: data['createdBy'] as String,
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      radius: (data['radius'] as num?)?.toDouble() ?? 100.0,
      icon: data['icon'] as String?,
      color: data['color'] as String?,
      notifyOnEnter: data['notifyOnEnter'] as bool? ?? true,
      notifyOnExit: data['notifyOnExit'] as bool? ?? true,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Create a Place from a map
  factory Place.fromMap(Map<String, dynamic> data, String id) {
    return Place(
      id: id,
      name: data['name'] as String,
      description: data['description'] as String?,
      circleId: data['circleId'] as String,
      createdBy: data['createdBy'] as String,
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      radius: (data['radius'] as num?)?.toDouble() ?? 100.0,
      icon: data['icon'] as String?,
      color: data['color'] as String?,
      notifyOnEnter: data['notifyOnEnter'] as bool? ?? true,
      notifyOnExit: data['notifyOnExit'] as bool? ?? true,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : data['createdAt'] as DateTime,
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : data['updatedAt'] as DateTime,
    );
  }

  /// Convert Place to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'circleId': circleId,
      'createdBy': createdBy,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'icon': icon,
      'color': color,
      'notifyOnEnter': notifyOnEnter,
      'notifyOnExit': notifyOnExit,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a copy of this place with updated fields
  Place copyWith({
    String? id,
    String? name,
    String? description,
    String? circleId,
    String? createdBy,
    double? latitude,
    double? longitude,
    double? radius,
    String? icon,
    String? color,
    bool? notifyOnEnter,
    bool? notifyOnExit,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      circleId: circleId ?? this.circleId,
      createdBy: createdBy ?? this.createdBy,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      notifyOnEnter: notifyOnEnter ?? this.notifyOnEnter,
      notifyOnExit: notifyOnExit ?? this.notifyOnExit,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if a coordinate is inside this place's geofence
  ///
  /// Uses the Haversine formula to calculate distance between two coordinates.
  bool containsLocation(double lat, double lng) {
    const double earthRadius = 6371000; // meters

    final dLat = _toRadians(lat - latitude);
    final dLng = _toRadians(lng - longitude);

    final a = (dLat / 2).sin * (dLat / 2).sin +
        latitude.toRadian().cos *
            lat.toRadian().cos *
            (dLng / 2).sin *
            (dLng / 2).sin;

    final c = 2 * (a.sqrt()).atan2((1 - a).sqrt());
    final distance = earthRadius * c;

    return distance <= radius;
  }

  double _toRadians(double degrees) {
    return degrees * (3.14159265359 / 180.0);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Place && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Place(id: $id, name: $name, circle: $circleId, radius: ${radius}m)';
}

/// Extension on double for radian conversion
extension _DoubleExtension on double {
  double toRadian() => this * (3.14159265359 / 180.0);
}
