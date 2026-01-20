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
    return NotificationRequest(
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      icon: json['icon'] as String?,
      priority: json['priority'] as String? ?? 'normal',
      category: json['category'] as String?,
      flashColor: json['flashColor'] as String?,
      flashDuration: json['flashDuration'] as int?,
      payload: json['payload'] as Map<String, dynamic>?,
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
