import 'package:flutter/material.dart';

const Map<String, Color> kNamedColors = {
  'red': Colors.red,
  'blue': Colors.blue,
  'green': Colors.green,
  'yellow': Colors.yellow,
  'white': Colors.white,
  'black': Colors.black,
  'gray': Colors.grey,
  'grey': Colors.grey,
  'orange': Colors.orange,
  'purple': Colors.purple,
  'pink': Colors.pink,
  'cyan': Colors.cyan,
};

Color parseColorValue(String source, {Color fallback = Colors.red}) {
  final normalized = source.trim().toLowerCase();
  if (normalized.isEmpty) {
    return fallback;
  }

  if (normalized.startsWith('#')) {
    final hex = normalized.substring(1);
    if (hex.length == 6) {
      final value = int.tryParse(hex, radix: 16);
      if (value != null) {
        return Color(value + 0xFF000000);
      }
    }
    if (hex.length == 8) {
      final value = int.tryParse(hex, radix: 16);
      if (value != null) {
        return Color(value);
      }
    }
  }

  if (normalized.startsWith('0x')) {
    final value = int.tryParse(normalized);
    if (value != null) {
      return Color(value);
    }
  }

  return kNamedColors[normalized] ?? fallback;
}

String colorToHex(Color color, {bool includeAlpha = false}) {
  final alpha = _channelToHex(color.a);
  final red = _channelToHex(color.r);
  final green = _channelToHex(color.g);
  final blue = _channelToHex(color.b);

  return includeAlpha ? '#$alpha$red$green$blue' : '#$red$green$blue';
}

String _channelToHex(double value) {
  final channel = (value * 255).round().clamp(0, 255);
  return channel.toRadixString(16).padLeft(2, '0').toUpperCase();
}
