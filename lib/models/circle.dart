import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Represents a Circle (group) of users who share location with each other
///
/// Circles are the core concept in LuminaLink - a private group where members
/// can see each other's locations and receive place alerts.
class Circle {
  /// Unique circle ID
  final String id;

  /// Circle name (e.g., "Family", "Close Friends", "Work Team")
  final String name;

  /// Optional description
  final String? description;

  /// User ID of the circle creator/owner
  final String ownerId;

  /// List of admin user IDs (can invite/remove members, edit settings)
  final List<String> adminIds;

  /// List of all member user IDs
  final List<String> memberIds;

  /// When the circle was created
  final DateTime createdAt;

  /// Last time circle settings were updated
  final DateTime updatedAt;

  /// Optional circle icon/color for visual identification
  final String? iconColor;

  /// Whether the circle is active (archived circles don't show locations)
  final bool isActive;

  /// Invite code for joining the circle (6-character alphanumeric)
  final String? inviteCode;

  /// Whether the invite code is currently enabled
  final bool inviteCodeEnabled;

  /// Maximum number of members allowed (-1 for unlimited)
  final int maxMembers;

  const Circle({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    this.adminIds = const [],
    this.memberIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.iconColor,
    this.isActive = true,
    this.inviteCode,
    this.inviteCodeEnabled = false,
    this.maxMembers = -1,
  });

  /// Create a Circle from a Firestore document snapshot
  factory Circle.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Circle(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String?,
      ownerId: data['ownerId'] as String,
      adminIds: List<String>.from(data['adminIds'] as List? ?? []),
      memberIds: List<String>.from(data['memberIds'] as List? ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      iconColor: data['iconColor'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      inviteCode: data['inviteCode'] as String?,
      inviteCodeEnabled: data['inviteCodeEnabled'] as bool? ?? false,
      maxMembers: data['maxMembers'] as int? ?? -1,
    );
  }

  /// Create a Circle from a map
  factory Circle.fromMap(Map<String, dynamic> data, String id) {
    return Circle(
      id: id,
      name: data['name'] as String,
      description: data['description'] as String?,
      ownerId: data['ownerId'] as String,
      adminIds: List<String>.from(data['adminIds'] as List? ?? []),
      memberIds: List<String>.from(data['memberIds'] as List? ?? []),
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : data['createdAt'] as DateTime,
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : data['updatedAt'] as DateTime,
      iconColor: data['iconColor'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      inviteCode: data['inviteCode'] as String?,
      inviteCodeEnabled: data['inviteCodeEnabled'] as bool? ?? false,
      maxMembers: data['maxMembers'] as int? ?? -1,
    );
  }

  /// Convert Circle to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'adminIds': adminIds,
      'memberIds': memberIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'iconColor': iconColor,
      'isActive': isActive,
      'inviteCode': inviteCode,
      'inviteCodeEnabled': inviteCodeEnabled,
      'maxMembers': maxMembers,
    };
  }

  /// Create a copy of this circle with updated fields
  Circle copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    List<String>? adminIds,
    List<String>? memberIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? iconColor,
    bool? isActive,
    String? inviteCode,
    bool? inviteCodeEnabled,
    int? maxMembers,
  }) {
    return Circle(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      adminIds: adminIds ?? this.adminIds,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      iconColor: iconColor ?? this.iconColor,
      isActive: isActive ?? this.isActive,
      inviteCode: inviteCode ?? this.inviteCode,
      inviteCodeEnabled: inviteCodeEnabled ?? this.inviteCodeEnabled,
      maxMembers: maxMembers ?? this.maxMembers,
    );
  }

  /// Check if a user is the owner of this circle
  bool isOwner(String userId) => ownerId == userId;

  /// Check if a user is an admin of this circle
  bool isAdmin(String userId) => adminIds.contains(userId) || isOwner(userId);

  /// Check if a user is a member of this circle
  bool isMember(String userId) => memberIds.contains(userId);

  /// Get the number of members in this circle
  int get memberCount => memberIds.length;

  /// Check if the circle has reached its member limit
  bool get isFull => maxMembers > 0 && memberCount >= maxMembers;

  /// Parse the icon color string to a Color object
  ///
  /// Returns the parsed color if iconColor is a valid hex string,
  /// otherwise returns a default amber color.
  Color get iconColorParsed {
    if (iconColor == null || iconColor!.isEmpty) {
      return const Color(0xFFF59E0B); // Default amber
    }

    try {
      // Remove '#' if present
      final colorString = iconColor!.replaceAll('#', '');

      // Parse hex color (supports both RGB and ARGB formats)
      if (colorString.length == 6) {
        return Color(int.parse('FF$colorString', radix: 16));
      } else if (colorString.length == 8) {
        return Color(int.parse(colorString, radix: 16));
      }
    } catch (e) {
      // Return default color if parsing fails
      return const Color(0xFFF59E0B);
    }

    return const Color(0xFFF59E0B);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Circle && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Circle(id: $id, name: $name, members: $memberCount)';
}
