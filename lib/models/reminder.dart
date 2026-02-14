import 'repeat_rule.dart';

class Reminder {
  final String id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final DateTime createdAt;
  final String type; // 'notification' or 'flash'
  final String? flashColor;
  final int? flashDuration;

  // === 新增字段 ===
  /// 重复规则
  final RepeatRule? repeatRule;

  /// 来源模板 ID
  final String? templateId;

  /// 父提醒 ID（用于关联提醒和重复提醒）
  final String? parentReminderId;

  /// 关联提醒 ID 列表
  final List<String> relatedIds;

  /// 重复次数索引（第几次重复）
  final int occurrenceIndex;

  /// 声音标识
  final String? soundKey;

  Reminder({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.createdAt,
    required this.type,
    this.flashColor,
    this.flashDuration,
    this.repeatRule,
    this.templateId,
    this.parentReminderId,
    this.relatedIds = const [],
    this.occurrenceIndex = 0,
    this.soundKey,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: json['type'] as String? ?? 'notification',
      flashColor: json['flashColor'] as String?,
      flashDuration: json['flashDuration'] as int?,
      repeatRule: json['repeatRule'] != null
          ? RepeatRule.fromJson(json['repeatRule'] as Map<String, dynamic>)
          : null,
      templateId: json['templateId'] as String?,
      parentReminderId: json['parentReminderId'] as String?,
      relatedIds: (json['relatedIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      occurrenceIndex: json['occurrenceIndex'] as int? ?? 0,
      soundKey: json['soundKey'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'scheduledTime': scheduledTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'type': type,
      if (flashColor != null) 'flashColor': flashColor,
      if (flashDuration != null) 'flashDuration': flashDuration,
      if (repeatRule != null) 'repeatRule': repeatRule!.toJson(),
      if (templateId != null) 'templateId': templateId,
      if (parentReminderId != null) 'parentReminderId': parentReminderId,
      if (relatedIds.isNotEmpty) 'relatedIds': relatedIds,
      if (occurrenceIndex > 0) 'occurrenceIndex': occurrenceIndex,
      if (soundKey != null) 'soundKey': soundKey,
    };
  }

  bool get isExpired => DateTime.now().isAfter(scheduledTime);

  bool get isRepeating =>
      repeatRule != null && repeatRule!.frequency != 'none';

  Duration get timeUntilReminder {
    final now = DateTime.now();
    if (scheduledTime.isBefore(now)) {
      return Duration.zero;
    }
    return scheduledTime.difference(now);
  }

  String get timeRemaining {
    final duration = timeUntilReminder;
    if (duration.inMinutes == 0) {
      return '${duration.inSeconds}s';
    } else if (duration.inHours == 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else if (duration.inDays == 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    }
  }

  Reminder copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? scheduledTime,
    DateTime? createdAt,
    String? type,
    String? flashColor,
    int? flashDuration,
    RepeatRule? repeatRule,
    String? templateId,
    String? parentReminderId,
    List<String>? relatedIds,
    int? occurrenceIndex,
    String? soundKey,
    bool clearFlashColor = false,
    bool clearFlashDuration = false,
    bool clearRepeatRule = false,
    bool clearTemplateId = false,
    bool clearParentReminderId = false,
    bool clearSoundKey = false,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      flashColor: clearFlashColor ? null : (flashColor ?? this.flashColor),
      flashDuration:
          clearFlashDuration ? null : (flashDuration ?? this.flashDuration),
      repeatRule: clearRepeatRule ? null : (repeatRule ?? this.repeatRule),
      templateId: clearTemplateId ? null : (templateId ?? this.templateId),
      parentReminderId:
          clearParentReminderId ? null : (parentReminderId ?? this.parentReminderId),
      relatedIds: relatedIds ?? this.relatedIds,
      occurrenceIndex: occurrenceIndex ?? this.occurrenceIndex,
      soundKey: clearSoundKey ? null : (soundKey ?? this.soundKey),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reminder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
