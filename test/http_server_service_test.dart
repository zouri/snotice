import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:snotice_new/models/app_config.dart';
import 'package:snotice_new/models/notification_request.dart';
import 'package:snotice_new/services/flash_overlay_service.dart';
import 'package:snotice_new/services/http_server_service.dart';
import 'package:snotice_new/services/logger_service.dart';
import 'package:snotice_new/services/notification_service.dart';

class _FakeNotificationService extends NotificationService {
  _FakeNotificationService(LoggerService logger)
    : super(logger, FlashOverlayService(logger));

  int callCount = 0;
  NotificationRequest? lastRequest;

  @override
  Future<void> showNotification(NotificationRequest request) async {
    callCount++;
    lastRequest = request;
  }
}

class _HttpResult {
  _HttpResult({required this.statusCode, required this.body});

  final int statusCode;
  final Map<String, dynamic> body;
}

Future<int> _reserveLocalPort() async {
  final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final port = socket.port;
  await socket.close();
  return port;
}

Future<_HttpResult> _postNotify({
  required int port,
  required String body,
  String contentType = 'application/json',
}) async {
  final client = HttpClient();
  try {
    final request = await client.post(
      InternetAddress.loopbackIPv4.host,
      port,
      '/api/notify',
    );
    request.headers.set(HttpHeaders.contentTypeHeader, contentType);
    request.write(body);

    final response = await request.close();
    final responseBody = await utf8.decoder.bind(response).join();

    return _HttpResult(
      statusCode: response.statusCode,
      body: jsonDecode(responseBody) as Map<String, dynamic>,
    );
  } finally {
    client.close(force: true);
  }
}

void main() {
  group('HttpServerService /api/notify validation', () {
    late LoggerService logger;
    late _FakeNotificationService notificationService;
    late HttpServerService serverService;
    late int port;

    setUp(() async {
      logger = LoggerService();
      notificationService = _FakeNotificationService(logger);
      port = await _reserveLocalPort();

      serverService = HttpServerService(
        notificationService: notificationService,
        logger: logger,
        config: AppConfig(port: port, allowedIPs: const ['127.0.0.1']),
      );

      await serverService.start();
    });

    tearDown(() async {
      if (serverService.isRunning) {
        await serverService.stop();
      }
    });

    test('returns 400 when body is not valid JSON', () async {
      final result = await _postNotify(port: port, body: '{"title":');

      expect(result.statusCode, 400);
      expect(result.body['success'], false);
      expect(result.body['error'], 'Request body must be valid JSON.');
      expect(notificationService.callCount, 0);
    });

    test('returns 400 when JSON body is not an object', () async {
      final result = await _postNotify(port: port, body: '["x"]');

      expect(result.statusCode, 400);
      expect(result.body['error'], 'Request body must be a JSON object.');
      expect(notificationService.callCount, 0);
    });

    test(
      'returns validation errors for non-flash request with empty body',
      () async {
        final result = await _postNotify(port: port, body: '{"title":"A"}');

        expect(result.statusCode, 400);
        expect(result.body['error'], 'Invalid notification request.');
        expect(
          result.body['validationErrors'],
          contains('Field "body" is required for non-flash notifications.'),
        );
        expect(notificationService.callCount, 0);
      },
    );

    test('returns validation errors for invalid enum values', () async {
      final result = await _postNotify(
        port: port,
        body: '{"title":"A","body":"B","priority":"urgent"}',
      );

      expect(result.statusCode, 400);
      expect(
        result.body['validationErrors'],
        contains('Field "priority" must be one of: low, normal, high.'),
      );
      expect(notificationService.callCount, 0);
    });

    test(
      'accepts flash request with empty body and forwards to service',
      () async {
        final result = await _postNotify(
          port: port,
          body:
              '{"title":"Flash","category":"flash","flashEffect":"edge","edgeWidth":6}',
        );

        expect(result.statusCode, 200);
        expect(result.body['success'], true);
        expect(notificationService.callCount, 1);
        expect(notificationService.lastRequest, isNotNull);
        expect(notificationService.lastRequest!.isFlash, isTrue);
      },
    );
  });
}
