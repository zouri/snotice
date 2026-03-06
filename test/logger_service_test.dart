import 'package:flutter_test/flutter_test.dart';
import 'package:snotice_new/models/log_entry.dart';
import 'package:snotice_new/services/logger_service.dart';

void main() {
  group('LoggerService', () {
    test('writes logs with typed levels', () {
      final logger = LoggerService();

      logger.info('i');
      logger.error('e');
      logger.request('r');

      expect(logger.logs.length, 3);
      expect(logger.logs[0].type, LogType.info);
      expect(logger.logs[1].type, LogType.error);
      expect(logger.logs[2].type, LogType.request);
    });

    test('enforces max log entries rotation', () {
      final logger = LoggerService(maxLogEntries: 2);

      logger.info('1');
      logger.info('2');
      logger.info('3');

      expect(logger.logs.length, 2);
      expect(logger.logs[0].message, '2');
      expect(logger.logs[1].message, '3');
    });

    test('logs getter is unmodifiable', () {
      final logger = LoggerService();
      logger.info('x');

      expect(
        () => logger.logs.add(
          LogEntry(
            timestamp: DateTime.now(),
            type: LogType.debug,
            message: 'nope',
          ),
        ),
        throwsUnsupportedError,
      );
    });

    test('notifies listeners on log and non-empty clear only', () {
      final logger = LoggerService();
      var notifyCount = 0;
      logger.addListener(() {
        notifyCount++;
      });

      logger.clear();
      expect(notifyCount, 0);

      logger.info('a');
      expect(notifyCount, 1);

      logger.clear();
      expect(notifyCount, 2);
    });
  });
}
