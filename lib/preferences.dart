
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
  static const String distance = 'distance';
  static const String interval = 'interval';
  static const String angle = 'angle';
  static const String heartbeat = 'heartbeat';
  static const String fastestInterval = 'fastest_interval';
  static const String buffer = 'buffer';
  static const String wakelock = 'wakelock';
  static const String stopDetection = 'stop_detection';

  static const String lastTimestamp = 'lastTimestamp';
  static const String lastLatitude = 'lastLatitude';
  static const String lastLongitude = 'lastLongitude';
  static const String lastHeading = 'lastHeading';

  static Future<void> init() async {
    instance = await SharedPreferencesWithCache.create(
      sharedPreferencesOptions: Platform.isAndroid
        ? SharedPreferencesAsyncAndroidOptions(backend: SharedPreferencesAndroidBackendLibrary.SharedPreferences)
        : SharedPreferencesOptions(),
      cacheOptions: SharedPreferencesWithCacheOptions(
        allowList: {
          id, url, accuracy, distance, interval, angle, heartbeat,
          fastestInterval, buffer,  wakelock, stopDetection,
          lastTimestamp, lastLatitude, lastLongitude, lastHeading,
          'device_id_preference', 'server_url_preference', 'accuracy_preference',
          'frequency_preference', 'distance_preference', 'buffer_preference', 'password',
        },
      ),
    );
  }

  static Future<void> migrate() async {
    if (Platform.isAndroid) {
      if (instance.get(interval) is String) {
        final stringValue = instance.getString(interval);
        await instance.setInt(interval, int.tryParse(stringValue ?? '') ?? 300);
      }
      if (instance.get(distance) is String) {
        final stringValue = instance.getString(distance);
        final intValue = int.tryParse(stringValue ?? '') ?? 75;
        await instance.setInt(distance, intValue > 0 ? intValue : 75);
      }
      if (instance.get(angle) is String) {
        final stringValue = instance.getString(angle);
        final intValue = int.tryParse(stringValue ?? '') ?? 0;
        await instance.setInt(angle, intValue);
      }
    } else {
      await _migrate();
    }
    await instance.setString(id, instance.getString(id) ?? (Random().nextInt(90000000) + 10000000).toString());
    await instance.setString(url, instance.getString(url) ?? 'http://demo.traccar.org:5055');
    await instance.setString(accuracy, instance.getString(accuracy) ?? 'medium');
    await instance.setInt(interval, instance.getInt(interval) ?? 300);
    await instance.setInt(distance, instance.getInt(distance) ?? 75);
    await instance.setBool(buffer, instance.getBool(buffer) ?? true);
    await instance.setBool(stopDetection, instance.getBool(stopDetection) ?? true);
    await instance.setInt(fastestInterval, instance.getInt(fastestInterval) ?? 30);
  }

  static bg.Config geolocationConfig() {
    final isHighestAccuracy = instance.getString(accuracy) == 'highest';
    final locationUpdateInterval = (instance.getInt(interval) ?? 0) * 1000;
    final fastestLocationUpdateInterval = (instance.getInt(fastestInterval) ?? 30) * 1000;
    final heartbeatInterval = instance.getInt(heartbeat) ?? 0;
    return bg.Config(
      isMoving: true,
      geolocation: bg.GeoConfig(
        desiredAccuracy: switch (instance.getString(accuracy)) {
          'highest' => Platform.isIOS ? bg.DesiredAccuracy.navigation : bg.DesiredAccuracy.high,
          'high' => bg.DesiredAccuracy.high,
          'low' => bg.DesiredAccuracy.low,
          _ => bg.DesiredAccuracy.medium,
        },
        distanceFilter: isHighestAccuracy ? 0 : instance.getInt(distance)?.toDouble(),
        locationUpdateInterval: isHighestAccuracy ? 0 : (locationUpdateInterval > 0 ? locationUpdateInterval : null),
        fastestLocationUpdateInterval: isHighestAccuracy ? 0 : fastestLocationUpdateInterval,
        disableElasticity: true,
        pausesLocationUpdatesAutomatically: Platform.isIOS ? !(isHighestAccuracy || instance.getBool(stopDetection) == false) : null,
        showsBackgroundLocationIndicator: false,
      ),
      app: bg.AppConfig(
        enableHeadless: true,
        stopOnTerminate: false,
        startOnBoot: true,
        heartbeatInterval: heartbeatInterval > 0 ? heartbeatInterval.toDouble() : null,
        preventSuspend: heartbeatInterval > 0,
        backgroundPermissionRationale: bg.PermissionRationale(
          title: 'Allow {applicationName} to access this device\'s location in the background',
          message: 'For reliable tracking, please enable {backgroundPermissionOptionLabel} location access.',
          positiveAction: 'Change to {backgroundPermissionOptionLabel}',
          negativeAction: 'Cancel'
        ),
        notification: bg.Notification(
          smallIcon: 'drawable/ic_stat_notify',
          priority: bg.NotificationPriority.low,
        ),
      ),
      http: bg.HttpConfig(
        autoSync: false,
        url: _formatUrl(instance.getString(url)),
        params: {
          'device_id': instance.getString(id),
        },
      ),
      logger: const bg.LoggerConfig(
        logLevel: bg.LogLevel.verbose,
        logMaxDays: 1,
      ),
      activity: bg.ActivityConfig(
        disableStopDetection: instance.getBool(stopDetection) == false,
      ),
      persistence: bg.PersistenceConfig(
        maxRecordsToPersist: instance.getBool(buffer) != false ? -1 : 1,
        locationTemplate: _locationTemplate(),
      ),
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
      instance.setInt(distance, oldDistance > 0 ? oldDistance : 75);
      instance.remove('distance_preference');
    }
    final oldBuffer = instance.getBool('buffer_preference');
    if (oldBuffer != null) {
      instance.setBool(buffer, oldBuffer);
      instance.remove('buffer_preference');
    }
  }
}
