import 'dart:io';
import 'package:flutter/services.dart';
import 'preferences.dart';

class RootService {
  static const MethodChannel _channel = MethodChannel('org.traccar.client/root');

  static bool? _cachedRootAvailable;

  /// 检测设备是否具备且允许 Root 权限
  static Future<bool> isRootAvailable({bool refresh = false}) async {
    if (!Platform.isAndroid) return false;
    if (_cachedRootAvailable != null && !refresh) {
      return _cachedRootAvailable!;
    }
    try {
      final bool? result = await _channel.invokeMethod<bool>('isRootAvailable');
      _cachedRootAvailable = result ?? false;
      return _cachedRootAvailable!;
    } catch (_) {
      _cachedRootAvailable = false;
      return false;
    }
  }

  /// 应用或取消 Root 保活机制
  static Future<bool> applyKeepAlive(bool enable) async {
    if (!Platform.isAndroid) return false;
    try {
      final bool? result = await _channel.invokeMethod<bool>(
        'applyRootKeepAlive',
        {'enable': enable},
      );
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// App 启动时如果用户开启了 Root 保活，则自动静默应用
  static Future<void> init() async {
    if (!Platform.isAndroid) return;
    final isEnabled = Preferences.instance.getBool(Preferences.rootKeepAlive) ?? false;
    if (isEnabled) {
      final hasRoot = await isRootAvailable();
      if (hasRoot) {
        await applyKeepAlive(true);
      }
    }
  }
}
