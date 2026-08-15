import 'geolocation_service.dart';
import 'preferences.dart';

class ConfigurationService {
  static Future<void> applyUri(Uri uri) async {
    final url = (uri.scheme == 'http' || uri.scheme == 'https')
        ? '${uri.origin}${uri.path}'
        : uri.queryParameters['url'];
    await applyParameters(uri.queryParameters, url: url);
  }

  static Future<void> applyManagedConfig(Map<String, dynamic> config) async {
    await applyParameters(config, url: config[Preferences.url]?.toString());
  }

  static Future<void> applyParameters(Map<String, dynamic> parameters, {String? url}) async {
    if (url != null) {
      await Preferences.instance.setString(Preferences.url, url);
    }
    await _applyStringParameter(parameters, Preferences.id);
    await _applyStringParameter(parameters, Preferences.accuracy);
    await _applyIntParameter(parameters, Preferences.distance);
    await _applyIntParameter(parameters, Preferences.interval);
    await _applyIntParameter(parameters, Preferences.angle);
    await _applyIntParameter(parameters, Preferences.heartbeat);
    await _applyBoolParameter(parameters, Preferences.buffer);
    await _applyBoolParameter(parameters, Preferences.wakelock);
    await _applyBoolParameter(parameters, Preferences.stopDetection);
    await _applyBoolParameter(parameters, Preferences.preferPlatformProviders);
    await GeolocationService.tracker.setConfig(Preferences.buildConfig());
  }

  static Future<void> _applyStringParameter(
      Map<String, dynamic> parameters, String key) async {
    final value = parameters[key];
    if (value != null) {
      await Preferences.instance.setString(key, value.toString());
    }
  }

  static Future<void> _applyIntParameter(
      Map<String, dynamic> parameters, String key) async {
    final raw = parameters[key];
    final value = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
    if (value != null) {
      await Preferences.instance.setInt(key, value);
    }
  }

  static Future<void> _applyBoolParameter(
      Map<String, dynamic> parameters, String key) async {
    final raw = parameters[key];
    if (raw is bool) {
      await Preferences.instance.setBool(key, raw);
    } else if (raw is String) {
      switch (raw) {
        case 'false':
          await Preferences.instance.setBool(key, false);
        case 'true':
          await Preferences.instance.setBool(key, true);
      }
    }
  }
}
