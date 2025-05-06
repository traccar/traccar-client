
import 'dart:io';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const String id = 'id';
  static const String url = 'url';
  static const String accuracy = 'accuracy';
  static const String interval = 'interval';
  static const String distance = 'distance';
  static const String buffer = 'buffer';

  static Future<void> init() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (Platform.isIOS) {
      await _migrate(preferences);
    }
    await preferences.setString(id, preferences.getString(id) ?? (Random().nextInt(900000) + 100000).toString());
    await preferences.setString(url, preferences.getString(url) ?? 'http://demo.traccar.org:5055');
    await preferences.setString(accuracy, preferences.getString(accuracy) ?? 'medium');
    await preferences.setInt(interval, preferences.getInt(interval) ?? 300);
    await preferences.setInt(distance, preferences.getInt(distance) ?? 0);
    await preferences.setBool(buffer, preferences.getBool(buffer) ?? true);
  }

  static Future<void> _migrate(SharedPreferences preferences) async {
    final oldId = preferences.getString('device_id_preference');
    if (oldId != null) {
      preferences.setString(id, oldId);
      preferences.remove('device_id_preference');
    }
    final oldUrl = preferences.getString('server_url_preference');
    if (oldUrl != null) {
      preferences.setString(url, oldUrl);
      preferences.remove('server_url_preference');
    }
    final oldAccuracy = preferences.getString('accuracy_preference');
    if (oldAccuracy != null) {
      preferences.setString(accuracy, oldAccuracy);
      preferences.remove('accuracy_preference');
    }
    final oldIntervalString = preferences.getString('frequency_preference');
    final oldInterval = oldIntervalString != null ? int.tryParse(oldIntervalString) : null;
    if (oldInterval != null) {
      preferences.setInt(interval, oldInterval);
      preferences.remove('frequency_preference');
    }
    final oldDistanceString = preferences.getString('distance_preference');
    final oldDistance = oldDistanceString != null ? int.tryParse(oldDistanceString) : null;
    if (oldDistance != null) {
      preferences.setInt(distance, oldDistance);
      preferences.remove('distance_preference');
    }
    final oldAngleString = preferences.getString('angle_preference');
    final oldAngle = oldAngleString != null ? int.tryParse(oldAngleString) : null;
    if (oldAngle != null) {
      preferences.setInt('angle', oldAngle);
      preferences.remove('angle_preference');
    }
    final oldBuffer = preferences.getBool('buffer_preference');
    if (oldBuffer != null) {
      preferences.setBool(buffer, oldBuffer);
      preferences.remove('buffer_preference');
    }
  }
}
