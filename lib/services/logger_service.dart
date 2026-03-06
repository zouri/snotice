import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../models/log_entry.dart';
import '../config/constants.dart';

class LoggerService extends ChangeNotifier {
  final List<LogEntry> _logs = [];
  final int _maxLogEntries;

  LoggerService({int maxLogEntries = AppConstants.defaultMaxLogEntries})
    : _maxLogEntries = maxLogEntries;

  List<LogEntry> get logs => List.unmodifiable(_logs);

  void log(LogType type, String message, {Map<String, dynamic>? data}) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      type: type,
      message: message,
      data: data,
    );

    _logs.add(entry);

    if (_logs.length > _maxLogEntries) {
      _logs.removeAt(0);
    }

    developer.log(message, name: 'SNotice.${type.code}', time: entry.timestamp);
    notifyListeners();
  }

  void info(String message, {Map<String, dynamic>? data}) {
    log(LogType.info, message, data: data);
  }

  void error(String message, {Map<String, dynamic>? data}) {
    log(LogType.error, message, data: data);
  }

  void warning(String message, {Map<String, dynamic>? data}) {
    log(LogType.warning, message, data: data);
  }

  void debug(String message, {Map<String, dynamic>? data}) {
    log(LogType.debug, message, data: data);
  }

  void request(String message, {Map<String, dynamic>? data}) {
    log(LogType.request, message, data: data);
  }

  void notification(String message, {Map<String, dynamic>? data}) {
    log(LogType.notification, message, data: data);
  }

  void clear() {
    if (_logs.isEmpty) {
      return;
    }
    _logs.clear();
    notifyListeners();
  }
}
