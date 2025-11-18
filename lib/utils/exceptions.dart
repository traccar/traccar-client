/// Custom exceptions for LuminaLink
///
/// Provides structured error handling with user-friendly messages
/// and error codes for logging and monitoring.

/// Base exception class for all LuminaLink exceptions
class LuminaLinkException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const LuminaLinkException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    if (code != null) {
      return 'LuminaLinkException [$code]: $message';
    }
    return 'LuminaLinkException: $message';
  }

  /// Get a user-friendly error message suitable for display
  String get userMessage => message;
}

/// Authentication-related exceptions
class AuthenticationException extends LuminaLinkException {
  const AuthenticationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory AuthenticationException.invalidCredentials() {
    return const AuthenticationException(
      'Invalid email or password. Please try again.',
      code: 'auth/invalid-credentials',
    );
  }

  factory AuthenticationException.userNotFound() {
    return const AuthenticationException(
      'No account found with this email address.',
      code: 'auth/user-not-found',
    );
  }

  factory AuthenticationException.emailAlreadyInUse() {
    return const AuthenticationException(
      'An account already exists with this email address.',
      code: 'auth/email-already-in-use',
    );
  }

  factory AuthenticationException.weakPassword() {
    return const AuthenticationException(
      'Password is too weak. Please use a stronger password.',
      code: 'auth/weak-password',
    );
  }

  factory AuthenticationException.invalidEmail() {
    return const AuthenticationException(
      'Invalid email address format.',
      code: 'auth/invalid-email',
    );
  }

  factory AuthenticationException.userDisabled() {
    return const AuthenticationException(
      'This account has been disabled. Please contact support.',
      code: 'auth/user-disabled',
    );
  }

  factory AuthenticationException.tooManyRequests() {
    return const AuthenticationException(
      'Too many failed attempts. Please try again later.',
      code: 'auth/too-many-requests',
    );
  }
}

/// Network-related exceptions
class NetworkException extends LuminaLinkException {
  const NetworkException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory NetworkException.noConnection() {
    return const NetworkException(
      'No internet connection. Please check your network and try again.',
      code: 'network/no-connection',
    );
  }

  factory NetworkException.timeout() {
    return const NetworkException(
      'Request timed out. Please try again.',
      code: 'network/timeout',
    );
  }

  factory NetworkException.serverError() {
    return const NetworkException(
      'Server error. Please try again later.',
      code: 'network/server-error',
    );
  }
}

/// Permission-related exceptions
class PermissionException extends LuminaLinkException {
  const PermissionException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory PermissionException.locationDenied() {
    return const PermissionException(
      'Location permission denied. Please enable location access in settings.',
      code: 'permission/location-denied',
    );
  }

  factory PermissionException.locationDeniedPermanently() {
    return const PermissionException(
      'Location permission permanently denied. Please enable it in device settings.',
      code: 'permission/location-denied-permanently',
    );
  }

  factory PermissionException.notificationDenied() {
    return const PermissionException(
      'Notification permission denied. You won\'t receive place alerts.',
      code: 'permission/notification-denied',
    );
  }

  factory PermissionException.unauthorized() {
    return const PermissionException(
      'You don\'t have permission to perform this action.',
      code: 'permission/unauthorized',
    );
  }
}

/// Circle-related exceptions
class CircleException extends LuminaLinkException {
  const CircleException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory CircleException.notFound() {
    return const CircleException(
      'Circle not found.',
      code: 'circle/not-found',
    );
  }

  factory CircleException.invalidInviteCode() {
    return const CircleException(
      'Invalid invite code. Please check and try again.',
      code: 'circle/invalid-invite-code',
    );
  }

  factory CircleException.circleFull() {
    return const CircleException(
      'This circle has reached its maximum number of members.',
      code: 'circle/full',
    );
  }

  factory CircleException.alreadyMember() {
    return const CircleException(
      'You are already a member of this circle.',
      code: 'circle/already-member',
    );
  }

