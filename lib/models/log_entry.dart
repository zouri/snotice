enum LogType {
  request,
  info,
  notification,
  warning,
  error,
  debug;

  String get code {
    switch (this) {
      case LogType.request:
        return 'REQUEST';
      case LogType.info:
        return 'INFO';
      case LogType.notification:
        return 'NOTIFICATION';
      case LogType.warning:
        return 'WARNING';
      case LogType.error:
        return 'ERROR';
      case LogType.debug:
        return 'DEBUG';
    }
  }
}

class LogEntry {
  final DateTime timestamp;
  final LogType type;
  final String message;
  final Map<String, dynamic>? data;

  LogEntry({
    required this.timestamp,
    required this.type,
    required this.message,
    this.data,
  });
}
