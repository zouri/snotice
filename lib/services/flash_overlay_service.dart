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
  /// - text: 弹幕文本（仅 effect=barrage 生效）
  /// - barrageSpeed: 弹幕速度 px/s（仅 effect=barrage 生效）
  /// - barrageFontSize: 弹幕字号（仅 effect=barrage 生效）
  /// - barrageLane: 弹幕轨道 top/middle/bottom（仅 effect=barrage 生效）
  Future<void> triggerFlash({
    required String color,
    int duration = 500,
    String effect = 'full',
    double? edgeWidth,
    double? edgeOpacity,
    int? edgeRepeat,
    String? text,
    double? barrageSpeed,
    double? barrageFontSize,
    String? barrageLane,
  }) async {
    try {
      _logger.info(
        'Creating flash overlay: effect=$effect, color=$color, duration=$duration',
      );

      final shouldUseNativeFlash = Platform.isMacOS;
      if (shouldUseNativeFlash) {
        final payload = <String, dynamic>{
          'color': color,
          'duration': duration,
          'effect': effect,
        };
        if (edgeWidth != null) payload['width'] = edgeWidth;
        if (edgeOpacity != null) payload['opacity'] = edgeOpacity;
        if (edgeRepeat != null) payload['repeat'] = edgeRepeat;
        if (text != null) payload['text'] = text;
        if (barrageSpeed != null) payload['speed'] = barrageSpeed;
        if (barrageFontSize != null) payload['fontSize'] = barrageFontSize;
        if (barrageLane != null) payload['lane'] = barrageLane;

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
        if (text != null) 'text': text,
        if (barrageSpeed != null) 'speed': barrageSpeed,
        if (barrageFontSize != null) 'fontSize': barrageFontSize,
        if (barrageLane != null) 'lane': barrageLane,
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
