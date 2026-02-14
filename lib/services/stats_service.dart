import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder.dart';
import 'logger_service.dart';

/// 每日统计数据
class DailyStats {
  final DateTime date;
  final int created;
  final int triggered;
  final int cancelled;

  const DailyStats({
    required this.date,
    required this.created,
    required this.triggered,
    required this.cancelled,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: DateTime.parse(json['date'] as String),
      created: json['created'] as int? ?? 0,
      triggered: json['triggered'] as int? ?? 0,
      cancelled: json['cancelled'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'created': created,
      'triggered': triggered,
      'cancelled': cancelled,
    };
  }
}

/// 提醒统计数据
class ReminderStats {
  /// 总计创建
  final int totalCreated;

  /// 总计触发
  final int totalTriggered;

  /// 总计取消
  final int totalCancelled;

  /// 完成率 (0.0 - 1.0)
  final double completionRate;

  /// 按小时统计 {'09': 5, '10': 8, ...}
  final Map<String, int> byHour;

  /// 按分类统计
  final Map<String, int> byCategory;

  /// 每日趋势数据
  final List<DailyStats> dailyTrends;

  const ReminderStats({
    required this.totalCreated,
    required this.totalTriggered,
    required this.totalCancelled,
    required this.completionRate,
    required this.byHour,
    required this.byCategory,
    required this.dailyTrends,
  });
}

/// 统计分析服务
class StatsService {
  final LoggerService _logger;
  static const String _statsEventsKey = 'stats_events';
  static const int _maxEventsToKeep = 1000;

  StatsService(this._logger);

  /// 记录提醒事件
  Future<void> recordEvent(
    Reminder reminder,
    String event, // 'created', 'triggered', 'cancelled'
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString(_statsEventsKey);

      List<Map<String, dynamic>> events = [];
      if (eventsJson != null) {
        final List<dynamic> jsonList = jsonDecode(eventsJson);
        events = jsonList
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }

      // 添加新事件
      events.add({
        'timestamp': DateTime.now().toIso8601String(),
        'event': event,
        'reminderId': reminder.id,
        'templateId': reminder.templateId,
        'category': _getCategoryFromTemplate(reminder.templateId),
        'type': reminder.type,
      });

      // 限制事件数量
      if (events.length > _maxEventsToKeep) {
        events = events.sublist(events.length - _maxEventsToKeep);
      }

      await prefs.setString(_statsEventsKey, jsonEncode(events));
      _logger.debug('Recorded stats event: $event for ${reminder.id}');
    } catch (e) {
      _logger.error('Failed to record stats event: $e');
    }
  }

  /// 计算统计数据
  Future<ReminderStats> calculate({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString(_statsEventsKey);

      if (eventsJson == null) {
        return const ReminderStats(
          totalCreated: 0,
          totalTriggered: 0,
          totalCancelled: 0,
          completionRate: 0,
          byHour: {},
          byCategory: {},
          dailyTrends: [],
        );
      }

      final List<dynamic> jsonList = jsonDecode(eventsJson);
      final events = jsonList
          .map((e) => e as Map<String, dynamic>)
          .where((e) {
        final timestamp = DateTime.parse(e['timestamp'] as String);
        if (startDate != null && timestamp.isBefore(startDate)) return false;
        if (endDate != null && timestamp.isAfter(endDate)) return false;
        return true;
      }).toList();

      // 统计各项指标
      int totalCreated = 0;
      int totalTriggered = 0;
      int totalCancelled = 0;
      final byHour = <String, int>{};
      final byCategory = <String, int>{};
      final dailyMap = <String, DailyStats>{};

      for (final event in events) {
        final timestamp = DateTime.parse(event['timestamp'] as String);
        final eventStr = event['event'] as String;
        final hour = timestamp.hour.toString().padLeft(2, '0');
        final category = event['category'] as String? ?? 'custom';
        final dateKey = timestamp.toIso8601String().split('T')[0];

        switch (eventStr) {
          case 'created':
            totalCreated++;
            byHour[hour] = (byHour[hour] ?? 0) + 1;
            byCategory[category] = (byCategory[category] ?? 0) + 1;
            _updateDailyStats(dailyMap, dateKey, created: 1);
            break;
          case 'triggered':
            totalTriggered++;
            _updateDailyStats(dailyMap, dateKey, triggered: 1);
            break;
          case 'cancelled':
            totalCancelled++;
            _updateDailyStats(dailyMap, dateKey, cancelled: 1);
            break;
        }
      }

      // 计算完成率
      final completionRate = totalCreated > 0
          ? totalTriggered / totalCreated
          : 0.0;

      // 转换每日趋势
      final dailyTrends = dailyMap.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      return ReminderStats(
        totalCreated: totalCreated,
        totalTriggered: totalTriggered,
        totalCancelled: totalCancelled,
        completionRate: completionRate,
        byHour: byHour,
        byCategory: byCategory,
        dailyTrends: dailyTrends,
      );
    } catch (e) {
      _logger.error('Failed to calculate stats: $e');
      return const ReminderStats(
        totalCreated: 0,
        totalTriggered: 0,
        totalCancelled: 0,
        completionRate: 0,
        byHour: {},
        byCategory: {},
        dailyTrends: [],
      );
    }
  }

  /// 获取最近 N 天的趋势数据
  Future<List<DailyStats>> getTrends(int days) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    final stats = await calculate(startDate: startDate, endDate: endDate);
    return stats.dailyTrends;
  }

  /// 清除所有统计数据
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_statsEventsKey);
      _logger.info('Cleared all stats data');
    } catch (e) {
      _logger.error('Failed to clear stats: $e');
    }
  }

  void _updateDailyStats(
    Map<String, DailyStats> map,
    String dateKey, {
    int created = 0,
    int triggered = 0,
    int cancelled = 0,
  }) {
    final existing = map[dateKey];
    if (existing != null) {
      map[dateKey] = DailyStats(
        date: existing.date,
        created: existing.created + created,
        triggered: existing.triggered + triggered,
        cancelled: existing.cancelled + cancelled,
      );
    } else {
      map[dateKey] = DailyStats(
        date: DateTime.parse(dateKey),
        created: created,
        triggered: triggered,
        cancelled: cancelled,
      );
    }
  }

  String _getCategoryFromTemplate(String? templateId) {
    if (templateId == null) return 'custom';
    // 从模板 ID 推断分类
    if (templateId.contains('break') || templateId.contains('pomodoro')) {
      return 'break';
    } else if (templateId.contains('meeting') || templateId.contains('standup')) {
      return 'meeting';
    } else if (templateId.contains('medicine') ||
        templateId.contains('water') ||
        templateId.contains('stretch') ||
        templateId.contains('lunch')) {
      return 'health';
    } else if (templateId.contains('work')) {
      return 'work';
    }
    return 'custom';
  }
}
