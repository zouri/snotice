/// 提醒模板模型
class ReminderTemplate {
  /// 唯一标识
  final String id;

  /// 显示名称
  final String name;

  /// emoji 图标
  final String icon;

  /// 默认延迟分钟数
  final int delayMinutes;

  /// 默认标题
  final String defaultTitle;

  /// 默认内容
  final String defaultBody;

  /// 类型: 'notification' | 'flash'
  final String type;

  /// 闪屏颜色（仅 type='flash' 时有效）
  final String? flashColor;

  /// 闪屏持续时间（毫秒）
  final int? flashDuration;

  /// 闪屏效果（仅 type='flash' 时有效）
  final String? flashEffect;

  /// 声音标识
  final String? soundKey;

  /// 是否内置模板
  final bool isBuiltIn;

  /// 是否收藏
  final bool isFavorite;

  /// 排序权重
  final int sortOrder;

  const ReminderTemplate({
    required this.id,
    required this.name,
    required this.icon,
    required this.delayMinutes,
    required this.defaultTitle,
    required this.defaultBody,
    required this.type,
    this.flashColor,
    this.flashDuration,
    this.flashEffect,
    this.soundKey,
    this.isBuiltIn = false,
    this.isFavorite = false,
    this.sortOrder = 0,
  });

  factory ReminderTemplate.fromJson(Map<String, dynamic> json) {
    return ReminderTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? '🔔',
      delayMinutes: json['delayMinutes'] as int? ?? 5,
      defaultTitle: json['defaultTitle'] as String? ?? '',
      defaultBody: json['defaultBody'] as String? ?? '',
      type: json['type'] as String? ?? 'notification',
      flashColor: json['flashColor'] as String?,
      flashDuration: json['flashDuration'] as int?,
      flashEffect: json['flashEffect'] as String?,
      soundKey: json['soundKey'] as String?,
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'delayMinutes': delayMinutes,
      'defaultTitle': defaultTitle,
      'defaultBody': defaultBody,
      'type': type,
      if (flashColor != null) 'flashColor': flashColor,
      if (flashDuration != null) 'flashDuration': flashDuration,
      if (flashEffect != null) 'flashEffect': flashEffect,
      if (soundKey != null) 'soundKey': soundKey,
      'isBuiltIn': isBuiltIn,
      'isFavorite': isFavorite,
      'sortOrder': sortOrder,
    };
  }

  ReminderTemplate copyWith({
    String? id,
    String? name,
    String? icon,
    int? delayMinutes,
    String? defaultTitle,
    String? defaultBody,
    String? type,
    String? flashColor,
    int? flashDuration,
    String? flashEffect,
    String? soundKey,
    bool? isBuiltIn,
    bool? isFavorite,
    int? sortOrder,
    bool clearFlashColor = false,
    bool clearFlashDuration = false,
    bool clearFlashEffect = false,
    bool clearSoundKey = false,
  }) {
    return ReminderTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      delayMinutes: delayMinutes ?? this.delayMinutes,
      defaultTitle: defaultTitle ?? this.defaultTitle,
      defaultBody: defaultBody ?? this.defaultBody,
      type: type ?? this.type,
      flashColor: clearFlashColor ? null : (flashColor ?? this.flashColor),
      flashDuration: clearFlashDuration
          ? null
          : (flashDuration ?? this.flashDuration),
      flashEffect: clearFlashEffect ? null : (flashEffect ?? this.flashEffect),
      soundKey: clearSoundKey ? null : (soundKey ?? this.soundKey),
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isFavorite: isFavorite ?? this.isFavorite,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// 获取延迟时间的友好显示
  String get delayDisplay {
    if (delayMinutes < 60) {
      return '$delayMinutes 分钟';
    } else if (delayMinutes < 1440) {
      final hours = delayMinutes ~/ 60;
      final minutes = delayMinutes % 60;
      if (minutes == 0) {
        return '$hours 小时';
      }
      return '$hours 小时 $minutes 分钟';
    } else {
      final days = delayMinutes ~/ 1440;
      return '$days 天';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReminderTemplate && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
