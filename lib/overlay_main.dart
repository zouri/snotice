import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:window_manager/window_manager.dart';

/// 覆盖窗口入口函数
void overlayMain(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // 获取当前窗口控制器
  final controller = await WindowController.fromCurrentEngine();

  // 解析参数（JSON字符串）
  final arguments = _parseArguments(controller.arguments);

  final color = arguments['color'] ?? '#FF0000';
  final duration = arguments['duration'] ?? 500;

  // 配置窗口为全屏、透明、置顶
  await _configureOverlayWindow();

  runApp(FlashOverlayApp(color: color, duration: duration));
}

Map<String, dynamic> _parseArguments(String args) {
  if (args.isEmpty) return {};
  try {
    return jsonDecode(args) as Map<String, dynamic>;
  } catch (e) {
    return {};
  }
}

Future<void> _configureOverlayWindow() async {
  // 设置窗口选项
  const windowOptions = WindowOptions(
    size: Size(1920, 1080),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: true,
    titleBarStyle: TitleBarStyle.hidden,
    alwaysOnTop: true,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    // 显示窗口
    await windowManager.show();

    // 设置关键属性
    await windowManager.setOpacity(0.5); // 50% 透明度
    await windowManager.setSkipTaskbar(true);
    await windowManager.setAlwaysOnTop(true);

    // 设置为全屏
    await windowManager.setFullScreen(true);
  });
}

class FlashOverlayApp extends StatelessWidget {
  final String color;
  final int duration;

  const FlashOverlayApp({
    super.key,
    required this.color,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FlashOverlayScreen(color: color, duration: duration),
    );
  }
}

class FlashOverlayScreen extends StatefulWidget {
  final String color;
  final int duration;

  const FlashOverlayScreen({
    super.key,
    required this.color,
    required this.duration,
  });

  @override
  State<FlashOverlayScreen> createState() => _FlashOverlayScreenState();
}

class _FlashOverlayScreenState extends State<FlashOverlayScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Color _flashColor;

  @override
  void initState() {
    super.initState();

    _flashColor = _parseColor(widget.color);

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _startAnimation();
  }

  Color _parseColor(String colorString) {
    colorString = colorString.trim().toLowerCase();

    if (colorString.startsWith('#')) {
      return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
    } else if (colorString.startsWith('0x')) {
      return Color(int.parse(colorString));
    }

    switch (colorString) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.black;
      case 'gray':
      case 'grey':
        return Colors.grey;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'cyan':
        return Colors.cyan;
      default:
        return Colors.red;
    }
  }

  Future<void> _startAnimation() async {
    // 淡入
    await _controller.forward();

    // 保持显示
    await Future.delayed(Duration(milliseconds: widget.duration));

    // 淡出
    await _controller.reverse();

    // 关闭窗口
    try {
      await windowManager.close();
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) {
          return Container(
            color: _flashColor.withValues(alpha: _opacityAnimation.value),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
