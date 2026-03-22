import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snotice_new/utils/color_value_utils.dart';

void main() {
  group('parseColorValue', () {
    test('parses 6-digit hex values', () {
      expect(parseColorValue('#12ABCD'), const Color(0xFF12ABCD));
    });

    test('parses named colors', () {
      expect(parseColorValue('red'), Colors.red);
      expect(parseColorValue('grey'), Colors.grey);
    });

    test('falls back for invalid values', () {
      expect(
        parseColorValue('not-a-color', fallback: Colors.cyan),
        Colors.cyan,
      );
    });
  });

  group('colorToHex', () {
    test('formats opaque colors as rgb hex', () {
      expect(colorToHex(const Color(0xFF12ABCD)), '#12ABCD');
    });

    test('includes alpha when requested', () {
      expect(
        colorToHex(const Color(0x8012ABCD), includeAlpha: true),
        '#8012ABCD',
      );
    });
  });
}
