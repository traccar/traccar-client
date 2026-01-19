import 'dart:developer' as developer;

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

import 'preferences.dart';

class ScheduleService {
  static Future<void> sync() async {
    final enabled = Preferences.instance.getBool(Preferences.scheduleEnabled) ?? false;
    final rawEntry = Preferences.instance.getString(Preferences.scheduleEntry)?.trim();

    if (!enabled || rawEntry == null || rawEntry.isEmpty) {
      await _clear();
      return;
    }

    final entries = rawEntry
        .split(RegExp(r'[\r\n]+'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    if (entries.isEmpty) {
      await _clear();
      return;
    }

    try {
      await bg.BackgroundGeolocation.setConfig(bg.Config(schedule: entries));
      await bg.BackgroundGeolocation.startSchedule();
    } catch (error, stackTrace) {
      developer.log('Failed to apply schedule', error: error, stackTrace: stackTrace);
    }
  }

  static Future<void> _clear() async {
    try {
      await bg.BackgroundGeolocation.stopSchedule();
      await bg.BackgroundGeolocation.setConfig(bg.Config(schedule: const []));
    } catch (error, stackTrace) {
      developer.log('Failed to clear schedule', error: error, stackTrace: stackTrace);
    }
  }
}
