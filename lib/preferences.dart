
import 'dart:io';
import 'dart:math';

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

class Preferences {
  static late SharedPreferencesWithCache instance;
  static const String id = 'id';
  static const String url = 'url';
  static const String accuracy = 'accuracy';
  static const String interval = 'interval';
  static const String distance = 'distance';
  static const String buffer = 'buffer';

  static Future<void> init() async {
    instance = await SharedPreferencesWithCache.create(
      sharedPreferencesOptions: Platform.isAndroid
        ? SharedPreferencesAsyncAndroidOptions(backend: SharedPreferencesAndroidBackendLibrary.SharedPreferences)
        : SharedPreferencesOptions(),
      cacheOptions: SharedPreferencesWithCacheOptions(
        allowList: {
          'id', 'url', 'accuracy', 'interval', 'distance', 'buffer',
          'device_id_preference', 'server_url_preference', 'accuracy_preference',
          'frequency_preference', 'distance_preference', 'buffer_preference',
        },
      ),
    );
    if (Platform.isIOS) {
      await _migrate();
    }
    await instance.setString(id, instance.getString(id) ?? (Random().nextInt(90000000) + 10000000).toString());
    await instance.setString(url, instance.getString(url) ?? 'http://demo.traccar.org:5055');
    await instance.setString(accuracy, instance.getString(accuracy) ?? 'medium');
    await instance.setInt(interval, instance.getInt(interval) ?? 300);
    final distanceValue = instance.getInt(distance);
    if (distanceValue == null || distanceValue <= 0) {
      await instance.setInt(distance, 75);
    }
    await instance.setBool(buffer, instance.getBool(buffer) ?? true);
  }

  static bg.Config geolocationConfig() {
    return bg.Config(
      stopOnTerminate: false,
      startOnBoot: true,
      desiredAccuracy: switch (instance.getString(accuracy)) {
        'high' => bg.Config.DESIRED_ACCURACY_HIGH,
        'low' => bg.Config.DESIRED_ACCURACY_LOW,
        _ => bg.Config.DESIRED_ACCURACY_MEDIUM,
      },
      url: _formatUrl(instance.getString(url)),
      params: {
        "device_id": instance.getString(id),
      },
      distanceFilter: instance.getInt(distance)?.toDouble(),
      locationUpdateInterval: (instance.getInt(interval) ?? 0) * 1000,
      maxRecordsToPersist: instance.getBool(buffer) != false ? -1 : 0,
      logLevel: bg.Config.LOG_LEVEL_INFO,
      logMaxDays: 1,
      locationTemplate: _locationTemplate(),
    );
  }

  static String? _formatUrl(String? url) {
    if (url == null) return null;
    final uri = Uri.parse(url);
    if ((uri.path.isEmpty || uri.path == '') && !url.endsWith('/')) return '$url/';
    return url;
  }

  static String _locationTemplate() {
    return '''{
      "timestamp": "<%= timestamp %>",
      "coords": {
        "latitude": <%= latitude %>,
        "longitude": <%= longitude %>,
        "accuracy": <%= accuracy %>,
        "speed": <%= speed %>,
        "heading": <%= heading %>,
        "altitude": <%= altitude %>
      },
      "is_moving": <%= is_moving %>,
      "odometer": <%= odometer %>,
      "event": "<%= event %>",
      "battery": {
        "level": <%= battery.level %>,
        "is_charging": <%= battery.is_charging %>
      },
      "activity": {
        "type": "<%= activity.type %>"
      },
      "extras": {},
      "_": "&id=${instance.getString(id)}&lat=<%= latitude %>&lon=<%= longitude %>&timestamp=<%= timestamp %>&"
    }'''.split('\n').map((line) => line.trimLeft()).join();
  }

  static Future<void> _migrate() async {
    final oldId = instance.getString('device_id_preference');
    if (oldId != null) {
      instance.setString(id, oldId);
      instance.remove('device_id_preference');
    }
    final oldUrl = instance.getString('server_url_preference');
    if (oldUrl != null) {
      instance.setString(url, oldUrl);
      instance.remove('server_url_preference');
    }
    final oldAccuracy = instance.getString('accuracy_preference');
    if (oldAccuracy != null) {
      instance.setString(accuracy, oldAccuracy);
      instance.remove('accuracy_preference');
    }
    final oldIntervalString = instance.getString('frequency_preference');
    final oldInterval = oldIntervalString != null ? int.tryParse(oldIntervalString) : null;
    if (oldInterval != null) {
      instance.setInt(interval, oldInterval);
      instance.remove('frequency_preference');
    }
    final oldDistanceString = instance.getString('distance_preference');
    final oldDistance = oldDistanceString != null ? int.tryParse(oldDistanceString) : null;
    if (oldDistance != null) {
      instance.setInt(distance, oldDistance);
      instance.remove('distance_preference');
    }
    final oldBuffer = instance.getBool('buffer_preference');
    if (oldBuffer != null) {
      instance.setBool(buffer, oldBuffer);
      instance.remove('buffer_preference');
    }
  }
}
