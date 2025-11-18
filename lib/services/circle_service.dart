import 'dart:developer' as developer;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luminalink/models/models.dart';
import 'package:luminalink/services/auth_service.dart';
import 'package:luminalink/utils/exceptions.dart';

/// Service for managing Circles (groups of users who share location)
///
/// Handles circle creation, member management, invitations, and real-time updates.
class CircleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  /// Get the circles collection reference
  CollectionReference get _circlesCollection =>
      _firestore.collection('circles');

  /// Get the users collection reference
  CollectionReference get _usersCollection => _firestore.collection('users');

  // ==========================================================================
  // CIRCLE CRUD OPERATIONS
  // ==========================================================================

  /// Create a new circle
  ///
  /// The current user becomes the owner and first member of the circle.
  /// Optionally generates an invite code if [enableInviteCode] is true.
  Future<Circle> createCircle({
    required String name,
    String? description,
    String? iconColor,
    bool enableInviteCode = true,
    int maxMembers = -1,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw const AuthenticationException(
        'No user logged in. Please sign in first.',
        code: 'auth/not-authenticated',
      );
    }

    try {
      final now = DateTime.now();
      final String? inviteCode =
          enableInviteCode ? _generateInviteCode() : null;

      final circle = Circle(
        id: '', // Will be set after creation
        name: name,
        description: description,
        ownerId: userId,
        adminIds: [userId],
        memberIds: [userId],
        createdAt: now,
        updatedAt: now,
        iconColor: iconColor,
        inviteCode: inviteCode,
        inviteCodeEnabled: enableInviteCode,
        maxMembers: maxMembers,
      );

      // Create circle document
      final docRef = await _circlesCollection.add(circle.toMap());

      // Update user's circleIds
      await _usersCollection.doc(userId).update({
        'circleIds': FieldValue.arrayUnion([docRef.id]),
        'updatedAt': Timestamp.now(),
      });

      developer.log('Circle created: ${docRef.id}');
      return circle.copyWith(id: docRef.id);
    } catch (e) {
      developer.log('Failed to create circle', error: e);
      rethrow;
    }
  }

  /// Get a circle by ID
  Future<Circle?> getCircle(String circleId) async {
    try {
      final doc = await _circlesCollection.doc(circleId).get();
      if (!doc.exists) return null;
      return Circle.fromFirestore(doc);
    } catch (e) {
      developer.log('Failed to get circle', error: e);
      return null;
    }
  }

  /// Get a stream of a circle's data
  Stream<Circle?> getCircleStream(String circleId) {
    return _circlesCollection.doc(circleId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Circle.fromFirestore(doc);
    });
  }

  /// Get all circles for the current user
  Future<List<Circle>> getMyCircles() async {
    final userId = _authService.currentUserId;
    if (userId == null) return [];

    try {
      final querySnapshot = await _circlesCollection
          .where('memberIds', arrayContains: userId)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Circle.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Failed to get circles', error: e);
      return [];
    }
  }

  /// Get a stream of all circles for the current user
  Stream<List<Circle>> getMyCirclesStream() {
    final userId = _authService.currentUserId;
    if (userId == null) return Stream.value([]);

    return _circlesCollection
        .where('memberIds', arrayContains: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Circle.fromFirestore(doc)).toList();
    });
  }

  /// Update circle details
  Future<void> updateCircle({
    required String circleId,
    String? name,
    String? description,
    String? iconColor,
    bool? inviteCodeEnabled,
    int? maxMembers,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw const AuthenticationException(
        'No user logged in. Please sign in first.',
        code: 'auth/not-authenticated',
      );
    }

    try {
      // Check if user is admin
      final circle = await getCircle(circleId);
      if (circle == null) throw CircleException.notFound();
      if (!circle.isAdmin(userId)) {
        throw PermissionException.unauthorized();
      }

      final updates = <String, dynamic>{
        'updatedAt': Timestamp.now(),
      };
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (iconColor != null) updates['iconColor'] = iconColor;
      if (inviteCodeEnabled != null) {
        updates['inviteCodeEnabled'] = inviteCodeEnabled;
      }
      if (maxMembers != null) updates['maxMembers'] = maxMembers;

      await _circlesCollection.doc(circleId).update(updates);
      developer.log('Circle updated: $circleId');
    } catch (e) {
      developer.log('Failed to update circle', error: e);
      rethrow;
    }
  }

  /// Delete (archive) a circle
  ///
  /// Only the owner can delete a circle. This sets isActive to false
  /// rather than deleting the document.
  Future<void> deleteCircle(String circleId) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw const AuthenticationException(
        'No user logged in. Please sign in first.',
        code: 'auth/not-authenticated',
      );
    }

    try {
      final circle = await getCircle(circleId);
      if (circle == null) throw CircleException.notFound();
      if (!circle.isOwner(userId)) {
        throw CircleException.onlyOwnerCanDelete();
      }

      // Archive the circle
      await _circlesCollection.doc(circleId).update({
        'isActive': false,
        'updatedAt': Timestamp.now(),
      });

      // Remove from all members' circleIds
      for (final memberId in circle.memberIds) {
        await _usersCollection.doc(memberId).update({
          'circleIds': FieldValue.arrayRemove([circleId]),
          'updatedAt': Timestamp.now(),
        });
      }

      developer.log('Circle deleted: $circleId');
    } catch (e) {
      developer.log('Failed to delete circle', error: e);
      rethrow;
    }
  }

  // ==========================================================================
  // MEMBER MANAGEMENT
  // ==========================================================================

  /// Add a member to a circle by user ID
  Future<void> addMember(String circleId, String userId) async {
    final currentUserId = _authService.currentUserId;
    if (currentUserId == null) {
      throw const AuthenticationException(
        'No user logged in. Please sign in first.',
        code: 'auth/not-authenticated',
      );
    }

    try {
      final circle = await getCircle(circleId);
      if (circle == null) throw CircleException.notFound();

      // Check if user is admin
      if (!circle.isAdmin(currentUserId)) {
        throw PermissionException.unauthorized();
      }

      // Check if already a member
      if (circle.isMember(userId)) {
        throw CircleException.alreadyMember();
      }

      // Check member limit
      if (circle.isFull) {
        throw CircleException.circleFull();
      }

      // Add to circle
      await _circlesCollection.doc(circleId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
        'updatedAt': Timestamp.now(),
      });

      // Add to user's circleIds
      await _usersCollection.doc(userId).update({
        'circleIds': FieldValue.arrayUnion([circleId]),
        'updatedAt': Timestamp.now(),
      });

      developer.log('Member added to circle: $userId -> $circleId');
    } catch (e) {
      developer.log('Failed to add member', error: e);
      rethrow;
    }
  }

  /// Remove a member from a circle
  Future<void> removeMember(String circleId, String userId) async {
    final currentUserId = _authService.currentUserId;
    if (currentUserId == null) {
      throw const AuthenticationException(
        'No user logged in. Please sign in first.',
        code: 'auth/not-authenticated',
      );
    }

    try {
      final circle = await getCircle(circleId);
      if (circle == null) throw CircleException.notFound();

      // Users can remove themselves, or admins can remove others
      if (userId != currentUserId && !circle.isAdmin(currentUserId)) {
        throw PermissionException.unauthorized();
      }

      // Can't remove the owner
      if (circle.isOwner(userId)) {
        throw const CircleException(
          'Cannot remove the circle owner. The owner must transfer ownership or delete the circle.',
          code: 'circle/cannot-remove-owner',
        );
      }

      // Remove from circle
      await _circlesCollection.doc(circleId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
        'adminIds': FieldValue.arrayRemove([userId]),
        'updatedAt': Timestamp.now(),
      });

      // Remove from user's circleIds
      await _usersCollection.doc(userId).update({
        'circleIds': FieldValue.arrayRemove([circleId]),
        'updatedAt': Timestamp.now(),
      });

      developer.log('Member removed from circle: $userId <- $circleId');
    } catch (e) {
      developer.log('Failed to remove member', error: e);
      rethrow;
    }
  }

  /// Promote a member to admin
  Future<void> promoteToAdmin(String circleId, String userId) async {
    final currentUserId = _authService.currentUserId;
    if (currentUserId == null) {
      throw const AuthenticationException(
        'No user logged in. Please sign in first.',
        code: 'auth/not-authenticated',
      );
    }

    try {
      final circle = await getCircle(circleId);
      if (circle == null) throw CircleException.notFound();

      // Only owner or existing admins can promote
      if (!circle.isAdmin(currentUserId)) {
        throw PermissionException.unauthorized();
      }

      if (!circle.isMember(userId)) {
        throw const CircleException(
          'User is not a member of this circle.',
          code: 'circle/not-member',
        );
      }

      if (circle.isAdmin(userId)) {
        throw const CircleException(
          'User is already an admin.',
          code: 'circle/already-admin',
        );
      }

      await _circlesCollection.doc(circleId).update({
        'adminIds': FieldValue.arrayUnion([userId]),
        'updatedAt': Timestamp.now(),
      });

      developer.log('Member promoted to admin: $userId in $circleId');
    } catch (e) {
      developer.log('Failed to promote member', error: e);
      rethrow;
    }
  }

  /// Demote an admin to regular member
  Future<void> demoteAdmin(String circleId, String userId) async {
    final currentUserId = _authService.currentUserId;
    if (currentUserId == null) {
      throw const AuthenticationException(
        'No user logged in. Please sign in first.',
        code: 'auth/not-authenticated',
      );
    }

    try {
      final circle = await getCircle(circleId);
      if (circle == null) throw CircleException.notFound();

      // Only owner can demote admins
      if (!circle.isOwner(currentUserId)) {
        throw const PermissionException(
          'Only the circle owner can demote admins.',
          code: 'permission/owner-only',
        );
      }

      // Can't demote the owner
      if (circle.isOwner(userId)) {
        throw const CircleException(
          'Cannot demote the circle owner.',
          code: 'circle/cannot-demote-owner',
        );
      }

      if (!circle.isAdmin(userId)) {
        throw const CircleException(
          'User is not an admin.',
          code: 'circle/not-admin',
        );
      }

      await _circlesCollection.doc(circleId).update({
        'adminIds': FieldValue.arrayRemove([userId]),
        'updatedAt': Timestamp.now(),
      });

      developer.log('Admin demoted: $userId in $circleId');
    } catch (e) {
      developer.log('Failed to demote admin', error: e);
      rethrow;
    }
  }

  // ==========================================================================
  // INVITE CODE MANAGEMENT
  // ==========================================================================

  /// Generate a new invite code for a circle
  Future<String> regenerateInviteCode(String circleId) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw const AuthenticationException(
        'No user logged in. Please sign in first.',
        code: 'auth/not-authenticated',
      );
    }

    try {
      final circle = await getCircle(circleId);
      if (circle == null) throw CircleException.notFound();

      if (!circle.isAdmin(userId)) {
        throw PermissionException.unauthorized();
      }

      final newCode = _generateInviteCode();
      await _circlesCollection.doc(circleId).update({
        'inviteCode': newCode,
        'inviteCodeEnabled': true,
        'updatedAt': Timestamp.now(),
      });

      developer.log('Invite code regenerated for circle: $circleId');
      return newCode;
    } catch (e) {
      developer.log('Failed to regenerate invite code', error: e);
      rethrow;
    }
  }

  /// Join a circle using an invite code
  Future<Circle> joinCircleWithCode(String inviteCode) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw const AuthenticationException(
        'No user logged in. Please sign in first.',
        code: 'auth/not-authenticated',
      );
    }

    try {
      // Find circle with this invite code
      final querySnapshot = await _circlesCollection
          .where('inviteCode', isEqualTo: inviteCode.toUpperCase())
          .where('inviteCodeEnabled', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw CircleException.invalidInviteCode();
      }

      final circle = Circle.fromFirestore(querySnapshot.docs.first);

      // Check if already a member
      if (circle.isMember(userId)) {
        throw CircleException.alreadyMember();
      }

      // Check member limit
      if (circle.isFull) {
        throw CircleException.circleFull();
      }

      // Add member
      await addMember(circle.id, userId);

      developer.log('User joined circle via invite code: $userId -> ${circle.id}');
      return circle;
    } catch (e) {
      developer.log('Failed to join circle with code', error: e);
      rethrow;
    }
  }

  // ==========================================================================
  // UTILITY METHODS
  // ==========================================================================

  /// Generate a random 6-character alphanumeric invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // No confusing chars
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Get all members of a circle as AppUser objects
  Future<List<AppUser>> getCircleMembers(String circleId) async {
    try {
      final circle = await getCircle(circleId);
      if (circle == null) return [];

      final members = <AppUser>[];
      for (final memberId in circle.memberIds) {
        final userDoc = await _usersCollection.doc(memberId).get();
        if (userDoc.exists) {
          members.add(AppUser.fromFirestore(userDoc));
        }
      }

      return members;
    } catch (e) {
      developer.log('Failed to get circle members', error: e);
      return [];
    }
  }

  /// Get a stream of circle members
  Stream<List<AppUser>> getCircleMembersStream(String circleId) {
    return getCircleStream(circleId).asyncMap((circle) async {
      if (circle == null) return <AppUser>[];
      return getCircleMembers(circleId);
    });
  }
}
