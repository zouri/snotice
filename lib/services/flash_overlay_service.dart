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
  /// - effect: full(全屏) 或 edge(边缘发光)，由 category 映射得到
  /// - edgeWidth: 边缘发光宽度（仅 effect=edge 生效）
  /// - edgeOpacity: 边缘发光透明度（仅 effect=edge 生效）
  /// - edgeRepeat: 边缘发光重复次数（仅 effect=edge 生效）
  Future<void> triggerFlash({
    required String color,
    int duration = 500,
    String effect = 'full',
    double? edgeWidth,
    double? edgeOpacity,
    int? edgeRepeat,
  }) async {
    try {
      _logger.info(
        'Creating flash overlay: effect=$effect, color=$color, duration=$duration',
      );

      if (Platform.isMacOS) {
        final payload = <String, dynamic>{
          'color': color,
          'duration': duration,
          'effect': effect,
        };
        if (edgeWidth != null) payload['width'] = edgeWidth;
        if (edgeOpacity != null) payload['opacity'] = edgeOpacity;
        if (edgeRepeat != null) payload['repeat'] = edgeRepeat;

        await _flashChannel.invokeMethod('triggerFlash', payload);
        _logger.info('Flash overlay created successfully');
        return;
      }

      // 创建参数（JSON字符串）
      final arguments = jsonEncode({
        'windowType': 'flash',
        'color': color,
        'duration': duration,
        'effect': effect,
        if (edgeWidth != null) 'width': edgeWidth,
        if (edgeOpacity != null) 'opacity': edgeOpacity,
        if (edgeRepeat != null) 'repeat': edgeRepeat,
      });

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
