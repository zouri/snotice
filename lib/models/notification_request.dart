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
  flashEdge,
  barrage;

  String get value {
    switch (this) {
      case NotificationCategory.flashFull:
        return 'flash_full';
      case NotificationCategory.flashEdge:
        return 'flash_edge';
      case NotificationCategory.barrage:
        return 'barrage';
    }
  }

  static NotificationCategory? tryParse(String? rawValue) {
    switch (rawValue?.trim().toLowerCase()) {
      case 'flash_full':
        return NotificationCategory.flashFull;
      case 'flash_edge':
        return NotificationCategory.flashEdge;
      case 'barrage':
        return NotificationCategory.barrage;
      default:
        return null;
    }
  }
}

enum NotificationBarrageLane {
  top,
  middle,
  bottom;

  String get value => name;

  static NotificationBarrageLane? tryParse(String? rawValue) {
    switch (rawValue?.trim().toLowerCase()) {
      case 'top':
        return NotificationBarrageLane.top;
      case 'middle':
        return NotificationBarrageLane.middle;
      case 'bottom':
        return NotificationBarrageLane.bottom;
      default:
        return null;
    }
  }
}

class NotificationRequest {
  static const int maxBarrageRepeat = 8;

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
  final String? barrageColor;
  final int? barrageDuration;
  final double? barrageSpeed;
  final double? barrageFontSize;
  final NotificationBarrageLane? barrageLane;
  final int? barrageRepeat;
  final Map<String, dynamic>? payload;
  final bool _hasInvalidPriority;
  final bool _hasInvalidCategory;
  final bool _hasInvalidBarrageLane;

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
    this.barrageColor,
    this.barrageDuration,
    this.barrageSpeed,
    this.barrageFontSize,
    this.barrageLane,
    this.barrageRepeat,
    Map<String, dynamic>? payload,
    bool hasInvalidPriority = false,
    bool hasInvalidCategory = false,
    bool hasInvalidBarrageLane = false,
  }) : payload = payload == null ? null : Map.unmodifiable(payload),
       _hasInvalidPriority = hasInvalidPriority,
       _hasInvalidCategory = hasInvalidCategory,
       _hasInvalidBarrageLane = hasInvalidBarrageLane;

  factory NotificationRequest.fromJson(Map<String, dynamic> json) {
    final rawPriority = _parseString(json['priority']);
    final rawCategory = _parseString(json['category']);
    final rawBarrageLane = _parseString(json['barrageLane']);
    final priority = NotificationPriority.tryParse(rawPriority);
    final category = NotificationCategory.tryParse(rawCategory);
    final barrageLane = NotificationBarrageLane.tryParse(rawBarrageLane);

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
      barrageColor: _parseString(json['barrageColor']),
      barrageDuration: _parseInt(json['barrageDuration']),
      barrageSpeed: _parseDouble(json['barrageSpeed']),
      barrageFontSize: _parseDouble(json['barrageFontSize']),
      barrageLane: barrageLane,
      barrageRepeat: _parseInt(json['barrageRepeat']),
      payload: _parsePayload(json['payload']),
      hasInvalidPriority: rawPriority != null && priority == null,
      hasInvalidCategory: rawCategory != null && category == null,
      hasInvalidBarrageLane: rawBarrageLane != null && barrageLane == null,
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
      if (barrageColor != null) 'barrageColor': barrageColor,
      if (barrageDuration != null) 'barrageDuration': barrageDuration,
      if (barrageSpeed != null) 'barrageSpeed': barrageSpeed,
      if (barrageFontSize != null) 'barrageFontSize': barrageFontSize,
      if (barrageLane != null) 'barrageLane': barrageLane!.value,
      if (barrageRepeat != null) 'barrageRepeat': barrageRepeat,
      if (payload != null) 'payload': payload,
    };
  }

  List<String> validate() {
    final errors = <String>[];

    if (title.trim().isEmpty) {
      errors.add('Field "title" is required.');
    }

    if (!isFlash && !isBarrage && body.trim().isEmpty) {
      errors.add('Field "body" is required for non-overlay notifications.');
    }

    if (_hasInvalidPriority) {
      errors.add('Field "priority" must be one of: low, normal, high.');
    }

    if (_hasInvalidCategory) {
      errors.add(
        'Field "category" must be one of: flash_full, flash_edge, barrage.',
      );
    }

    if (_hasInvalidBarrageLane) {
      errors.add('Field "barrageLane" must be one of: top, middle, bottom.');
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

    if (barrageDuration != null && barrageDuration! <= 0) {
      errors.add('Field "barrageDuration" must be greater than 0.');
    }

    if (barrageSpeed != null && barrageSpeed! <= 0) {
      errors.add('Field "barrageSpeed" must be greater than 0.');
    }

    if (barrageFontSize != null && barrageFontSize! <= 0) {
      errors.add('Field "barrageFontSize" must be greater than 0.');
    }

    if (barrageRepeat != null && barrageRepeat! <= 0) {
      errors.add('Field "barrageRepeat" must be greater than 0.');
    }

    if (barrageRepeat != null && barrageRepeat! > maxBarrageRepeat) {
      errors.add(
        'Field "barrageRepeat" must be less than or equal to $maxBarrageRepeat.',
      );
    }

    if (category != NotificationCategory.flashEdge &&
        (edgeWidth != null || edgeOpacity != null || edgeRepeat != null)) {
      errors.add(
        'edgeWidth/edgeOpacity/edgeRepeat require category=flash_edge.',
      );
    }

    if (category != NotificationCategory.barrage &&
        (barrageColor != null ||
            barrageDuration != null ||
            barrageSpeed != null ||
            barrageFontSize != null ||
            barrageLane != null ||
            barrageRepeat != null)) {
      errors.add(
        'barrageColor/barrageDuration/barrageSpeed/barrageFontSize/barrageLane/barrageRepeat require category=barrage.',
      );
    }

    return errors;
  }

  bool get isValid => validate().isEmpty;
  bool get isFlash =>
      category == NotificationCategory.flashFull ||
      category == NotificationCategory.flashEdge;
  bool get isEdgeFlash => category == NotificationCategory.flashEdge;
  bool get isBarrage => category == NotificationCategory.barrage;
}
