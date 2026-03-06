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
  flash;

  String get value => name;

  static NotificationCategory? tryParse(String? rawValue) {
    switch (rawValue?.trim().toLowerCase()) {
      case 'flash':
        return NotificationCategory.flash;
      default:
        return null;
    }
  }
}

enum FlashEffect {
  full,
  edge;

  String get value => name;

  static FlashEffect? tryParse(String? rawValue) {
    switch (rawValue?.trim().toLowerCase()) {
      case 'full':
        return FlashEffect.full;
      case 'edge':
        return FlashEffect.edge;
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
  final FlashEffect? flashEffect;
  final double? edgeWidth;
  final double? edgeOpacity;
  final int? edgeRepeat;
  final Map<String, dynamic>? payload;
  final bool _hasInvalidPriority;
  final bool _hasInvalidCategory;
  final bool _hasInvalidFlashEffect;

  NotificationRequest({
    required this.title,
    required this.body,
    this.icon,
    this.priority = NotificationPriority.normal,
    this.category,
    this.flashColor,
    this.flashDuration,
    this.flashEffect,
    this.edgeWidth,
    this.edgeOpacity,
    this.edgeRepeat,
    Map<String, dynamic>? payload,
    bool hasInvalidPriority = false,
    bool hasInvalidCategory = false,
    bool hasInvalidFlashEffect = false,
  }) : payload = payload == null ? null : Map.unmodifiable(payload),
       _hasInvalidPriority = hasInvalidPriority,
       _hasInvalidCategory = hasInvalidCategory,
       _hasInvalidFlashEffect = hasInvalidFlashEffect;

  factory NotificationRequest.fromJson(Map<String, dynamic> json) {
    final rawPriority = _parseString(json['priority']);
    final rawCategory = _parseString(json['category'] ?? json['type']);
    final rawFlashEffect = _parseString(json['flashEffect'] ?? json['effect']);
    final priority = NotificationPriority.tryParse(rawPriority);
    final category = NotificationCategory.tryParse(rawCategory);
    final flashEffect = FlashEffect.tryParse(rawFlashEffect);

    return NotificationRequest(
      title: _parseString(json['title']) ?? '',
      body: _parseString(json['body'] ?? json['message']) ?? '',
      icon: _parseString(json['icon']),
      priority: priority ?? NotificationPriority.normal,
      category: category,
      flashColor: _parseString(json['flashColor'] ?? json['color']),
      flashDuration: _parseInt(json['flashDuration'] ?? json['duration']),
      flashEffect: flashEffect,
      edgeWidth: _parseDouble(json['edgeWidth'] ?? json['width']),
      edgeOpacity: _parseDouble(json['edgeOpacity'] ?? json['opacity']),
      edgeRepeat: _parseInt(json['edgeRepeat'] ?? json['repeat']),
      payload: _parsePayload(json['payload']),
      hasInvalidPriority: rawPriority != null && priority == null,
      hasInvalidCategory: rawCategory != null && category == null,
      hasInvalidFlashEffect: rawFlashEffect != null && flashEffect == null,
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
      if (flashEffect != null) 'flashEffect': flashEffect!.value,
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
      errors.add('Field "category" must be: flash.');
    }

    if (_hasInvalidFlashEffect) {
      errors.add('Field "flashEffect" must be one of: full, edge.');
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

    if (flashEffect != FlashEffect.edge &&
        (edgeWidth != null || edgeOpacity != null || edgeRepeat != null)) {
      errors.add('edgeWidth/edgeOpacity/edgeRepeat require flashEffect=edge.');
    }

    return errors;
  }

  bool get isValid => validate().isEmpty;
  bool get isFlash => category == NotificationCategory.flash;
}
