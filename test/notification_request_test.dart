import 'package:flutter_test/flutter_test.dart';
import 'package:snotice_new/models/notification_request.dart';

void main() {
  group('NotificationRequest.fromJson', () {
    test('parses canonical fields and aliases', () {
      final request = NotificationRequest.fromJson({
        'title': 'Alert',
        'message': 'Body from alias',
        'type': 'flash',
        'color': '#00FF00',
        'duration': '700',
        'effect': 'edge',
        'width': '12.5',
        'opacity': 0.6,
        'repeat': 2.0,
        'payload': {1: 'one', 'ok': true},
      });

      expect(request.title, 'Alert');
      expect(request.body, 'Body from alias');
      expect(request.category, NotificationCategory.flash);
      expect(request.flashColor, '#00FF00');
      expect(request.flashDuration, 700);
      expect(request.flashEffect, FlashEffect.edge);
      expect(request.edgeWidth, 12.5);
      expect(request.edgeOpacity, 0.6);
      expect(request.edgeRepeat, 2);
      expect(request.payload, {'1': 'one', 'ok': true});
      expect(request.isFlash, isTrue);
      expect(request.isValid, isTrue);
    });

    test('uses defaults when optional fields are missing', () {
      final request = NotificationRequest.fromJson({'title': 'T', 'body': 'B'});

      expect(request.priority, NotificationPriority.normal);
      expect(request.category, isNull);
      expect(request.payload, isNull);
      expect(request.isFlash, isFalse);
      expect(request.isValid, isTrue);
    });

    test('falls back to known defaults for unknown enum-like values', () {
      final request = NotificationRequest.fromJson({
        'title': 'T',
        'body': 'B',
        'priority': 'urgent',
        'category': 'custom',
        'flashEffect': 'glow',
      });

      expect(request.priority, NotificationPriority.normal);
      expect(request.category, isNull);
      expect(request.flashEffect, isNull);
      expect(request.isFlash, isFalse);
      expect(
        request.validate(),
        contains('Field "priority" must be one of: low, normal, high.'),
      );
      expect(request.validate(), contains('Field "category" must be: flash.'));
      expect(
        request.validate(),
        contains('Field "flashEffect" must be one of: full, edge.'),
      );
    });
  });

  group('NotificationRequest.validate', () {
    test('allows flash request with empty body', () {
      final request = NotificationRequest.fromJson({
        'title': 'Flash only',
        'category': 'flash',
      });

      expect(request.isFlash, isTrue);
      expect(request.validate(), isEmpty);
    });

    test('requires body for non-flash notifications', () {
      final request = NotificationRequest.fromJson({
        'title': 'No body',
        'category': 'notice',
      });

      expect(
        request.validate(),
        contains('Field "body" is required for non-flash notifications.'),
      );
    });

    test('requires edge effect when edge-only fields are provided', () {
      final request = NotificationRequest.fromJson({
        'title': 'T',
        'body': 'B',
        'edgeWidth': 8,
      });

      expect(
        request.validate(),
        contains('edgeWidth/edgeOpacity/edgeRepeat require flashEffect=edge.'),
      );
    });
  });

  group('NotificationRequest immutability', () {
    test('payload map is unmodifiable', () {
      final request = NotificationRequest(
        title: 'T',
        body: 'B',
        payload: {'a': 1},
      );

      expect(() => request.payload!['b'] = 2, throwsUnsupportedError);
    });
  });

  group('NotificationRequest.toJson', () {
    test('always includes priority and excludes null optionals', () {
      final request = NotificationRequest(title: 'Title', body: 'Body');

      final json = request.toJson();
      expect(json['title'], 'Title');
      expect(json['body'], 'Body');
      expect(json['priority'], 'normal');
      expect(json.containsKey('category'), isFalse);
      expect(json.containsKey('payload'), isFalse);
    });
  });
}
