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
    final repeat = _parseInt(arguments['repeat']) ?? 1;

    runApp(
      BarrageOverlayApp(
        text: text.isEmpty ? 'SNotice' : text,
        color: color,
        duration: duration,
        speed: speed,
        fontSize: fontSize,
        lane: lane,
        repeat: repeat,
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
    required this.repeat,
  });

  final String text;
  final String color;
  final int duration;
  final double speed;
  final double fontSize;
  final String lane;
  final int repeat;

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
        repeat: repeat,
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
    required this.repeat,
  });

  final String text;
  final String color;
  final int duration;
  final double speed;
  final double fontSize;
  final String lane;
  final int repeat;

  @override
  State<BarrageOverlayScreen> createState() => _BarrageOverlayScreenState();
}

class _BarrageOverlayScreenState extends State<BarrageOverlayScreen>
    with SingleTickerProviderStateMixin {
  static const int _maxBarrageRepeat = 8;

  late final AnimationController _controller;
  late final Color _textColor;
  late final TextStyle _textStyle;
  bool _started = false;
  double _textWidth = 0;
  double _startX = 0;
  double _endX = 0;
  int _repeatCount = 1;
  double _itemHeight = 48;
  double _rowSpacing = 60;
  double _devicePixelRatio = 1.0;
  final math.Random _random = math.Random();
  List<_BarrageItemLayout> _barrageItems = <_BarrageItemLayout>[];
  List<Widget> _barrageBubbles = <Widget>[];

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
        Shadow(color: Color(0x80000000), blurRadius: 8, offset: Offset(0, 1)),
        Shadow(color: Color(0x4D000000), blurRadius: 3, offset: Offset(0, 0)),
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
    final screenHeight = media.size.height;
    _devicePixelRatio = media.devicePixelRatio;
    _textWidth = _measureTextWidth(widget.text, _textStyle);
    final textHeight = _measureTextHeight(widget.text, _textStyle);
    _itemHeight = textHeight;
    _rowSpacing = _resolveRowSpacing(_itemHeight);
    _repeatCount = widget.repeat <= 0
        ? 1
        : math.min(widget.repeat, _maxBarrageRepeat);
    _startX = screenWidth + 40;
    _endX = -_textWidth - 60;

    final laneY = screenHeight * _laneFactor();
    final rowTops = _buildRandomRowTops(laneY: laneY, maxHeight: screenHeight);
    _barrageItems = List<_BarrageItemLayout>.generate(_repeatCount, (index) {
      return _BarrageItemLayout(
        rowTop: rowTops[index],
        spawnOffsetX: _randomBetween(-screenWidth * 0.18, screenWidth * 0.35),
        endExtra: _randomBetween(0, screenWidth * 0.2),
        initialProgress: _randomBetween(0.06, 0.42),
        speedFactor: _randomBetween(0.82, 1.2),
      );
    });
    _barrageBubbles = List<Widget>.generate(
      _repeatCount,
      (index) => RepaintBoundary(
        key: ValueKey<String>('barrage-bubble-$index'),
        child: _BarrageBubble(text: widget.text, textStyle: _textStyle),
      ),
    );

    final farthestStartX = _startX + screenWidth * 0.35;
    final farthestEndX = _endX - screenWidth * 0.2;
    final distance = farthestStartX - farthestEndX;
    final speed = math.max(1.0, widget.speed) * 0.82;
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

  double _measureTextHeight(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    return painter.height;
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

  double _resolveRowSpacing(double itemHeight) {
    return math.max(36.0, math.min(120.0, itemHeight + 12.0));
  }

  List<double> _buildRandomRowTops({
    required double laneY,
    required double maxHeight,
  }) {
    final rows = List<double>.generate(_repeatCount, (index) {
      final lane = widget.lane.toLowerCase();
      final rawTop = switch (lane) {
        'bottom' => laneY - index * _rowSpacing,
        'middle' => laneY + _middleSignedStep(index) * _rowSpacing,
        _ => laneY + index * _rowSpacing,
      };
      final jitter = _randomBetween(-_rowSpacing * 0.35, _rowSpacing * 0.35);
      return _clampTop(rawTop + jitter, maxHeight);
    });
    rows.shuffle(_random);
    return rows;
  }

  double _middleSignedStep(int index) {
    if (index == 0) {
      return 0;
    }
    final level = ((index + 1) / 2).floorToDouble();
    return index.isOdd ? level : -level;
  }

  double _clampTop(double top, double maxHeight) {
    final maxTop = math.max(0.0, maxHeight - _itemHeight);
    return top.clamp(0.0, maxTop);
  }

  double _randomBetween(double min, double max) {
    return min + _random.nextDouble() * (max - min);
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
            final fallbackTop = _clampTop(
              constraints.maxHeight * _laneFactor(),
              constraints.maxHeight,
            );
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final items = _barrageItems.isEmpty
                    ? <_BarrageItemLayout>[
                        const _BarrageItemLayout(
                          rowTop: 0,
                          spawnOffsetX: 0,
                          endExtra: 0,
                          initialProgress: 0,
                          speedFactor: 1,
                        ),
                      ]
                    : _barrageItems;
                final barrageItems = List<Widget>.generate(items.length, (
                  index,
                ) {
                  final item = items[index];
                  final rowTop = _barrageItems.isEmpty
                      ? fallbackTop
                      : _clampTop(item.rowTop, constraints.maxHeight);
                  final startX = _startX + item.spawnOffsetX;
                  final endX = _endX - item.endExtra;
                  final baseProgress =
                      item.initialProgress +
                      (1 - item.initialProgress) * _controller.value;
                  final easedProgress =
                      1 -
                      math.pow(1 - baseProgress, item.speedFactor).toDouble();
                  final x = startX + (endX - startX) * easedProgress;
                  final alignedX = _alignToPixel(x, _devicePixelRatio);
                  final alignedTop = _alignToPixel(rowTop, _devicePixelRatio);
                  return Positioned(
                    left: alignedX,
                    top: alignedTop,
                    child: _barrageBubbles[index],
                  );
                });
                return Stack(children: barrageItems);
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

  double _alignToPixel(double value, double devicePixelRatio) {
    assert(devicePixelRatio > 0, 'devicePixelRatio must be positive');
    return (value * devicePixelRatio).roundToDouble() / devicePixelRatio;
  }
}

class _BarrageItemLayout {
  const _BarrageItemLayout({
    required this.rowTop,
    required this.spawnOffsetX,
    required this.endExtra,
    required this.initialProgress,
    required this.speedFactor,
  });

  final double rowTop;
  final double spawnOffsetX;
  final double endExtra;
  final double initialProgress;
  final double speedFactor;
}

class _BarrageBubble extends StatelessWidget {
  const _BarrageBubble({required this.text, required this.textStyle});

  final String text;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x24000000),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(text, style: textStyle, maxLines: 1),
      ),
    );
  }
}
