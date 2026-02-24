class NotificationRequest {
  String title;
  String body;
  String? icon;
  String? priority;
  String? category;
  String? flashColor;
  int? flashDuration;
  Map<String, dynamic>? payload;

  NotificationRequest({
    required this.title,
    required this.body,
    this.icon,
    this.priority = 'normal',
    this.category,
    this.flashColor,
    this.flashDuration,
    this.payload,
  });

  factory NotificationRequest.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value is int) {
        return value;
      }
      if (value is double) {
        return value.toInt();
      }
      if (value is String) {
        return int.tryParse(value.trim());
      }
      return null;
    }

    String? parseString(dynamic value) {
      if (value == null) {
        return null;
      }
      if (value is String) {
        return value;
      }
      return value.toString();
    }

    Map<String, dynamic>? parsePayload(dynamic value) {
      if (value is Map<String, dynamic>) {
        return value;
      }
      if (value is Map) {
        return value.map((key, val) => MapEntry(key.toString(), val));
      }
      return null;
    }

    return NotificationRequest(
      title: parseString(json['title']) ?? '',
      body: parseString(json['body'] ?? json['message']) ?? '',
      icon: parseString(json['icon']),
      priority: parseString(json['priority']) ?? 'normal',
      category: parseString(json['category'] ?? json['type']),
      flashColor: parseString(json['flashColor'] ?? json['color']),
      flashDuration: parseInt(json['flashDuration'] ?? json['duration']),
      payload: parsePayload(json['payload']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      if (icon != null) 'icon': icon,
      if (priority != null) 'priority': priority,
      if (category != null) 'category': category,
      if (flashColor != null) 'flashColor': flashColor,
      if (flashDuration != null) 'flashDuration': flashDuration,
      if (payload != null) 'payload': payload,
    };
  }

  bool get isValid => title.isNotEmpty && body.isNotEmpty;
}
