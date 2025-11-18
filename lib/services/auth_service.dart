import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luminalink/models/models.dart';

/// Authentication service for LuminaLink
///
/// Handles all Firebase Authentication operations including sign up, sign in,
/// password reset, and user profile management.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get the current Firebase user
  User? get currentFirebaseUser => _auth.currentUser;

  /// Stream of auth state changes (logged in/out)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get the current user's ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if a user is currently logged in
  bool get isAuthenticated => _auth.currentUser != null;

  // ==========================================================================
  // SIGN UP & SIGN IN
  // ==========================================================================

  /// Sign up with email and password
  ///
  /// Creates a new Firebase Auth user and a corresponding user document in Firestore.
  ///
  /// Throws [FirebaseAuthException] if sign up fails.
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create Firebase Auth user
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Failed to create user account');
      }

      // Update display name
      await firebaseUser.updateDisplayName(displayName);

      // Create user document in Firestore
      final now = DateTime.now();
      final appUser = AppUser(
        uid: firebaseUser.uid,
        email: email,
        displayName: displayName,
        createdAt: now,
        updatedAt: now,
        locationSharingEnabled: false,
        onboardingCompleted: false,
      );

      await _firestore.collection('users').doc(firebaseUser.uid).set(
            appUser.toMap(),
          );

      developer.log('User signed up successfully: ${firebaseUser.uid}');
      return appUser;
    } on FirebaseAuthException catch (e) {
      developer.log('Sign up failed', error: e);
      throw _handleAuthException(e);
    }
  }

  /// Sign in with email and password
  ///
  /// Throws [FirebaseAuthException] if sign in fails.
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Failed to sign in');
      }

      // Get user document from Firestore
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        // Create user document if it doesn't exist (edge case)
        final now = DateTime.now();
        final appUser = AppUser(
          uid: firebaseUser.uid,
          email: email,
          displayName: firebaseUser.displayName ?? email.split('@')[0],
          createdAt: now,
          updatedAt: now,
        );
        await _firestore.collection('users').doc(firebaseUser.uid).set(
              appUser.toMap(),
            );
        return appUser;
      }

      // Update last seen
      await _updateLastSeen(firebaseUser.uid);

      developer.log('User signed in successfully: ${firebaseUser.uid}');
      return AppUser.fromFirestore(userDoc);
    } on FirebaseAuthException catch (e) {
      developer.log('Sign in failed', error: e);
      throw _handleAuthException(e);
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      if (_auth.currentUser != null) {
        await _updateOnlineStatus(_auth.currentUser!.uid, false);
      }
      await _auth.signOut();
      developer.log('User signed out successfully');
    } catch (e) {
      developer.log('Sign out failed', error: e);
      rethrow;
    }
  }

  // ==========================================================================
  // PASSWORD MANAGEMENT
  // ==========================================================================

  /// Send a password reset email
  ///
  /// Throws [FirebaseAuthException] if the operation fails.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      developer.log('Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      developer.log('Password reset failed', error: e);
      throw _handleAuthException(e);
    }
  }

  /// Change the current user's password
  ///
  /// Requires recent authentication. May throw [FirebaseAuthException]
  /// if re-authentication is required.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Re-authenticate with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Change password
      await user.updatePassword(newPassword);
      developer.log('Password changed successfully');
    } on FirebaseAuthException catch (e) {
      developer.log('Password change failed', error: e);
      throw _handleAuthException(e);
    }
  }

  // ==========================================================================
  // USER PROFILE MANAGEMENT
  // ==========================================================================

  /// Get the current user's AppUser document
  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;
      return AppUser.fromFirestore(userDoc);
    } catch (e) {
      developer.log('Failed to get current user', error: e);
      return null;
    }
  }

  /// Stream of the current user's AppUser document
  Stream<AppUser?> getCurrentUserStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.exists ? AppUser.fromFirestore(doc) : null);
  }

  /// Update the current user's profile
  Future<void> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      // Update Firebase Auth profile
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Update Firestore document
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.now(),
      };
      if (displayName != null) updates['displayName'] = displayName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      await _firestore.collection('users').doc(user.uid).update(updates);
      developer.log('User profile updated successfully');
    } catch (e) {
      developer.log('Profile update failed', error: e);
      rethrow;
    }
  }

  /// Update the user's FCM token for push notifications
  Future<void> updateFcmToken(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      developer.log('Failed to update FCM token', error: e);
    }
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'onboardingCompleted': true,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      developer.log('Failed to complete onboarding', error: e);
      rethrow;
    }
  }

  /// Update location sharing status
  Future<void> updateLocationSharing(bool enabled) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'locationSharingEnabled': enabled,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      developer.log('Failed to update location sharing', error: e);
      rethrow;
    }
  }

  // ==========================================================================
  // PRESENCE & ACTIVITY
  // ==========================================================================

  /// Update the user's online status
  Future<void> _updateOnlineStatus(String userId, bool isOnline) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isOnline': isOnline,
        'lastSeen': Timestamp.now(),
      });
    } catch (e) {
      developer.log('Failed to update online status', error: e);
    }
  }

  /// Update the user's last seen timestamp
  Future<void> _updateLastSeen(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastSeen': Timestamp.now(),
        'isOnline': true,
      });
    } catch (e) {
      developer.log('Failed to update last seen', error: e);
    }
  }

  // ==========================================================================
  // ERROR HANDLING
  // ==========================================================================

  /// Convert FirebaseAuthException to user-friendly messages
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('Password is too weak. Please use a stronger password.');
      case 'email-already-in-use':
        return Exception('An account already exists with this email address.');
      case 'invalid-email':
        return Exception('The email address is not valid.');
      case 'user-disabled':
        return Exception('This account has been disabled.');
      case 'user-not-found':
        return Exception('No account found with this email address.');
      case 'wrong-password':
        return Exception('Incorrect password. Please try again.');
      case 'too-many-requests':
        return Exception('Too many failed attempts. Please try again later.');
      case 'requires-recent-login':
        return Exception('This operation requires recent authentication. Please sign in again.');
      case 'network-request-failed':
        return Exception('Network error. Please check your internet connection.');
      default:
        return Exception('Authentication failed: ${e.message}');
    }
  }
}
