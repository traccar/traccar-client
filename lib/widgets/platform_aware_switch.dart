import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A platform-adaptive switch widget
///
/// Uses [CupertinoSwitch] on iOS and [Switch] (Material) on Android
class PlatformAwareSwitch extends StatelessWidget {
  /// The current value of the switch
  final bool value;

  /// Called when the user toggles the switch
  final ValueChanged<bool> onChanged;

  /// The active color (when switch is on)
  final Color? activeColor;

  /// The track color (background)
  final Color? trackColor;

  /// The thumb color
  final Color? thumbColor;

  const PlatformAwareSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.trackColor,
    this.thumbColor,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor ?? CupertinoColors.systemBlue,
        trackColor: trackColor,
        thumbColor: thumbColor ?? CupertinoColors.white,
      );
    } else {
      return Switch(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
        activeTrackColor: trackColor,
        inactiveThumbColor: thumbColor,
      );
    }
  }
}

/// A list tile with a platform-adaptive switch
class PlatformAwareSwitchListTile extends StatelessWidget {
  /// The primary content of the list tile (typically a title)
  final Widget title;

  /// Additional content displayed below the title
  final Widget? subtitle;

  /// A widget to display before the title (typically an icon)
  final Widget? leading;

  /// The current value of the switch
  final bool value;

  /// Called when the user toggles the switch
  final ValueChanged<bool> onChanged;

  /// The active color (when switch is on)
  final Color? activeColor;

  const PlatformAwareSwitchListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      // iOS-style list tile with switch
      return CupertinoListTile(
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: activeColor ?? CupertinoColors.systemBlue,
        ),
        onTap: () => onChanged(!value),
      );
    } else {
      // Material Design list tile with switch
      return SwitchListTile(
        title: title,
        subtitle: subtitle,
        secondary: leading,
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
      );
    }
  }
}
