import 'dart:io';

import 'package:launch_at_startup/launch_at_startup.dart';

import '../config/constants.dart';
import 'logger_service.dart';

class StartupService {
  StartupService(this._logger);

  final LoggerService _logger;
  bool _initialized = false;

  bool get isSupported =>
      Platform.isMacOS || Platform.isLinux || Platform.isWindows;

  Future<void> setAutoLaunchOnLogin(bool enabled) async {
    if (!isSupported) {
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
