import 'package:flutter/foundation.dart';
import '../models/log_entry.dart';
import '../services/logger_service.dart';

class LogProvider with ChangeNotifier {
  final LoggerService _loggerService;

  LogProvider(this._loggerService);

  List<LogEntry> get logs => _loggerService.logs;

  void addLog(String type, String message, {Map<String, dynamic>? data}) {
    _loggerService.log(type, message, data: data);
    notifyListeners();
  }

  void clearLogs() {
    _loggerService.clear();
    notifyListeners();
  }

  List<LogEntry> filterByType(String type) {
    return _loggerService.filterByType(type);
  }

  List<LogEntry> filterByDateRange(DateTime start, DateTime end) {
    return _loggerService.filterByDateRange(start, end);
  }
}
