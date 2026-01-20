import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_config.dart';
import 'logger_service.dart';

class ConfigService {
  final LoggerService _logger;

  ConfigService(this._logger);

  Future<AppConfig> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('app_config');

      if (configJson != null) {
        _logger.info('Config loaded from storage');
        return AppConfig.fromJson(jsonDecode(configJson));
      }

      _logger.info('Using default config');
      return AppConfig();
    } catch (e) {
      _logger.error('Failed to load config: $e');
      return AppConfig();
    }
  }

  Future<void> saveConfig(AppConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_config', jsonEncode(config.toJson()));
      _logger.info('Config saved');
    } catch (e) {
      _logger.error('Failed to save config: $e');
      rethrow;
    }
  }

  Future<void> resetConfig() async {
    await saveConfig(AppConfig());
    _logger.info('Config reset to default');
  }
}
