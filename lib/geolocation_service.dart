
import 'dart:io';

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:traccar_client/preferences.dart';
import 'package:wakelock_partial_android/wakelock_partial_android.dart';

class GeolocationService {
  static Future<void> init() async {
    await bg.BackgroundGeolocation.ready(Preferences.geolocationConfig());
    if (Platform.isAndroid) {
      await bg.BackgroundGeolocation.registerHeadlessTask(headlessTask);
    }
    bg.BackgroundGeolocation.onEnabledChange(onEnabledChange);
    bg.BackgroundGeolocation.onMotionChange(onMotionChange);
    bg.BackgroundGeolocation.onHeartbeat(onHeartbeat);
  }

  static Future<void> onEnabledChange(bool enabled) async {
    if (Preferences.instance.getBool(Preferences.wakelock) ?? false) {
      if (!enabled) {
        await WakelockPartialAndroid.release();
      }
    }
  }

  static Future<void> onMotionChange(bg.Location location) async {
    if (Preferences.instance.getBool(Preferences.wakelock) ?? false) {
      if (location.isMoving) {
        await WakelockPartialAndroid.acquire();
      } else {
        await WakelockPartialAndroid.release();
      }
    }
  }

  static Future<void> onHeartbeat(bg.HeartbeatEvent event) async {
    await bg.BackgroundGeolocation.getCurrentPosition(samples: 1, persist: true, extras: {'heartbeat': true});
  }
}

@pragma('vm:entry-point')
void headlessTask(bg.HeadlessEvent headlessEvent) async {
  await Preferences.init();
  switch (headlessEvent.name) {
    case bg.Event.ENABLEDCHANGE:
      await GeolocationService.onEnabledChange(headlessEvent.event);
      break;
    case bg.Event.MOTIONCHANGE:
      await GeolocationService.onMotionChange(headlessEvent.event);
      break;
    case bg.Event.HEARTBEAT:
      await GeolocationService.onHeartbeat(headlessEvent.event);
      break;
  }
}
