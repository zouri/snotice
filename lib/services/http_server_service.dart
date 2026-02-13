import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import '../models/notification_request.dart';
import '../models/app_config.dart';
import 'notification_service.dart';
import 'logger_service.dart';
import '../utils/response_util.dart';

class HttpServerService {
  final NotificationService _notificationService;
  final LoggerService _logger;
  HttpServer? _server;
  DateTime? _startTime;
  AppConfig _config;

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
        ..post('/api/notify', _handleNotify)
        ..get('/api/status', _handleStatus)
        ..get('/api/config', _handleGetConfig)
        ..post('/api/config', _handleUpdateConfig)
        ..all('/<ignored|.*>', _handleNotFound);

      final handler = Pipeline()
          .addMiddleware(_corsMiddleware())
          .addMiddleware(_ipWhitelistMiddleware())
          .addHandler(router.call);

      _server = await shelf_io.serve(
        handler,
        InternetAddress.anyIPv4,
        _config.port,
      );

      _startTime = DateTime.now();
      _logger.info('Server started on port ${_config.port}');
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
    _startTime = null;
    _logger.info('Server stopped');
  }

  void updateConfig(AppConfig config) {
    _config = config;
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

  Middleware _ipWhitelistMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        final connectionInfo =
            request.context['shelf.io.connection_info'] as HttpConnectionInfo?;
        final ip = connectionInfo?.remoteAddress.address ?? 'unknown';

        if (!_config.isIPAllowed(ip)) {
          _logger.warning('Request from unauthorized IP: $ip');
          return ResponseUtil.unauthorized('IP not allowed');
        }

        return innerHandler(request);
      };
    };
  }

  Future<Response> _handleNotify(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body);
      final notificationRequest = NotificationRequest.fromJson(json);

      _logger.request('POST /api/notify', data: json);

      if (!notificationRequest.isValid) {
        return ResponseUtil.badRequest('Invalid notification request');
      }

      await _notificationService.showNotification(notificationRequest);

      return ResponseUtil.success({
        'success': true,
        'message': 'Notification sent',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.error('Error in /api/notify: $e');
      return ResponseUtil.serverError('Internal server error');
    }
  }

  Future<Response> _handleStatus(Request request) async {
    _logger.request('GET /api/status');

    return ResponseUtil.success({
      'running': isRunning,
      'port': _config.port,
      'uptime': _startTime != null
          ? DateTime.now().difference(_startTime!).inSeconds
          : 0,
    });
  }

  Future<Response> _handleGetConfig(Request request) async {
    _logger.request('GET /api/config');

    return ResponseUtil.success(_config.toJson());
  }

  Future<Response> _handleUpdateConfig(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body);

      _logger.request('POST /api/config', data: json);

      _config = AppConfig.fromJson(json);

      return ResponseUtil.success({
        'success': true,
        'message': 'Config updated',
        'config': _config.toJson(),
      });
    } catch (e) {
      _logger.error('Error in POST /api/config: $e');
      return ResponseUtil.badRequest('Invalid config data');
    }
  }

  Future<Response> _handleNotFound(Request request) async {
    _logger.request('${request.method} ${request.url.path}');
    return ResponseUtil.notFound('Endpoint not found');
  }
}
