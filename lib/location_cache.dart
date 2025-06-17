import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:traccar_client/preferences.dart';

class Location {
  final String timestamp;
  final double latitude;
  final double longitude;
  final double heading;
  const Location({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.heading,
  });
}

class LocationCache {
  static Location? _last;

  static Location? get() {
    if (_last == null) {
      final timestamp = Preferences.instance.getString(Preferences.lastTimestamp);
      final latitude = Preferences.instance.getDouble(Preferences.lastLatitude);
      final longitude = Preferences.instance.getDouble(Preferences.lastLongitude);
      final heading = Preferences.instance.getDouble(Preferences.lastHeading);
      if (timestamp != null && latitude != null && longitude != null && heading != null) {
        _last = Location(
          timestamp: timestamp,
          latitude: latitude,
          longitude: longitude,
          heading: heading,
        );
      }
    }
    return _last;
  }

  static Future<void> set(bg.Location location) async {
    final last = Location(
      timestamp: location.timestamp,
      latitude: location.coords.latitude,
      longitude: location.coords.longitude,
      heading: location.coords.heading,
    );
    Preferences.instance.setString(Preferences.lastTimestamp, last.timestamp);
    Preferences.instance.setDouble(Preferences.lastLatitude, last.latitude);
    Preferences.instance.setDouble(Preferences.lastLongitude, last.longitude);
    Preferences.instance.setDouble(Preferences.lastHeading, last.heading);
    _last = last;
  }
}
