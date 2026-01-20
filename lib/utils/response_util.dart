import 'dart:convert';
import 'package:shelf/shelf.dart';

class ResponseUtil {
  static Response success([Map<String, dynamic>? data]) {
    return Response.ok(
      jsonEncode(data ?? {'success': true}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Response badRequest(String message) {
    return Response(
      400,
      body: jsonEncode({'success': false, 'error': message}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Response unauthorized([String message = 'Unauthorized']) {
    return Response(
      401,
      body: jsonEncode({'success': false, 'error': message}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Response notFound([String message = 'Not found']) {
    return Response(
      404,
      body: jsonEncode({'success': false, 'error': message}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Response serverError([String message = 'Internal server error']) {
    return Response(
      500,
      body: jsonEncode({'success': false, 'error': message}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
