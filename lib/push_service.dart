import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

import 'preferences.dart';

class PushService {
  static Future<void> init() async {
    await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    FirebaseMessaging.onMessage.listen(_onMessage);
    FirebaseMessaging.instance.onTokenRefresh.listen(_uploadToken);
    bg.BackgroundGeolocation.onEnabledChange((enabled) async {
      if (enabled) {
        _uploadToken(await FirebaseMessaging.instance.getToken());
      }
    });
  }

  @pragma('vm:entry-point')
  static Future<void> _backgroundHandler(RemoteMessage message) async {
    await Preferences.init();
    await _onMessage(message);
  }

  static Future<void> _onMessage(RemoteMessage message) async {
    final command = message.data['command'];
    if (command == 'positionSingle') {
      try {
        await bg.BackgroundGeolocation.getCurrentPosition(samples: 1, persist: true, extras: {'remote': true});
      } catch (error) {
        developer.log('Failed to get position', error: error);
      }
    }
  }

  static Future<void> _uploadToken(String? token) async {
    if (token == null) return;
    final id = Preferences.instance.getString(Preferences.id);
    final url = Preferences.instance.getString(Preferences.url);
    if (id == null || url == null) return;
    try {
      final request = await HttpClient().postUrl(Uri.parse(url));
      request.headers.contentType = ContentType.parse('application/x-www-form-urlencoded');
      request.write('id=${Uri.encodeComponent(id)}&notificationToken=${Uri.encodeComponent(token)}');
      await request.close();
    } catch (error) {
      developer.log('Failed to upload token', error: error);
    }
  }
}
