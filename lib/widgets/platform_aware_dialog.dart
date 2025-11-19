import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A platform-adaptive dialog that uses Material Design on Android
/// and Cupertino design on iOS to feel native on both platforms.
class PlatformAwareDialog {
  /// Shows a platform-adaptive alert dialog
  ///
  /// On iOS: Uses [CupertinoAlertDialog]
  /// On Android: Uses [AlertDialog] (Material Design 3)
  ///
  /// Example:
  /// ```dart
  /// await PlatformAwareDialog.show(
  ///   context: context,
  ///   title: 'Delete Item',
  ///   content: 'Are you sure you want to delete this item?',
  ///   actions: [
  ///     PlatformDialogAction(
  ///       text: 'Cancel',
  ///       onPressed: () => Navigator.pop(context),
  ///     ),
  ///     PlatformDialogAction(
  ///       text: 'Delete',
  ///       isDestructive: true,
  ///       onPressed: () {
  ///         // Perform delete
  ///         Navigator.pop(context);
  ///       },
  ///     ),
  ///   ],
  /// );
  /// ```
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? content,
    Widget? contentWidget,
    required List<PlatformDialogAction> actions,
    bool barrierDismissible = true,
  }) {
    if (Platform.isIOS) {
      return showCupertinoDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(title),
          content: contentWidget ?? (content != null ? Text(content) : null),
          actions: actions.map((action) {
            return CupertinoDialogAction(
              onPressed: action.onPressed,
              isDefaultAction: action.isDefault,
              isDestructiveAction: action.isDestructive,
              child: Text(action.text),
            );
          }).toList(),
        ),
      );
    } else {
      return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (BuildContext context) => AlertDialog(
          title: Text(title),
          content: contentWidget ?? (content != null ? Text(content) : null),
          actions: actions.map((action) {
            if (action.isDestructive) {
              return TextButton(
                onPressed: action.onPressed,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(action.text),
              );
            } else if (action.isDefault) {
              return FilledButton(
                onPressed: action.onPressed,
                child: Text(action.text),
              );
            } else {
              return TextButton(
                onPressed: action.onPressed,
                child: Text(action.text),
              );
            }
          }).toList(),
        ),
      );
    }
  }

  /// Shows a platform-adaptive action sheet (bottom sheet on Android, action sheet on iOS)
  static Future<T?> showActionSheet<T>({
    required BuildContext context,
    required String title,
    String? message,
    required List<PlatformDialogAction> actions,
    PlatformDialogAction? cancelAction,
  }) {
    if (Platform.isIOS) {
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: Text(title),
          message: message != null ? Text(message) : null,
          actions: actions.map((action) {
            return CupertinoActionSheetAction(
              onPressed: action.onPressed,
              isDefaultAction: action.isDefault,
              isDestructiveAction: action.isDestructive,
              child: Text(action.text),
            );
          }).toList(),
          cancelButton: cancelAction != null
              ? CupertinoActionSheetAction(
                  onPressed: cancelAction.onPressed,
                  child: Text(cancelAction.text),
                )
              : null,
        ),
      );
    } else {
      // Material Design uses bottom sheet for action sheets
      return showModalBottomSheet<T>(
        context: context,
        builder: (BuildContext context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title.isNotEmpty || message != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (title.isNotEmpty)
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      if (message != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          message,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ...actions.map((action) {
                return ListTile(
                  title: Text(
                    action.text,
                    style: TextStyle(
                      color: action.isDestructive
                          ? Theme.of(context).colorScheme.error
                          : null,
                      fontWeight:
                          action.isDefault ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  onTap: action.onPressed,
                );
              }),
              if (cancelAction != null)
                ListTile(
                  title: Text(cancelAction.text),
                  onTap: cancelAction.onPressed,
                ),
            ],
          ),
        ),
      );
    }
  }
}

/// Represents an action button in a platform-aware dialog
class PlatformDialogAction {
  /// The text to display on the action button
  final String text;

  /// Callback when the action is pressed
  final VoidCallback onPressed;

  /// Whether this is the default/primary action (emphasized)
  final bool isDefault;

  /// Whether this is a destructive action (shown in red)
  final bool isDestructive;

  const PlatformDialogAction({
    required this.text,
    required this.onPressed,
    this.isDefault = false,
    this.isDestructive = false,
  });
}
