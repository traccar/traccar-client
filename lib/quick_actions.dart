import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_actions/quick_actions.dart';

import 'geolocation_service.dart';
import 'l10n/app_localizations.dart';

class QuickActionsInitializer extends StatefulWidget {
  const QuickActionsInitializer({super.key});

  @override
  State<QuickActionsInitializer> createState() => _QuickActionsInitializerState();
}

class _QuickActionsInitializerState extends State<QuickActionsInitializer> {
  final QuickActions quickActions = QuickActions();

  @override
  void initState() {
    super.initState();
    quickActions.initialize((shortcutType) async {
      FirebaseCrashlytics.instance.log('quick_action: $shortcutType');
      try {
        switch (shortcutType) {
          case 'start':
            await GeolocationService.tracker.start();
          case 'stop':
            await GeolocationService.tracker.stop();
          case 'sos':
            await GeolocationService.tracker.requestPosition(alarm: 'sos');
        }
      } on PlatformException {
        // permission denied or startup error
      }
      if (mounted) {
        FirebaseCrashlytics.instance.log('quick_action_exit');
        SystemNavigator.pop();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localizations = AppLocalizations.of(context)!;
    quickActions.setShortcutItems(<ShortcutItem>[
      ShortcutItem(type: 'start', localizedTitle: localizations.startAction, icon: 'play'),
      ShortcutItem(type: 'stop', localizedTitle: localizations.stopAction, icon: 'stop'),
      ShortcutItem(type: 'sos', localizedTitle: localizations.sosAction, icon: 'exclamation'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
