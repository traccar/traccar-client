import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// The style variant for platform-aware buttons
enum PlatformButtonStyle {
  /// Primary/filled button (most emphasis)
  filled,

  /// Outlined button (medium emphasis)
  outlined,

  /// Text button (least emphasis)
  text,

  /// Destructive action button (for delete, remove, etc.)
  destructive,
}

/// A platform-adaptive button widget
///
/// Uses [CupertinoButton] on iOS and Material buttons on Android
class PlatformAwareButton extends StatelessWidget {
  /// The text to display on the button
  final String text;

  /// The callback when the button is pressed
  final VoidCallback? onPressed;

  /// The style of the button
  final PlatformButtonStyle style;

  /// An optional icon to display before the text
  final IconData? icon;

  /// Whether the button should expand to fill available width
  final bool isExpanded;

  /// Custom padding for the button
  final EdgeInsetsGeometry? padding;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom text color
  final Color? textColor;

  const PlatformAwareButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = PlatformButtonStyle.filled,
    this.icon,
    this.isExpanded = false,
    this.padding,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget button;

    if (Platform.isIOS) {
      button = _buildCupertinoButton(context);
    } else {
      button = _buildMaterialButton(context);
    }

    if (isExpanded) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  Widget _buildCupertinoButton(BuildContext context) {
    final bool isDestructive = style == PlatformButtonStyle.destructive;
    final bool isFilled = style == PlatformButtonStyle.filled || isDestructive;

    Color? effectiveBackgroundColor = backgroundColor;
    Color? effectiveTextColor = textColor;

    if (isFilled && effectiveBackgroundColor == null) {
      effectiveBackgroundColor = isDestructive
          ? CupertinoColors.systemRed
          : CupertinoColors.activeBlue;
    }

    if (effectiveTextColor == null) {
      if (isFilled) {
        effectiveTextColor = CupertinoColors.white;
      } else if (isDestructive) {
        effectiveTextColor = CupertinoColors.systemRed;
      } else {
        effectiveTextColor = CupertinoColors.activeBlue;
      }
    }

    Widget child = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(text),
            ],
          )
        : Text(text);

    if (isFilled) {
      return CupertinoButton.filled(
        onPressed: onPressed,
        padding: padding,
        child: child,
      );
    } else {
      return CupertinoButton(
        onPressed: onPressed,
        padding: padding,
        color: effectiveBackgroundColor,
        child: DefaultTextStyle(
          style: TextStyle(color: effectiveTextColor),
          child: child,
        ),
      );
    }
  }

  Widget _buildMaterialButton(BuildContext context) {
    final Widget child = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(text),
            ],
          )
        : Text(text);

    switch (style) {
      case PlatformButtonStyle.filled:
        return FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            padding: padding,
          ),
          child: child,
        );

      case PlatformButtonStyle.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            padding: padding,
          ),
          child: child,
        );

      case PlatformButtonStyle.text:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            padding: padding,
          ),
          child: child,
        );

      case PlatformButtonStyle.destructive:
        return FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor:
                backgroundColor ?? Theme.of(context).colorScheme.error,
            foregroundColor: textColor ?? Colors.white,
            padding: padding,
          ),
          child: child,
        );
    }
  }
}

/// A platform-adaptive icon button
class PlatformAwareIconButton extends StatelessWidget {
  /// The icon to display
  final IconData icon;

  /// The callback when the button is pressed
  final VoidCallback? onPressed;

  /// The size of the icon
  final double? iconSize;

  /// The color of the icon
  final Color? color;

  /// The tooltip message
  final String? tooltip;

  const PlatformAwareIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconSize,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Platform.isIOS
        ? CupertinoButton(
            onPressed: onPressed,
            padding: EdgeInsets.zero,
            minSize: iconSize ?? 24.0,
            child: Icon(
              icon,
              size: iconSize,
              color: color ?? CupertinoColors.activeBlue,
            ),
          )
        : IconButton(
            onPressed: onPressed,
            icon: Icon(icon),
            iconSize: iconSize,
            color: color,
            tooltip: tooltip,
          );

    if (tooltip != null && Platform.isIOS) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
