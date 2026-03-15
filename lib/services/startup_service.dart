import 'dart:io';

import 'package:flutter/services.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

import '../config/constants.dart';
import 'logger_service.dart';

class StartupService {
  StartupService(this._logger);

  final LoggerService _logger;
  bool _initialized = false;
  static const MethodChannel _macStartupChannel = MethodChannel(
    'snotice/startup',
  );

  bool get isSupported =>
      Platform.isMacOS || Platform.isLinux || Platform.isWindows;

  Future<void> setAutoLaunchOnLogin(bool enabled) async {
    if (!isSupported) {
      return;
    }

    if (Platform.isMacOS) {
      await _setMacNativeAutoLaunchOnLogin(enabled);
      return;
    }

    await _initializeIfNeeded();

    try {
      final isEnabled = await launchAtStartup.isEnabled();
      if (isEnabled == enabled) {
        return;
      }

      if (enabled) {
        await launchAtStartup.enable();
      } else {
        await launchAtStartup.disable();
      }
    } catch (e) {
      _logger.error('Failed to update auto-launch-on-login setting: $e');
      rethrow;
    }
  }

  Future<void> _setMacNativeAutoLaunchOnLogin(bool enabled) async {
    try {
      await _cleanupLegacyMacLaunchAgent();

      final isEnabled = await _macStartupChannel.invokeMethod<bool>(
        'isEnabled',
      );
      if (isEnabled == enabled) {
        return;
      }

      await _macStartupChannel.invokeMethod<void>('setEnabled', {
        'enabled': enabled,
      });
    } catch (e) {
      _logger.error('Failed to update macOS auto-launch-on-login setting: $e');
      rethrow;
    }
  }

  Future<void> _cleanupLegacyMacLaunchAgent() async {
    final legacyFile = File(
      '${Platform.environment['HOME']}/Library/LaunchAgents/${AppConstants.appPackageName}.plist',
    );
    if (await legacyFile.exists()) {
      await legacyFile.delete();
    }
  }

  Future<void> _initializeIfNeeded() async {
    if (_initialized || !isSupported) {
      return;
    }

    launchAtStartup.setup(
      appName: AppConstants.appName,
      appPath: Platform.resolvedExecutable,
      packageName: AppConstants.appPackageName,
    );
    _initialized = true;
  }
}
