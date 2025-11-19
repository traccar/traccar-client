import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a LuminaLink user with profile information and privacy settings
///
/// This model is used throughout the app for user authentication, profile display,
/// and determining what information is shared with circle members.
class AppUser {
  /// Unique user ID (matches Firebase Auth UID)
  final String uid;

  /// User's email address
  final String email;

  /// Display name (e.g., "John Doe")
  final String displayName;

  /// Optional phone number
  final String? phoneNumber;

  /// URL to profile photo (from Firebase Storage or external)
  final String? photoUrl;

  /// When the user account was created
  final DateTime createdAt;

  /// Last time the user updated their profile
  final DateTime updatedAt;

  /// Whether location sharing is globally enabled for this user
  final bool locationSharingEnabled;

  /// List of circle IDs this user belongs to
  final List<String> circleIds;

  /// FCM token for push notifications
  final String? fcmToken;

  /// Whether the user has completed the onboarding flow
  final bool onboardingCompleted;

  /// User's preferred battery optimization setting (high/balanced/low)
  final String batteryMode;

  /// Last known online status
  final DateTime? lastSeen;

  /// Whether the user is currently online
  final bool isOnline;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phoneNumber,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.locationSharingEnabled = false,
    this.circleIds = const [],
    this.fcmToken,
    this.onboardingCompleted = false,
    this.batteryMode = 'balanced',
    this.lastSeen,
    this.isOnline = false,
  });

  /// Create an AppUser from a Firestore document snapshot
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] as String,
      displayName: data['displayName'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String?,
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      locationSharingEnabled: data['locationSharingEnabled'] as bool? ?? false,
      circleIds: List<String>.from(data['circleIds'] as List? ?? []),
      fcmToken: data['fcmToken'] as String?,
      onboardingCompleted: data['onboardingCompleted'] as bool? ?? false,
      batteryMode: data['batteryMode'] as String? ?? 'balanced',
      lastSeen: data['lastSeen'] != null
          ? (data['lastSeen'] as Timestamp).toDate()
          : null,
      isOnline: data['isOnline'] as bool? ?? false,
    );
  }

  /// Create an AppUser from a map (for testing or manual creation)
  factory AppUser.fromMap(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      email: data['email'] as String,
      displayName: data['displayName'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String?,
      photoUrl: data['photoUrl'] as String?,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : data['createdAt'] as DateTime,
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : data['updatedAt'] as DateTime,
      locationSharingEnabled: data['locationSharingEnabled'] as bool? ?? false,
      circleIds: List<String>.from(data['circleIds'] as List? ?? []),
      fcmToken: data['fcmToken'] as String?,
      onboardingCompleted: data['onboardingCompleted'] as bool? ?? false,
      batteryMode: data['batteryMode'] as String? ?? 'balanced',
      lastSeen: data['lastSeen'] != null
          ? (data['lastSeen'] is Timestamp
              ? (data['lastSeen'] as Timestamp).toDate()
              : data['lastSeen'] as DateTime)
          : null,
      isOnline: data['isOnline'] as bool? ?? false,
    );
  }

  /// Convert AppUser to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'locationSharingEnabled': locationSharingEnabled,
      'circleIds': circleIds,
      'fcmToken': fcmToken,
      'onboardingCompleted': onboardingCompleted,
      'batteryMode': batteryMode,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'isOnline': isOnline,
    };
  }

  /// Create a copy of this user with updated fields
  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? locationSharingEnabled,
    List<String>? circleIds,
    String? fcmToken,
    bool? onboardingCompleted,
    String? batteryMode,
    DateTime? lastSeen,
    bool? isOnline,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      locationSharingEnabled:
          locationSharingEnabled ?? this.locationSharingEnabled,
      circleIds: circleIds ?? this.circleIds,
      fcmToken: fcmToken ?? this.fcmToken,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      batteryMode: batteryMode ?? this.batteryMode,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  /// Get user's initials for avatar display (e.g., "JD" for "John Doe")
  String get initials {
    if (displayName.isEmpty) return email[0].toUpperCase();
    final parts = displayName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.substring(0, 1).toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() => 'AppUser(uid: $uid, email: $email, displayName: $displayName)';
}
