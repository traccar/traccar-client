import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

import 'l10n/app_localizations.dart';

class QuickActionsInitializer extends StatefulWidget {
  const QuickActionsInitializer({super.key});

  @override
  State<QuickActionsInitializer> createState() => _QuickActionsInitializerState();
}

class _QuickActionsInitializerState extends State<QuickActionsInitializer> {
  final QuickActions quickActions = QuickActions();
  static const MethodChannel _intentChannel = MethodChannel('org.traccar.client/intent');

  @override
  void initState() {
    super.initState();
    quickActions.initialize((shortcutType) async {
      await _handleAction(shortcutType);
    });
    _intentChannel.setMethodCallHandler((call) async {
      if (call.method == 'action') {
        await _handleAction(call.arguments as String);
      }
    });
  }

  Future<void> _handleAction(String shortcutType) async {
    developer.log('action $shortcutType');
    switch (shortcutType) {
      case 'start':
        bg.BackgroundGeolocation.start();
      case 'stop':
        bg.BackgroundGeolocation.stop();
      case 'sos':
        try {
          await bg.BackgroundGeolocation.getCurrentPosition(samples: 1, persist: true, extras: {'alarm': 'sos'});
          await bg.BackgroundGeolocation.sync();
        } catch (error) {
          developer.log('Failed to send alert', error: error);
        }
    }
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
