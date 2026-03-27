import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import '../models/app_config.dart';
import '../models/notification_request.dart';
import '../utils/response_util.dart';
import 'logger_service.dart';
import 'notification_service.dart';

class HttpServerService {
  static const String _mcpProtocolVersion = '2024-11-05';
  static const String _mcpServerName = 'snotice-http-mcp';
  static const String _mcpServerVersion = '0.1.0';

  final NotificationService _notificationService;
  final LoggerService _logger;
  final JsonEncoder _prettyJson = const JsonEncoder.withIndent('  ');
  HttpServer? _server;
  AppConfig _config;
  DateTime? _startedAt;

  HttpServerService({
    required NotificationService notificationService,
    required LoggerService logger,
    required AppConfig config,
  }) : _notificationService = notificationService,
       _logger = logger,
       _config = config;

  bool get isRunning => _server != null;
  int get port => _config.port;

  Future<void> start() async {
    if (_server != null) {
      _logger.warning('Server is already running on port ${_config.port}');
      return;
    }

    try {
      final router = Router()
        ..get('/api/status', _handleStatus)
        ..post('/api/notify', _handleNotify)
        ..post('/api/mcp', _handleMcp)
        ..all('/<ignored|.*>', _handleNotFound);

      final handler = Pipeline()
          .addMiddleware(_corsMiddleware())
          .addHandler(router.call);

      _server = await shelf_io.serve(
        handler,
        InternetAddress.anyIPv4,
        _config.port,
      );

      _logger.info('Server started on port ${_config.port}');
      _startedAt = DateTime.now();
    } catch (e) {
      _logger.error('Failed to start server: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    if (_server == null) {
      _logger.warning('Server is not running');
      return;
    }

    await _server!.close();
    _server = null;
    _startedAt = null;
    _logger.info('Server stopped');
  }

  void updateConfig(AppConfig config) {
    _config = config;
    _notificationService.updateConfig(config);
  }

  Middleware _corsMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        final response = await innerHandler(request);
        return response.change(
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
            ...response.headers,
          },
        );
      };
    };
  }

  Future<Response> _handleNotify(Request request) async {
    try {
      final body = await request.readAsString();
      final decoded = jsonDecode(body);
      final json = _asJsonObject(decoded);
      if (json == null) {
        return ResponseUtil.badRequest('Request body must be a JSON object.');
      }

      final result = await _processNotifyPayload(
        json,
        requestLabel: 'POST /api/notify',
      );
      return _jsonResponse(result.statusCode, result.body);
    } on FormatException {
      return ResponseUtil.badRequest('Request body must be valid JSON.');
    }
  }

  Future<Response> _handleStatus(Request request) async {
    _logger.request('GET /api/status');
    return _jsonResponse(200, _statusBody());
  }

  Future<Response> _handleMcp(Request request) async {
    try {
      final body = await request.readAsString();
      final decoded = jsonDecode(body);
      final json = _asJsonObject(decoded);
      if (json == null) {
        return ResponseUtil.badRequest('Request body must be a JSON object.');
      }

      _logger.request('POST /api/mcp', data: json);
      final rpcResponse = await _handleMcpRequest(json);
      if (rpcResponse == null) {
        return Response(204);
      }

      return _jsonResponse(200, rpcResponse);
    } on FormatException {
      return ResponseUtil.badRequest('Request body must be valid JSON.');
    } catch (e) {
      _logger.error('Error in POST /api/mcp: $e');
      return ResponseUtil.serverError('Internal server error');
    }
  }

  Future<Map<String, dynamic>?> _handleMcpRequest(
    Map<String, dynamic> message,
  ) async {
    final id = message['id'];
    final method = message['method'];

    if (method is! String) {
      return _mcpError(id, -32600, 'Invalid Request');
    }

    final paramsValue = message['params'];
    Map<String, dynamic> params = <String, dynamic>{};
    if (paramsValue != null) {
      final paramsJson = _asJsonObject(paramsValue);
      if (paramsJson == null) {
        return _mcpError(id, -32602, 'Invalid params: expected object.');
      }
      params = paramsJson;
    }

    switch (method) {
      case 'initialize':
        if (id == null) {
          return _mcpError(
            null,
            -32600,
            'Request id is required for initialize.',
          );
        }
        final requestedProtocol = params['protocolVersion'];
        final protocolVersion =
            requestedProtocol is String && requestedProtocol.trim().isNotEmpty
            ? requestedProtocol
            : _mcpProtocolVersion;

        return _mcpResult(id, {
          'protocolVersion': protocolVersion,
          'capabilities': {
            'tools': {'listChanged': false},
          },
          'serverInfo': {'name': _mcpServerName, 'version': _mcpServerVersion},
          'instructions':
              'Call SNotice tools via tools/list and tools/call over /api/mcp.',
        });

      case 'notifications/initialized':
        if (id == null) {
          return null;
        }
        return _mcpResult(id, {});

      case 'ping':
        if (id == null) {
          return null;
        }
        return _mcpResult(id, {});

      case 'tools/list':
        if (id == null) {
          return _mcpError(
            null,
            -32600,
            'Request id is required for tools/list.',
          );
        }
        return _mcpResult(id, {'tools': _mcpTools()});

      case 'tools/call':
        if (id == null) {
          return _mcpError(
            null,
            -32600,
            'Request id is required for tools/call.',
          );
        }
        return _handleMcpToolCall(id, params);

      default:
        return _mcpError(id, -32601, 'Method not found: $method');
    }
  }

  Future<Map<String, dynamic>> _handleMcpToolCall(
    dynamic id,
    Map<String, dynamic> params,
  ) async {
    final name = params['name'];
    if (name is! String || name.trim().isEmpty) {
      return _mcpError(id, -32602, 'tools/call requires string field "name".');
    }

    final argumentsValue = params['arguments'];
    Map<String, dynamic> arguments = <String, dynamic>{};
    if (argumentsValue != null) {
      final argumentsJson = _asJsonObject(argumentsValue);
      if (argumentsJson == null) {
        return _mcpError(
          id,
          -32602,
          'tools/call field "arguments" must be an object.',
        );
      }
      arguments = argumentsJson;
    }

    switch (name) {
      case 'snotice_send_notification':
        final payload = Map<String, dynamic>.from(arguments);
        if (!payload.containsKey('message') && payload.containsKey('body')) {
          payload['message'] = payload['body'];
        }
        if (!payload.containsKey('message')) {
          payload['message'] = '';
        }
        final notifyResult = await _processNotifyPayload(
          payload,
          requestLabel: 'MCP tools/call snotice_send_notification',
        );
        return _mcpResult(
          id,
          _mcpToolResult('snotice_send_notification', notifyResult),
        );
      case 'snotice_get_status':
        return _mcpResult(
          id,
          _mcpToolResult(
            'snotice_get_status',
            _ServiceCallResult(200, _statusBody()),
          ),
        );
      case 'snotice_get_config':
        return _mcpResult(
          id,
          _mcpToolResult(
            'snotice_get_config',
            _ServiceCallResult(200, {
              'success': true,
              'config': _config.toJson(),
            }),
          ),
        );

      default:
        return _mcpError(id, -32601, 'Unknown tool: $name');
    }
  }

  List<Map<String, dynamic>> _mcpTools() {
    return [
      {
        'name': 'snotice_send_notification',
        'description': 'Send one desktop notification via SNotice.',
        'inputSchema': {
          'type': 'object',
          'properties': {
            'title': {'type': 'string'},
            'message': {'type': 'string'},
            'priority': {
              'type': 'string',
              'enum': ['low', 'normal', 'high'],
              'default': 'normal',
            },
            'category': {
              'type': 'string',
              'enum': ['flash_full', 'flash_edge', 'barrage'],
            },
            'flashColor': {'type': 'string'},
            'flashDuration': {'type': 'integer', 'minimum': 1},
            'edgeWidth': {'type': 'number', 'exclusiveMinimum': 0},
            'edgeOpacity': {'type': 'number', 'minimum': 0, 'maximum': 1},
            'edgeRepeat': {'type': 'integer', 'minimum': 1},
            'barrageColor': {'type': 'string'},
            'barrageDuration': {'type': 'integer', 'minimum': 1},
            'barrageSpeed': {'type': 'number', 'exclusiveMinimum': 0},
            'barrageFontSize': {'type': 'number', 'exclusiveMinimum': 0},
            'barrageLane': {
              'type': 'string',
              'enum': ['top', 'middle', 'bottom'],
            },
            'barrageRepeat': {'type': 'integer', 'minimum': 1, 'maximum': 8},
            'icon': {'type': 'string'},
            'payload': {'type': 'object'},
          },
          'required': ['title'],
          'additionalProperties': false,
        },
      },
      {
        'name': 'snotice_get_status',
        'description': 'Read server status, port, and uptime.',
        'inputSchema': {
          'type': 'object',
          'properties': {},
          'additionalProperties': false,
        },
      },
      {
        'name': 'snotice_get_config',
        'description': 'Read the current SNotice configuration.',
        'inputSchema': {
          'type': 'object',
          'properties': {},
          'additionalProperties': false,
        },
      },
    ];
  }

  Map<String, dynamic> _statusBody() {
    final startedAt = _startedAt;
    final uptimeSeconds = startedAt == null
        ? 0
        : DateTime.now().difference(startedAt).inSeconds;

    return {
      'success': true,
      'running': isRunning,
      'port': _config.port,
      'uptimeSeconds': uptimeSeconds,
      if (startedAt != null) 'startedAt': startedAt.toIso8601String(),
    };
  }

  Future<_ServiceCallResult> _processNotifyPayload(
    Map<String, dynamic> json, {
    required String requestLabel,
  }) async {
    try {
      final normalizedPayload = Map<String, dynamic>.from(json);
      _applyFlashDefaults(normalizedPayload);
      _applyBarrageDefaults(normalizedPayload);
      final notificationRequest = NotificationRequest.fromJson(
        normalizedPayload,
      );
      _logger.request(requestLabel, data: normalizedPayload);

      final validationErrors = notificationRequest.validate();
      if (validationErrors.isNotEmpty) {
        return _ServiceCallResult(400, {
          'success': false,
          'error': 'Invalid notification request.',
          'validationErrors': validationErrors,
        });
      }

      if (notificationRequest.isFlash && !_config.showFlash) {
        return _ServiceCallResult(403, {
          'success': false,
          'error': 'Flash notifications are disabled in current config.',
        });
      }

      if (notificationRequest.isBarrage && !_config.showBarrage) {
        return _ServiceCallResult(403, {
          'success': false,
          'error': 'Barrage notifications are disabled in current config.',
        });
      }

      await _notificationService.showNotification(notificationRequest);

      return _ServiceCallResult(200, {
        'success': true,
        'message': 'Notification sent',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.error('Error in $requestLabel: $e');
      return _ServiceCallResult(500, {
        'success': false,
        'error': 'Internal server error',
      });
    }
  }

  void _applyBarrageDefaults(Map<String, dynamic> payload) {
    final rawCategory = payload['category'];
    final category = rawCategory?.toString().trim().toLowerCase();
    if (category != NotificationCategory.barrage.value) {
      return;
    }

    payload.putIfAbsent('barrageColor', () => _config.defaultBarrageColor);
    payload.putIfAbsent(
      'barrageDuration',
      () => _config.defaultBarrageDuration,
    );
    payload.putIfAbsent('barrageSpeed', () => _config.defaultBarrageSpeed);
    payload.putIfAbsent(
      'barrageFontSize',
      () => _config.defaultBarrageFontSize,
    );
    payload.putIfAbsent('barrageLane', () => _config.defaultBarrageLane);
    payload.putIfAbsent('barrageRepeat', () => _config.defaultBarrageRepeat);
  }

  void _applyFlashDefaults(Map<String, dynamic> payload) {
    final rawCategory = payload['category'];
    final category = rawCategory?.toString().trim().toLowerCase();
    if (category != NotificationCategory.flashFull.value &&
        category != NotificationCategory.flashEdge.value) {
      return;
    }

    payload.putIfAbsent('flashColor', () => _config.defaultFlashColor);
    payload.putIfAbsent('flashDuration', () => _config.defaultFlashDuration);

    if (category == NotificationCategory.flashEdge.value) {
      payload.putIfAbsent('edgeWidth', () => _config.defaultFlashEdgeWidth);
      payload.putIfAbsent('edgeOpacity', () => _config.defaultFlashEdgeOpacity);
      payload.putIfAbsent('edgeRepeat', () => _config.defaultFlashEdgeRepeat);
    }
  }

  Map<String, dynamic> _mcpResult(dynamic id, Map<String, dynamic> result) {
    return {'jsonrpc': '2.0', 'id': id, 'result': result};
  }

  Map<String, dynamic> _mcpError(dynamic id, int code, String message) {
    return {
      'jsonrpc': '2.0',
      'id': id,
      'error': {'code': code, 'message': message},
    };
  }

  Map<String, dynamic> _mcpToolResult(
    String toolName,
    _ServiceCallResult result,
  ) {
    final prettyBody = _prettyJson.convert(result.body);
    final text = '$toolName -> HTTP ${result.statusCode}\n$prettyBody';

    return {
      'content': [
        {'type': 'text', 'text': text},
      ],
      'structuredContent': {'status': result.statusCode, 'body': result.body},
      'isError': result.statusCode < 200 || result.statusCode >= 300,
    };
  }

  Response _jsonResponse(int statusCode, Map<String, dynamic> body) {
    return Response(
      statusCode,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Map<String, dynamic>? _asJsonObject(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  Future<Response> _handleNotFound(Request request) async {
    _logger.request('${request.method} ${request.url.path}');
    return ResponseUtil.notFound('Endpoint not found');
  }
}

class _ServiceCallResult {
  const _ServiceCallResult(this.statusCode, this.body);

  final int statusCode;
  final Map<String, dynamic> body;
}
