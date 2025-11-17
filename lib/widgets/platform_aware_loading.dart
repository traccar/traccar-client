import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A platform-adaptive loading indicator widget
///
/// Uses [CupertinoActivityIndicator] on iOS and [CircularProgressIndicator] on Android
class PlatformAwareLoadingIndicator extends StatelessWidget {
  /// The radius of the loading indicator
  final double? radius;

  /// The stroke width (Android only)
  final double? strokeWidth;

  /// The color of the loading indicator
  final Color? color;

  const PlatformAwareLoadingIndicator({
    super.key,
    this.radius,
    this.strokeWidth,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoActivityIndicator(
        radius: radius ?? 10.0,
        color: color,
      );
    } else {
      return SizedBox(
        width: radius != null ? radius! * 2 : 20.0,
        height: radius != null ? radius! * 2 : 20.0,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth ?? 4.0,
          valueColor: color != null
              ? AlwaysStoppedAnimation<Color>(color!)
              : null,
        ),
      );
    }
  }
}

/// A full-screen platform-adaptive loading overlay
class PlatformAwareLoadingOverlay extends StatelessWidget {
  /// Optional message to display below the loading indicator
  final String? message;

  /// Background color of the overlay
  final Color? backgroundColor;

  const PlatformAwareLoadingOverlay({
    super.key,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ??
          (Platform.isIOS
              ? CupertinoColors.systemBackground.withOpacity(0.9)
              : Colors.black.withOpacity(0.5)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PlatformAwareLoadingIndicator(
              radius: 20,
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: Platform.isIOS
                    ? CupertinoTheme.of(context).textTheme.textStyle
                    : Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A platform-adaptive linear progress indicator
class PlatformAwareLinearProgress extends StatelessWidget {
  /// The current progress value (0.0 to 1.0), null for indeterminate
  final double? value;

  /// The color of the progress indicator
  final Color? color;

  /// The background color of the progress track
  final Color? backgroundColor;

  const PlatformAwareLinearProgress({
    super.key,
    this.value,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Both platforms use similar linear progress, but we can customize
    // the styling to match platform conventions
    if (Platform.isIOS) {
      // iOS typically uses a thinner progress bar
      return ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: backgroundColor ?? CupertinoColors.systemGrey5,
          valueColor: color != null
              ? AlwaysStoppedAnimation<Color>(color!)
              : null,
          minHeight: 3.0,
        ),
      );
    } else {
      // Android Material Design 3 style
      return LinearProgressIndicator(
        value: value,
        backgroundColor: backgroundColor,
        valueColor: color != null
            ? AlwaysStoppedAnimation<Color>(color!)
            : null,
      );
    }
  }
}
