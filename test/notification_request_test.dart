import 'package:flutter_test/flutter_test.dart';
import 'package:snotice_new/models/notification_request.dart';

void main() {
  group('NotificationRequest.fromJson', () {
    test('parses canonical fields', () {
      final request = NotificationRequest.fromJson({
        'title': 'Alert',
        'message': 'Body',
        'category': 'flash_edge',
        'flashColor': '#00FF00',
        'flashDuration': '700',
        'edgeWidth': '12.5',
        'edgeOpacity': 0.6,
        'edgeRepeat': 2.0,
        'payload': {1: 'one', 'ok': true},
      });

      expect(request.title, 'Alert');
      expect(request.message, 'Body');
      expect(request.category, NotificationCategory.flashEdge);
      expect(request.flashColor, '#00FF00');
      expect(request.flashDuration, 700);
      expect(request.edgeWidth, 12.5);
      expect(request.edgeOpacity, 0.6);
      expect(request.edgeRepeat, 2);
      expect(request.payload, {'1': 'one', 'ok': true});
      expect(request.isFlash, isTrue);
      expect(request.isEdgeFlash, isTrue);
      expect(request.isValid, isTrue);
    });

    test('parses body as compatibility alias', () {
      final request = NotificationRequest.fromJson({
        'title': 'Alert',
        'body': 'Body from alias',
      });

      expect(request.message, 'Body from alias');
    });

    test('does not parse unsupported legacy option aliases', () {
      final request = NotificationRequest.fromJson({
        'title': 'Alert',
        'message': 'Body from alias',
        'type': 'flash_edge',
        'color': '#00FF00',
        'duration': 700,
        'width': 12.5,
        'opacity': 0.6,
        'repeat': 2,
      });

      expect(request.category, isNull);
      expect(request.flashColor, isNull);
      expect(request.flashDuration, isNull);
      expect(request.edgeWidth, isNull);
      expect(request.edgeOpacity, isNull);
      expect(request.edgeRepeat, isNull);
    });

    test('uses defaults when optional fields are missing', () {
      final request = NotificationRequest.fromJson({
        'title': 'T',
        'message': 'B',
      });

      expect(request.priority, NotificationPriority.normal);
      expect(request.category, isNull);
      expect(request.payload, isNull);
      expect(request.isFlash, isFalse);
      expect(request.isValid, isTrue);
    });

    test('falls back to known defaults for unknown enum-like values', () {
      final request = NotificationRequest.fromJson({
        'title': 'T',
        'message': 'B',
        'priority': 'urgent',
        'category': 'custom',
      });

      expect(request.priority, NotificationPriority.normal);
      expect(request.category, isNull);
      expect(request.isFlash, isFalse);
      expect(
        request.validate(),
        contains('Field "priority" must be one of: low, normal, high.'),
      );
      expect(
        request.validate(),
        contains(
          'Field "category" must be one of: flash_full, flash_edge, barrage.',
        ),
      );
    });
  });

  group('NotificationRequest.validate', () {
    test('allows flash request with empty message', () {
      final request = NotificationRequest.fromJson({
        'title': 'Flash only',
        'category': 'flash_full',
      });

      expect(request.isFlash, isTrue);
      expect(request.validate(), isEmpty);
    });

    test('requires message for non-overlay notifications', () {
      final request = NotificationRequest.fromJson({
        'title': 'No message',
        'category': 'notice',
      });

      expect(
        request.validate(),
        contains('Field "message" is required for non-overlay notifications.'),
      );
    });

    test('allows barrage request with empty message', () {
      final request = NotificationRequest.fromJson({
        'title': 'Barrage only',
        'category': 'barrage',
      });

      expect(request.isBarrage, isTrue);
      expect(request.validate(), isEmpty);
    });

    test('validates barrageRepeat range', () {
      final tooSmall = NotificationRequest.fromJson({
        'title': 'Barrage',
        'category': 'barrage',
        'barrageRepeat': 0,
      });
      final tooLarge = NotificationRequest.fromJson({
        'title': 'Barrage',
        'category': 'barrage',
        'barrageRepeat': 99,
      });

      expect(
        tooSmall.validate(),
        contains('Field "barrageRepeat" must be greater than 0.'),
      );
      expect(
        tooLarge.validate(),
        contains(
          'Field "barrageRepeat" must be less than or equal to ${NotificationRequest.maxBarrageRepeat}.',
        ),
      );
    });

    test('requires flash_edge category when edge-only fields are provided', () {
      final request = NotificationRequest.fromJson({
        'title': 'T',
        'message': 'B',
        'edgeWidth': 8,
      });

      expect(
        request.validate(),
        contains(
          'edgeWidth/edgeOpacity/edgeRepeat require category=flash_edge.',
        ),
      );
    });
  });

  group('NotificationRequest immutability', () {
    test('payload map is unmodifiable', () {
      final request = NotificationRequest(
        title: 'T',
        message: 'B',
        payload: {'a': 1},
      );

      expect(() => request.payload!['b'] = 2, throwsUnsupportedError);
    });
  });

  group('NotificationRequest.toJson', () {
    test('always includes priority and excludes null optionals', () {
      final request = NotificationRequest(title: 'Title', message: 'Body');

      final json = request.toJson();
      expect(json['title'], 'Title');
      expect(json['message'], 'Body');
      expect(json['priority'], 'normal');
      expect(json.containsKey('category'), isFalse);
      expect(json.containsKey('payload'), isFalse);
    });
  });
}
