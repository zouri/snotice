import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'logger_service.dart';

/// 闪烁覆盖窗口服务
/// 负责创建和管理全屏透明覆盖窗口
class FlashOverlayService {
  final LoggerService _logger;
  static const MethodChannel _flashChannel = MethodChannel('snotice/flash');

  FlashOverlayService(this._logger);

  /// 触发全屏闪烁覆盖
  ///
  /// 参数:
  /// - color: 闪烁颜色，支持十六进制（"#FF0000"）或颜色名称（"red"")
  /// - duration: 闪烁持续时间（毫秒），默认 500ms
  Future<void> triggerFlash({required String color, int duration = 500}) async {
    try {
      _logger.info('Creating flash overlay: color=$color, duration=$duration');

      if (Platform.isMacOS) {
        await _flashChannel.invokeMethod('triggerFlash', {
          'color': color,
          'duration': duration,
        });
        _logger.info('Flash overlay created successfully');
        return;
      }

      // 创建参数（JSON字符串）
      final arguments = jsonEncode({'color': color, 'duration': duration});

      // 创建新窗口（隐藏启动，稍后配置）
      final controller = await WindowController.create(
        WindowConfiguration(hiddenAtLaunch: true, arguments: arguments),
      );

      // 显示窗口
      await controller.show();

      _logger.info('Flash overlay created successfully');
    } catch (e) {
      _logger.error('Failed to create flash overlay: $e');
      rethrow;
    }
  }
}
