import 'package:traccar_client_sdk/traccar_client_sdk.dart';

import 'preferences.dart';

class GeolocationService {
  static final tracker = TraccarClientSdk();

  static Future<void> restartIfTracking() async {
    if (await tracker.isTracking()) {
      await tracker.stop();
      await tracker.start(Preferences.buildConfig());
    }
  }
}
