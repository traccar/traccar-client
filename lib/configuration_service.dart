import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

import 'preferences.dart';
import 'schedule_service.dart';

class ConfigurationService {
  static Future<void> applyUri(Uri uri) async {
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      await Preferences.instance.setString(Preferences.url, '${uri.origin}${uri.path}');
    } else {
      final url = uri.queryParameters['url'];
      if (url != null) {
        await Preferences.instance.setString(Preferences.url, url);
      }
    }
    final parameters = uri.queryParameters;
    await _applyStringParameter(parameters, Preferences.id);
    await _applyStringParameter(parameters, Preferences.accuracy);
    await _applyIntParameter(parameters, Preferences.distance);
    await _applyIntParameter(parameters, Preferences.interval);
    await _applyIntParameter(parameters, Preferences.angle);
    await _applyIntParameter(parameters, Preferences.heartbeat);
    await _applyIntParameter(parameters, Preferences.fastestInterval);
    await _applyBoolParameter(parameters, Preferences.buffer);
    await _applyBoolParameter(parameters, Preferences.wakelock);
    await _applyBoolParameter(parameters, Preferences.stopDetection);
    await _applyScheduleParameters(parameters);
    await bg.BackgroundGeolocation.setConfig(Preferences.geolocationConfig());
    await ScheduleService.sync();
    await _applyServiceParameter(parameters);
  }

  static Future<void> _applyStringParameter(
      Map<String, String> parameters, String key) async {
    final value = parameters[key];
    if (value != null) {
      await Preferences.instance.setString(key, value);
    }
  }

  static Future<void> _applyIntParameter(
      Map<String, String> parameters, String key) async {
    final stringValue = parameters[key];
    if (stringValue != null) {
      final value = int.tryParse(stringValue);
      if (value != null) {
        await Preferences.instance.setInt(key, value);
      }
    }
  }

  static Future<void> _applyBoolParameter(
      Map<String, String> parameters, String key) async {
    final value = parameters[key];
    if (value != null) {
      switch (value) {
        case 'false':
          await Preferences.instance.setBool(key, false);
          break;
        case 'true':
          await Preferences.instance.setBool(key, true);
          break;
      }
    }
  }

  static Future<void> _applyScheduleParameters(
      Map<String, String> parameters) async {
    final scheduleEntry = parameters['schedule']?.trim();
    if (scheduleEntry != null && scheduleEntry.isNotEmpty) {
      await Preferences.instance.setString(Preferences.scheduleEntry, scheduleEntry);
      await Preferences.instance.setBool(Preferences.scheduleEnabled, true);
      return;
    }

    final start = parameters['startTime'];
    final stop = parameters['stopTime'];
    if (_isValidTime(start) && _isValidTime(stop)) {
      final normalizedStart = _normalizeTime(start!);
      final normalizedStop = _normalizeTime(stop!);
      final days = parameters['days']?.trim();
      final entryDays = (days != null && days.isNotEmpty) ? days : '1-7';
      final entry = '$entryDays $normalizedStart-$normalizedStop';
      await Preferences.instance.setString(Preferences.scheduleStart, normalizedStart);
      await Preferences.instance.setString(Preferences.scheduleStop, normalizedStop);
      await Preferences.instance.setString(Preferences.scheduleEntry, entry);
      await Preferences.instance.setBool(Preferences.scheduleEnabled, true);
    }
  }

  static Future<void> _applyServiceParameter(
      Map<String, String> parameters) async {
    final value = parameters['service'];
    switch (value) {
      case 'true':
        await bg.BackgroundGeolocation.start();
        break;
      case 'false':
        await bg.BackgroundGeolocation.stop();
        break;
    }
  }

  static bool _isValidTime(String? value) {
    if (value == null) {
      return false;
    }
    final parts = value.split(':');
    if (parts.length != 2) {
      return false;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return false;
    }
    return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  }

  static String _normalizeTime(String value) {
    final parts = value.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}

