import '../models/log_entry.dart';
import '../config/constants.dart';

class LoggerService {
  final List<LogEntry> _logs = [];
  final int _maxLogEntries;

  LoggerService({int maxLogEntries = AppConstants.defaultMaxLogEntries})
    : _maxLogEntries = maxLogEntries;

  List<LogEntry> get logs => List.unmodifiable(_logs);

  void log(String type, String message, {Map<String, dynamic>? data}) {
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

    print('[${entry.timestamp.toIso8601String()}] [$type] $message');
  }

  void info(String message, {Map<String, dynamic>? data}) {
    log('INFO', message, data: data);
  }

  void error(String message, {Map<String, dynamic>? data}) {
    log('ERROR', message, data: data);
  }

  void warning(String message, {Map<String, dynamic>? data}) {
    log('WARNING', message, data: data);
  }

  void request(String message, {Map<String, dynamic>? data}) {
    log('REQUEST', message, data: data);
  }

  void notification(String message, {Map<String, dynamic>? data}) {
    log('NOTIFICATION', message, data: data);
  }

  void clear() {
    _logs.clear();
  }

  List<LogEntry> filterByType(String type) {
    return _logs.where((log) => log.type == type).toList();
  }

  List<LogEntry> filterByDateRange(DateTime start, DateTime end) {
    return _logs
        .where(
          (log) => log.timestamp.isAfter(start) && log.timestamp.isBefore(end),
        )
        .toList();
  }
}
