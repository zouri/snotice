class Reminder {
  final String id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final DateTime createdAt;
  final String type; // 'notification' or 'flash'
  final String? flashColor;
  final int? flashDuration;

  Reminder({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.createdAt,
    required this.type,
    this.flashColor,
    this.flashDuration,
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
      'flashColor': flashColor,
      'flashDuration': flashDuration,
    };
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
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      flashColor: flashColor ?? this.flashColor,
      flashDuration: flashDuration ?? this.flashDuration,
    );
  }

  bool get isExpired => DateTime.now().isAfter(scheduledTime);

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
}
