import 'dart:convert';
import 'dart:math' as math;

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void overlayMain(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  final controller = await WindowController.fromCurrentEngine();
  final arguments = _parseArguments(controller.arguments);

  final effect = _parseString(arguments['effect'])?.toLowerCase() ?? 'full';
  final color = _parseString(arguments['color']) ?? '#FF0000';
  final duration = _parseInt(arguments['duration']) ?? 500;

  await _configureOverlayWindow(effect: effect);

  if (effect == 'barrage') {
    final text = _parseString(arguments['text'])?.trim() ?? '';
    final speed = _parseDouble(arguments['speed']) ?? 120;
    final fontSize = _parseDouble(arguments['fontSize']) ?? 28;
    final lane = _parseString(arguments['lane']) ?? 'top';

    runApp(
      BarrageOverlayApp(
        text: text.isEmpty ? 'SNotice' : text,
        color: color,
        duration: duration,
        speed: speed,
        fontSize: fontSize,
        lane: lane,
      ),
    );
    return;
  }

  runApp(FlashOverlayApp(color: color, duration: duration));
}

Map<String, dynamic> _parseArguments(String rawArguments) {
  if (rawArguments.isEmpty) {
    return {};
  }

  try {
    final decoded = jsonDecode(rawArguments);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
  } catch (_) {
    // Ignore invalid arguments.
  }
  return {};
}

int? _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim());
  }
  return null;
}

double? _parseDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value.trim());
  }
  return null;
}

String? _parseString(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  return value.toString();
}

Future<void> _configureOverlayWindow({required String effect}) async {
  const windowOptions = WindowOptions(
    backgroundColor: Colors.transparent,
    skipTaskbar: true,
    titleBarStyle: TitleBarStyle.hidden,
    alwaysOnTop: true,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setSkipTaskbar(true);
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setFullScreen(true);

    if (effect == 'barrage') {
      await windowManager.setOpacity(1.0);
      try {
        await windowManager.setIgnoreMouseEvents(true, forward: true);
      } catch (_) {
        await windowManager.setIgnoreMouseEvents(true);
      }
    } else {
      await windowManager.setOpacity(0.5);
      await windowManager.setIgnoreMouseEvents(false);
    }

    await windowManager.show();
  });
}

Color _parseColor(String colorString) {
  final normalized = colorString.trim().toLowerCase();

  if (normalized.startsWith('#')) {
    return Color(int.parse(normalized.substring(1), radix: 16) + 0xFF000000);
  }
  if (normalized.startsWith('0x')) {
    return Color(int.parse(normalized));
  }

  switch (normalized) {
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

class FlashOverlayApp extends StatelessWidget {
  const FlashOverlayApp({
    super.key,
    required this.color,
    required this.duration,
  });

  final String color;
  final int duration;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FlashOverlayScreen(color: color, duration: duration),
    );
  }
}

class FlashOverlayScreen extends StatefulWidget {
  const FlashOverlayScreen({
    super.key,
    required this.color,
    required this.duration,
  });

  final String color;
  final int duration;

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

  Future<void> _startAnimation() async {
    await _controller.forward();
    await Future.delayed(Duration(milliseconds: widget.duration));
    await _controller.reverse();
    await _closeOverlayWindow();
  }

  Future<void> _closeOverlayWindow() async {
    try {
      await windowManager.close();
    } catch (_) {
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

class BarrageOverlayApp extends StatelessWidget {
  const BarrageOverlayApp({
    super.key,
    required this.text,
    required this.color,
    required this.duration,
    required this.speed,
    required this.fontSize,
    required this.lane,
  });

  final String text;
  final String color;
  final int duration;
  final double speed;
  final double fontSize;
  final String lane;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BarrageOverlayScreen(
        text: text,
        color: color,
        duration: duration,
        speed: speed,
        fontSize: fontSize,
        lane: lane,
      ),
    );
  }
}

class BarrageOverlayScreen extends StatefulWidget {
  const BarrageOverlayScreen({
    super.key,
    required this.text,
    required this.color,
    required this.duration,
    required this.speed,
    required this.fontSize,
    required this.lane,
  });

  final String text;
  final String color;
  final int duration;
  final double speed;
  final double fontSize;
  final String lane;

  @override
  State<BarrageOverlayScreen> createState() => _BarrageOverlayScreenState();
}

class _BarrageOverlayScreenState extends State<BarrageOverlayScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Color _textColor;
  late final TextStyle _textStyle;
  bool _started = false;
  double _textWidth = 0;
  double _startX = 0;
  double _endX = 0;

  @override
  void initState() {
    super.initState();
    _textColor = _parseColor(widget.color);
    _textStyle = TextStyle(
      color: _textColor,
      fontSize: math.max(12, widget.fontSize),
      fontWeight: FontWeight.w700,
      height: 1.2,
      shadows: const [
        Shadow(color: Color(0xD9000000), blurRadius: 14, offset: Offset(0, 2)),
        Shadow(color: Color(0xB2000000), blurRadius: 5, offset: Offset(0, 0)),
      ],
    );
    _controller = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _startAnimation();
    });
  }

  Future<void> _startAnimation() async {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    _textWidth = _measureTextWidth(widget.text, _textStyle);
    _startX = screenWidth + 40;
    _endX = -_textWidth - 40;

    final distance = _startX - _endX;
    final speed = math.max(1.0, widget.speed);
    final travelMs = (distance / speed * 1000).round();
    final effectiveMs = math.max(widget.duration, travelMs);

    _controller.duration = Duration(milliseconds: effectiveMs);

    try {
      await _controller.forward(from: 0);
    } finally {
      await _closeOverlayWindow();
    }
  }

  double _measureTextWidth(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    return painter.width;
  }

  double _laneFactor() {
    switch (widget.lane.toLowerCase()) {
      case 'middle':
        return 0.5;
      case 'bottom':
        return 0.82;
      case 'top':
      default:
        return 0.18;
    }
  }

  Future<void> _closeOverlayWindow() async {
    try {
      await windowManager.close();
    } catch (_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IgnorePointer(
        ignoring: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final laneY = constraints.maxHeight * _laneFactor();
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final x = _startX + (_endX - _startX) * _controller.value;
                return Stack(
                  children: [
                    Positioned(
                      left: x,
                      top: laneY,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0x24000000),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0x33FFFFFF)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            widget.text,
                            style: _textStyle,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
