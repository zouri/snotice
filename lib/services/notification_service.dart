import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../config/constants.dart';
import '../models/app_config.dart';
import '../models/notification_request.dart';
import 'logger_service.dart';
import 'flash_overlay_service.dart';

class NotificationService {
  final LoggerService _logger;
  final FlashOverlayService _flashService;
  AppConfig _config;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService(this._logger, this._flashService, [AppConfig? config])
    : _config = config ?? AppConfig();

  void updateConfig(AppConfig config) {
    _config = config;
  }

  Future<void> initialize() async {
    const initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettingsLinux = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );

    const initializationSettings = InitializationSettings(
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    await _notificationsPlugin.initialize(initializationSettings);

    _logger.info('Notification service initialized');
  }

  Future<void> showNotification(NotificationRequest request) async {
    // Overlay 提醒允许 body 为空，优先处理 flash/barrage 分支
    if (request.isFlash) {
      if (!_config.showFlash) {
        _logger.warning('Flash notifications are disabled in config');
        return;
      }
      await _handleFlashNotification(request);
      return;
    }
    if (request.isBarrage) {
      if (!_config.showBarrage) {
        _logger.warning('Barrage notifications are disabled in config');
        return;
      }
      await _handleBarrageNotification(request);
      return;
    }

    if (!request.isValid) {
      _logger.error('Invalid notification request: title or body is empty');
      return;
    }

    // 标准通知逻辑
    try {
      final darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: _config.showSound,
      );

      const linuxDetails = LinuxNotificationDetails();

      final notificationDetails = NotificationDetails(
        macOS: darwinDetails,
        linux: linuxDetails,
      );

      await _notificationsPlugin.show(
        AppConstants.notificationId,
        request.title,
        request.body,
        notificationDetails,
        payload: request.payload?.toString(),
      );

      _logger.notification(
        'Notification sent: ${request.title}',
        data: request.toJson(),
      );
    } catch (e) {
      _logger.error('Failed to send notification: $e');
      rethrow;
    }
  }

  Future<void> _handleBarrageNotification(NotificationRequest request) async {
    try {
      final color = request.barrageColor ?? '#FFFFFF';
      final duration = request.barrageDuration ?? 6000;
      final speed = request.barrageSpeed ?? 120;
      final fontSize = request.barrageFontSize ?? 28;
      final lane = request.barrageLane?.value ?? 'top';
      final repeat = request.barrageRepeat ?? 1;
      final text = request.body.trim().isEmpty ? request.title : request.body;

      _logger.notification(
        'Barrage notification: ${request.title}',
        data: request.toJson(),
      );

      await _flashService.triggerFlash(
        color: color,
        duration: duration,
        effect: 'barrage',
        text: text,
        barrageSpeed: speed,
        barrageFontSize: fontSize,
        barrageLane: lane,
        barrageRepeat: repeat,
      );
    } catch (e) {
      _logger.error('Failed to trigger barrage: $e');
      rethrow;
    }
  }

  Future<void> _handleFlashNotification(NotificationRequest request) async {
    try {
      final color = request.flashColor ?? '#FF0000';
      final duration = request.flashDuration ?? 500;
      final effect = request.isEdgeFlash ? 'edge' : 'full';

      _logger.notification(
        'Flash notification: ${request.title}',
        data: request.toJson(),
      );

      await _flashService.triggerFlash(
        color: color,
        duration: duration,
        effect: effect,
        edgeWidth: request.edgeWidth,
        edgeOpacity: request.edgeOpacity,
        edgeRepeat: request.edgeRepeat,
      );
    } catch (e) {
      _logger.error('Failed to trigger flash: $e');
      rethrow;
    }
  }
}
