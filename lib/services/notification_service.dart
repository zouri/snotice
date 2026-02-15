import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../config/constants.dart';
import '../models/notification_request.dart';
import 'logger_service.dart';
import 'flash_overlay_service.dart';

class NotificationService {
  final LoggerService _logger;
  final FlashOverlayService _flashService;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService(this._logger, this._flashService);

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
    if (!request.isValid) {
      _logger.error('Invalid notification request: title or body is empty');
      return;
    }

    // 检测是否为 flash 类型
    if (request.category?.toLowerCase() == 'flash') {
      await _handleFlashNotification(request);
      return;
    }

    // 标准通知逻辑
    try {
      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
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

  Future<void> _handleFlashNotification(NotificationRequest request) async {
    try {
      final color = request.flashColor ?? '#FF0000';
      final duration = request.flashDuration ?? 500;

      _logger.notification(
        'Flash notification: ${request.title}',
        data: request.toJson(),
      );

      await _flashService.triggerFlash(color: color, duration: duration);
    } catch (e) {
      _logger.error('Failed to trigger flash: $e');
      rethrow;
    }
  }
}
