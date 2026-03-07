enum NotificationPriority {
  low,
  normal,
  high;

  String get value => name;

  static NotificationPriority? tryParse(String? rawValue) {
    switch (rawValue?.trim().toLowerCase()) {
      case 'low':
        return NotificationPriority.low;
      case 'high':
        return NotificationPriority.high;
      case 'normal':
        return NotificationPriority.normal;
      default:
        return null;
    }
  }
}

enum NotificationCategory {
  flashFull,
  flashEdge;

  String get value {
    switch (this) {
      case NotificationCategory.flashFull:
        return 'flash_full';
      case NotificationCategory.flashEdge:
        return 'flash_edge';
    }
  }

  static NotificationCategory? tryParse(String? rawValue) {
    switch (rawValue?.trim().toLowerCase()) {
      case 'flash_full':
        return NotificationCategory.flashFull;
      case 'flash_edge':
        return NotificationCategory.flashEdge;
      default:
        return null;
    }
  }
}

class NotificationRequest {
  final String title;
  final String body;
  final String? icon;
  final NotificationPriority priority;
  final NotificationCategory? category;
  final String? flashColor;
  final int? flashDuration;
  final double? edgeWidth;
  final double? edgeOpacity;
  final int? edgeRepeat;
  final Map<String, dynamic>? payload;
  final bool _hasInvalidPriority;
  final bool _hasInvalidCategory;

  NotificationRequest({
    required this.title,
    required this.body,
    this.icon,
    this.priority = NotificationPriority.normal,
    this.category,
    this.flashColor,
    this.flashDuration,
    this.edgeWidth,
    this.edgeOpacity,
    this.edgeRepeat,
    Map<String, dynamic>? payload,
    bool hasInvalidPriority = false,
    bool hasInvalidCategory = false,
  }) : payload = payload == null ? null : Map.unmodifiable(payload),
       _hasInvalidPriority = hasInvalidPriority,
       _hasInvalidCategory = hasInvalidCategory;

  factory NotificationRequest.fromJson(Map<String, dynamic> json) {
    final rawPriority = _parseString(json['priority']);
    final rawCategory = _parseString(json['category']);
    final priority = NotificationPriority.tryParse(rawPriority);
    final category = NotificationCategory.tryParse(rawCategory);

    return NotificationRequest(
      title: _parseString(json['title']) ?? '',
      body: _parseString(json['body']) ?? '',
      icon: _parseString(json['icon']),
      priority: priority ?? NotificationPriority.normal,
      category: category,
      flashColor: _parseString(json['flashColor']),
      flashDuration: _parseInt(json['flashDuration']),
      edgeWidth: _parseDouble(json['edgeWidth']),
      edgeOpacity: _parseDouble(json['edgeOpacity']),
      edgeRepeat: _parseInt(json['edgeRepeat']),
      payload: _parsePayload(json['payload']),
      hasInvalidPriority: rawPriority != null && priority == null,
      hasInvalidCategory: rawCategory != null && category == null,
    );
  }

  static int? _parseInt(dynamic value) {
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

  static double? _parseDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim());
    }
    return null;
  }

  static String? _parseString(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    return value.toString();
  }

  static Map<String, dynamic>? _parsePayload(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      if (icon != null) 'icon': icon,
      'priority': priority.value,
      if (category != null) 'category': category!.value,
      if (flashColor != null) 'flashColor': flashColor,
      if (flashDuration != null) 'flashDuration': flashDuration,
      if (edgeWidth != null) 'edgeWidth': edgeWidth,
      if (edgeOpacity != null) 'edgeOpacity': edgeOpacity,
      if (edgeRepeat != null) 'edgeRepeat': edgeRepeat,
      if (payload != null) 'payload': payload,
    };
  }

  List<String> validate() {
    final errors = <String>[];

    if (title.trim().isEmpty) {
      errors.add('Field "title" is required.');
    }

    if (!isFlash && body.trim().isEmpty) {
      errors.add('Field "body" is required for non-flash notifications.');
    }

    if (_hasInvalidPriority) {
      errors.add('Field "priority" must be one of: low, normal, high.');
    }

    if (_hasInvalidCategory) {
      errors.add('Field "category" must be one of: flash_full, flash_edge.');
    }

    if (flashDuration != null && flashDuration! <= 0) {
      errors.add('Field "flashDuration" must be greater than 0.');
    }

    if (edgeWidth != null && edgeWidth! <= 0) {
      errors.add('Field "edgeWidth" must be greater than 0.');
    }

    if (edgeOpacity != null && (edgeOpacity! < 0 || edgeOpacity! > 1)) {
      errors.add('Field "edgeOpacity" must be between 0 and 1.');
    }

    if (edgeRepeat != null && edgeRepeat! <= 0) {
      errors.add('Field "edgeRepeat" must be greater than 0.');
    }

    if (category != NotificationCategory.flashEdge &&
        (edgeWidth != null || edgeOpacity != null || edgeRepeat != null)) {
      errors.add(
        'edgeWidth/edgeOpacity/edgeRepeat require category=flash_edge.',
      );
    }

    return errors;
  }

  bool get isValid => validate().isEmpty;
  bool get isFlash =>
      category == NotificationCategory.flashFull ||
      category == NotificationCategory.flashEdge;
  bool get isEdgeFlash => category == NotificationCategory.flashEdge;
}
