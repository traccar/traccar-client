import 'dart:async';
import 'dart:developer' as developer;

import 'package:managed_configurations/managed_configurations.dart';

import 'configuration_service.dart';

class ManagedConfigService {
  static final ManagedConfigurations _managedConfigurations = ManagedConfigurations();

  static Future<void> init() async {
    try {
      final config = await _managedConfigurations.getManagedConfigurations;
      if (config != null && config.isNotEmpty) {
        await ConfigurationService.applyManagedConfig(config);
      }
    } catch (error) {
      developer.log('Failed to read managed configuration', error: error);
    }
    _managedConfigurations.mangedConfigurationsStream.listen((config) {
      if (config != null && config.isNotEmpty) {
        ConfigurationService.applyManagedConfig(config);
      }
    });
  }
}
