import 'dart:developer' as developer;

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

import 'preferences.dart';

class ScheduleService {
  static const _weekdays = '1-7';

  static Future<void> sync() async {
    final enabled = Preferences.instance.getBool(Preferences.scheduleEnabled) ?? false;
    final start = Preferences.instance.getString(Preferences.scheduleStart);
    final stop = Preferences.instance.getString(Preferences.scheduleStop);

    if (!enabled || start == null || stop == null) {
      await _clear();
      return;
    }

    final entry = '$_weekdays $start-$stop';
    try {
      await bg.BackgroundGeolocation.setConfig(bg.Config(schedule: [entry]));
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
