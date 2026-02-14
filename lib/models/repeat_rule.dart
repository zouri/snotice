/// 重复规则模型
class RepeatRule {
  /// 频率类型: 'none', 'daily', 'weekly', 'monthly', 'custom'
  final String frequency;

  /// 间隔（每N天/周/月）
  final int interval;

  /// 周几重复 [1-7] (1=Monday, 7=Sunday)，用于 weekly
  final List<int>? weekdays;

  /// 结束日期，null 表示不限制
  final DateTime? endDate;

  /// 最大重复次数，null 表示不限制
  final int? maxCount;

  const RepeatRule({
    this.frequency = 'none',
    this.interval = 1,
    this.weekdays,
    this.endDate,
    this.maxCount,
  });

  bool get isRepeating => frequency != 'none';

  factory RepeatRule.fromJson(Map<String, dynamic> json) {
    return RepeatRule(
      frequency: json['frequency'] as String? ?? 'none',
      interval: json['interval'] as int? ?? 1,
      weekdays: (json['weekdays'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      maxCount: json['maxCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frequency': frequency,
      'interval': interval,
      if (weekdays != null) 'weekdays': weekdays,
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (maxCount != null) 'maxCount': maxCount,
    };
  }

  RepeatRule copyWith({
    String? frequency,
    int? interval,
    List<int>? weekdays,
    DateTime? endDate,
    int? maxCount,
    bool clearEndDate = false,
    bool clearMaxCount = false,
    bool clearWeekdays = false,
  }) {
    return RepeatRule(
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      weekdays: clearWeekdays ? null : (weekdays ?? this.weekdays),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      maxCount: clearMaxCount ? null : (maxCount ?? this.maxCount),
    );
  }

  @override
  String toString() {
    switch (frequency) {
      case 'none':
        return '不重复';
      case 'daily':
        return interval == 1 ? '每天' : '每 $interval 天';
      case 'weekly':
        if (weekdays != null && weekdays!.isNotEmpty) {
          final dayNames = weekdays!.map((d) => _weekdayName(d)).join('、');
          return '每周 $dayNames';
        }
        return interval == 1 ? '每周' : '每 $interval 周';
      case 'monthly':
        return interval == 1 ? '每月' : '每 $interval 月';
      case 'custom':
        return '自定义';
      default:
        return frequency;
    }
  }

  String _weekdayName(int day) {
    const names = ['一', '二', '三', '四', '五', '六', '日'];
    return '周${names[day - 1]}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RepeatRule &&
        other.frequency == frequency &&
        other.interval == interval &&
        _listEquals(other.weekdays, weekdays) &&
        other.endDate == endDate &&
        other.maxCount == maxCount;
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      frequency,
      interval,
      Object.hashAll(weekdays ?? []),
      endDate,
      maxCount,
    );
  }
}
