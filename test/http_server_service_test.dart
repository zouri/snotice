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
  return _postPath(
    port: port,
    path: '/api/notify',
    body: body,
    contentType: contentType,
  );
}

Future<_HttpResult> _postPath({
  required int port,
  required String path,
  required String body,
  String contentType = 'application/json',
}) async {
  final client = HttpClient();
  try {
    final request = await client.post(
      InternetAddress.loopbackIPv4.host,
      port,
      path,
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

Future<_HttpResult> _getPath({required int port, required String path}) async {
  final client = HttpClient();
  try {
    final request = await client.get(
      InternetAddress.loopbackIPv4.host,
      port,
      path,
    );

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
        config: AppConfig(port: port),
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
          contains('Field "body" is required for non-overlay notifications.'),
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
          body: '{"title":"Flash","category":"flash_edge","edgeWidth":6}',
        );

        expect(result.statusCode, 200);
        expect(result.body['success'], true);
        expect(notificationService.callCount, 1);
        expect(notificationService.lastRequest, isNotNull);
        expect(notificationService.lastRequest!.isFlash, isTrue);
      },
    );

    test(
      'applies configured flash defaults when payload omits fields',
      () async {
        serverService.updateConfig(
          AppConfig(
            port: port,
            defaultFlashColor: '#12ABCD',
            defaultFlashDuration: 900,
            defaultFlashEdgeWidth: 16,
            defaultFlashEdgeOpacity: 0.75,
            defaultFlashEdgeRepeat: 4,
          ),
        );

        final result = await _postNotify(
          port: port,
          body: '{"title":"Flash","category":"flash_edge"}',
        );

        expect(result.statusCode, 200);
        expect(notificationService.callCount, 1);
        final request = notificationService.lastRequest!;
        expect(request.flashColor, '#12ABCD');
        expect(request.flashDuration, 900);
        expect(request.edgeWidth, 16);
        expect(request.edgeOpacity, 0.75);
        expect(request.edgeRepeat, 4);
      },
    );

    test('returns 403 when flash is disabled in config', () async {
      serverService.updateConfig(AppConfig(port: port, showFlash: false));

      final result = await _postNotify(
        port: port,
        body: '{"title":"Flash","category":"flash_full"}',
      );

      expect(result.statusCode, 403);
      expect(
        result.body['error'],
        'Flash notifications are disabled in current config.',
      );
      expect(notificationService.callCount, 0);
    });

    test(
      'accepts barrage request with empty body and forwards to service',
      () async {
        final result = await _postNotify(
          port: port,
          body: '{"title":"Barrage","category":"barrage","barrageSpeed":180}',
        );

        expect(result.statusCode, 200);
        expect(result.body['success'], true);
        expect(notificationService.callCount, 1);
        expect(notificationService.lastRequest, isNotNull);
        expect(notificationService.lastRequest!.isBarrage, isTrue);
      },
    );

    test(
      'applies configured barrage defaults when payload omits fields',
      () async {
        serverService.updateConfig(
          AppConfig(
            port: port,
            defaultBarrageColor: '#00FFAA',
            defaultBarrageDuration: 7777,
            defaultBarrageSpeed: 210,
            defaultBarrageFontSize: 32,
            defaultBarrageLane: 'bottom',
            defaultBarrageRepeat: 4,
          ),
        );

        final result = await _postNotify(
          port: port,
          body: '{"title":"Barrage","category":"barrage"}',
        );

        expect(result.statusCode, 200);
        expect(notificationService.callCount, 1);
        final request = notificationService.lastRequest!;
        expect(request.barrageColor, '#00FFAA');
        expect(request.barrageDuration, 7777);
        expect(request.barrageSpeed, 210);
        expect(request.barrageFontSize, 32);
        expect(request.barrageLane?.value, 'bottom');
        expect(request.barrageRepeat, 4);
      },
    );

    test('returns 403 when barrage is disabled in config', () async {
      serverService.updateConfig(AppConfig(port: port, showBarrage: false));

      final result = await _postNotify(
        port: port,
        body: '{"title":"Barrage","category":"barrage","body":"x"}',
      );

      expect(result.statusCode, 403);
      expect(
        result.body['error'],
        'Barrage notifications are disabled in current config.',
      );
      expect(notificationService.callCount, 0);
    });

    test('returns 404 for removed GET /api/status endpoint', () async {
      final result = await _getPath(port: port, path: '/api/status');

      expect(result.statusCode, 404);
      expect(result.body['success'], false);
    });
  });

  group('HttpServerService /api/mcp', () {
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
        config: AppConfig(port: port),
      );

      await serverService.start();
    });

    tearDown(() async {
      if (serverService.isRunning) {
        await serverService.stop();
      }
    });

    test('initialize returns MCP capabilities', () async {
      final result = await _postPath(
        port: port,
        path: '/api/mcp',
        body: jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'initialize',
          'params': {'protocolVersion': '2024-11-05'},
        }),
      );

      expect(result.statusCode, 200);
      expect(result.body['jsonrpc'], '2.0');
      expect(result.body['id'], 1);
      expect(result.body['result'], isA<Map<String, dynamic>>());
      expect(
        result.body['result']['capabilities']['tools']['listChanged'],
        false,
      );
    });

    test('tools/list contains built-in SNotice tools', () async {
      final result = await _postPath(
        port: port,
        path: '/api/mcp',
        body: jsonEncode({'jsonrpc': '2.0', 'id': 2, 'method': 'tools/list'}),
      );

      expect(result.statusCode, 200);
      final tools = result.body['result']['tools'] as List<dynamic>;
      final toolNames = tools
          .map((tool) => (tool as Map<String, dynamic>)['name'] as String)
          .toList();
      expect(toolNames, contains('snotice_send_notification'));
      expect(toolNames, contains('snotice_get_status'));
      expect(toolNames, contains('snotice_get_config'));
      expect(toolNames, contains('snotice_update_config'));
    });

    test(
      'tools/call can send notification via snotice_send_notification',
      () async {
        final result = await _postPath(
          port: port,
          path: '/api/mcp',
          body: jsonEncode({
            'jsonrpc': '2.0',
            'id': 3,
            'method': 'tools/call',
            'params': {
              'name': 'snotice_send_notification',
              'arguments': {'title': 'MCP', 'body': 'hello'},
            },
          }),
        );

        expect(result.statusCode, 200);
        expect(result.body['result']['isError'], false);
        expect(result.body['result']['structuredContent']['status'], 200);
        expect(notificationService.callCount, 1);
      },
    );

    test('tools/call returns error result for invalid args', () async {
      final result = await _postPath(
        port: port,
        path: '/api/mcp',
        body: jsonEncode({
          'jsonrpc': '2.0',
          'id': 4,
          'method': 'tools/call',
          'params': {
            'name': 'snotice_get_status',
            'arguments': {'unexpected': true},
          },
        }),
      );

      expect(result.statusCode, 200);
      expect(result.body['result']['isError'], true);
      final content = result.body['result']['content'] as List<dynamic>;
      final text = (content.first as Map<String, dynamic>)['text'] as String;
      expect(text, contains('does not accept arguments'));
    });
  });
}