  factory CircleException.onlyOwnerCanDelete() {
    return const CircleException(
      'Only the circle owner can delete this circle.',
      code: 'circle/only-owner-can-delete',
    );
  }

  factory CircleException.cannotLeaveAsOwner() {
    return const CircleException(
      'You cannot leave a circle you own. Transfer ownership or delete the circle.',
      code: 'circle/cannot-leave-as-owner',
    );
  }
}

/// Place-related exceptions
class PlaceException extends LuminaLinkException {
  const PlaceException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory PlaceException.notFound() {
    return const PlaceException(
      'Place not found.',
      code: 'place/not-found',
    );
  }

  factory PlaceException.invalidRadius() {
    return const PlaceException(
      'Place radius must be between 50m and 1000m.',
      code: 'place/invalid-radius',
    );
  }

  factory PlaceException.invalidLocation() {
    return const PlaceException(
      'Invalid location coordinates.',
      code: 'place/invalid-location',
    );
  }

  factory PlaceException.unauthorized() {
    return const PlaceException(
      'You don\'t have permission to modify this place.',
      code: 'place/unauthorized',
    );
  }
}

/// Location-related exceptions
class LocationException extends LuminaLinkException {
  const LocationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory LocationException.serviceDisabled() {
    return const LocationException(
      'Location services are disabled. Please enable them in device settings.',
      code: 'location/service-disabled',
    );
  }

  factory LocationException.notAvailable() {
    return const LocationException(
      'Location not available. Please try again.',
      code: 'location/not-available',
    );
  }

  factory LocationException.timeout() {
    return const LocationException(
      'Location request timed out. Please try again.',
      code: 'location/timeout',
    );
  }
}

/// Validation exceptions
class ValidationException extends LuminaLinkException {
  const ValidationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory ValidationException.required(String fieldName) {
    return ValidationException(
      '$fieldName is required.',
      code: 'validation/required',
    );
  }

  factory ValidationException.invalid(String fieldName) {
    return ValidationException(
      'Invalid $fieldName.',
      code: 'validation/invalid',
    );
  }

  factory ValidationException.tooShort(String fieldName, int minLength) {
    return ValidationException(
      '$fieldName must be at least $minLength characters.',
      code: 'validation/too-short',
    );
  }

  factory ValidationException.tooLong(String fieldName, int maxLength) {
    return ValidationException(
      '$fieldName must be no more than $maxLength characters.',
      code: 'validation/too-long',
    );
  }
}

/// Utility function to convert Firebase errors to LuminaLink exceptions
LuminaLinkException fromFirebaseError(dynamic error) {
  final errorMessage = error.toString().toLowerCase();

  // Auth errors
  if (errorMessage.contains('invalid-credential') ||
      errorMessage.contains('wrong-password')) {
    return AuthenticationException.invalidCredentials();
  }
  if (errorMessage.contains('user-not-found')) {
    return AuthenticationException.userNotFound();
  }
  if (errorMessage.contains('email-already-in-use')) {
    return AuthenticationException.emailAlreadyInUse();
  }
  if (errorMessage.contains('weak-password')) {
    return AuthenticationException.weakPassword();
  }
  if (errorMessage.contains('invalid-email')) {
    return AuthenticationException.invalidEmail();
  }
  if (errorMessage.contains('user-disabled')) {
    return AuthenticationException.userDisabled();
  }
  if (errorMessage.contains('too-many-requests')) {
    return AuthenticationException.tooManyRequests();
  }

  // Network errors
  if (errorMessage.contains('network') || errorMessage.contains('connection')) {
    return NetworkException.noConnection();
  }
  if (errorMessage.contains('timeout')) {
    return NetworkException.timeout();
  }

  // Permission errors
  if (errorMessage.contains('permission') || errorMessage.contains('denied')) {
    return PermissionException.unauthorized();
  }

  // Default to generic exception
  return LuminaLinkException(
    'An unexpected error occurred. Please try again.',
    code: 'unknown',
    originalError: error,
  );
}
