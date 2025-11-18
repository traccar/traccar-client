import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:luminalink/services/auth_service.dart';
import 'package:luminalink/models/models.dart';
import 'package:luminalink/screens/auth/login_screen.dart';
import 'package:luminalink/screens/onboarding/onboarding_screen.dart';
import 'package:luminalink/main_screen.dart';
import 'package:luminalink/widgets/widgets.dart';

/// Authentication wrapper that routes users based on their auth state
///
/// This widget listens to Firebase Auth state changes and shows:
/// - Login screen if not authenticated
/// - Onboarding flow if authenticated but hasn't completed onboarding
/// - Main screen if authenticated and onboarded
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, authSnapshot) {
        // Show loading indicator while checking auth state
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: PlatformAwareLoadingIndicator(),
            ),
          );
        }

        // User is not logged in - show login screen
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const LoginScreen();
        }

        // User is logged in - check if onboarding is completed
        return StreamBuilder<AppUser?>(
          stream: authService.getCurrentUserStream(),
          builder: (context, userSnapshot) {
            // Show loading while fetching user data
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: PlatformAwareLoadingIndicator(),
                ),
              );
            }

            // If user document doesn't exist or hasn't completed onboarding
            if (!userSnapshot.hasData ||
                userSnapshot.data == null ||
                !userSnapshot.data!.onboardingCompleted) {
              return const OnboardingScreen();
            }

            // User is fully authenticated and onboarded - show main screen
            return const MainScreen();
          },
        );
      },
    );
  }
}
