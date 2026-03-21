import 'package:flutter_test/flutter_test.dart';
import 'package:snotice_new/models/app_config.dart';

void main() {
  group('AppConfig flash defaults', () {
    test('normalizes invalid flash default values', () {
      final config = AppConfig(
        defaultFlashColor: ' ',
        defaultFlashDuration: -1,
        defaultFlashEdgeWidth: 0,
        defaultFlashEdgeOpacity: 2,
        defaultFlashEdgeRepeat: 0,
      );

      expect(config.defaultFlashColor, '#FF0000');
      expect(config.defaultFlashDuration, 500);
      expect(config.defaultFlashEdgeWidth, 12);
      expect(config.defaultFlashEdgeOpacity, 0.92);
      expect(config.defaultFlashEdgeRepeat, 2);
    });

    test('parses flash defaults from json', () {
      final config = AppConfig.fromJson({
        'defaultFlashColor': '#12ABCD',
        'defaultFlashDuration': '900',
        'defaultFlashEdgeWidth': '16.5',
        'defaultFlashEdgeOpacity': '0.75',
        'defaultFlashEdgeRepeat': '4',
      });

      expect(config.defaultFlashColor, '#12ABCD');
      expect(config.defaultFlashDuration, 900);
      expect(config.defaultFlashEdgeWidth, 16.5);
      expect(config.defaultFlashEdgeOpacity, 0.75);
      expect(config.defaultFlashEdgeRepeat, 4);
    });
  });

  group('AppConfig barrage defaults', () {
    test('normalizes invalid barrage default values', () {
      final config = AppConfig(
        defaultBarrageColor: ' ',
        defaultBarrageDuration: -1,
        defaultBarrageSpeed: 0,
        defaultBarrageFontSize: -8,
        defaultBarrageLane: 'unknown',
        defaultBarrageRepeat: 0,
      );

      expect(config.defaultBarrageColor, '#FFD84D');
      expect(config.defaultBarrageDuration, 6000);
      expect(config.defaultBarrageSpeed, 120);
      expect(config.defaultBarrageFontSize, 28);
      expect(config.defaultBarrageLane, 'top');
      expect(config.defaultBarrageRepeat, 1);
    });

    test('parses barrage defaults from json', () {
      final config = AppConfig.fromJson({
        'defaultBarrageColor': '#AABBCC',
        'defaultBarrageDuration': '7500',
        'defaultBarrageSpeed': '150.5',
        'defaultBarrageFontSize': 30,
        'defaultBarrageLane': 'middle',
        'defaultBarrageRepeat': '3',
        'showBarrage': false,
      });

      expect(config.defaultBarrageColor, '#AABBCC');
      expect(config.defaultBarrageDuration, 7500);
      expect(config.defaultBarrageSpeed, 150.5);
      expect(config.defaultBarrageFontSize, 30);
      expect(config.defaultBarrageLane, 'middle');
      expect(config.defaultBarrageRepeat, 3);
      expect(config.showBarrage, false);
    });
  });

  group('AppConfig compatibility', () {
    test('ignores legacy allowedIPs values when loading old config', () {
      final config = AppConfig.fromJson({
        'port': 9999,
        'allowedIPs': ['127.0.0.1', '192.168.1.0/24'],
        'showNotifications': false,
      });

      expect(config.port, 9999);
      expect(config.showNotifications, false);
      expect(config.toJson().containsKey('allowedIPs'), false);
      expect(config.toJson().containsKey('defaultFlashColor'), true);
    });

    test('parses and serializes reminder mode toggles', () {
      final config = AppConfig.fromJson({
        'showFlash': false,
        'showBarrage': false,
        'showSound': false,
      });

      expect(config.showFlash, false);
      expect(config.showBarrage, false);
      expect(config.showSound, false);
      expect(config.toJson()['showFlash'], false);
      expect(config.toJson()['showBarrage'], false);
      expect(config.toJson()['showSound'], false);
    });
  });

  group('AppConfig auto-launch-on-login', () {
    test('parses and serializes autoLaunchOnLogin', () {
      final config = AppConfig.fromJson({'autoLaunchOnLogin': 'true'});

      expect(config.autoLaunchOnLogin, true);
      expect(config.toJson()['autoLaunchOnLogin'], true);
    });
  });
}
