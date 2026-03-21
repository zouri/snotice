class AppConfig {
  static const int maxBarrageRepeat = 8;

  final int port;
  final bool autoLaunchOnLogin;
  final bool showNotifications;
  final bool showFlash;
  final bool showBarrage;
  final bool showSound;
  final String defaultFlashColor;
  final int defaultFlashDuration;
  final double defaultFlashEdgeWidth;
  final double defaultFlashEdgeOpacity;
  final int defaultFlashEdgeRepeat;
  final String defaultBarrageColor;
  final int defaultBarrageDuration;
  final double defaultBarrageSpeed;
  final double defaultBarrageFontSize;
  final String defaultBarrageLane;
  final int defaultBarrageRepeat;

  AppConfig({
    this.port = 8642,
    this.autoLaunchOnLogin = false,
    this.showNotifications = true,
    this.showFlash = true,
    this.showBarrage = true,
    this.showSound = true,
    String defaultFlashColor = '#FF0000',
    int defaultFlashDuration = 500,
    double defaultFlashEdgeWidth = 12,
    double defaultFlashEdgeOpacity = 0.92,
    int defaultFlashEdgeRepeat = 2,
    String defaultBarrageColor = '#FFD84D',
    int defaultBarrageDuration = 6000,
    double defaultBarrageSpeed = 120,
    double defaultBarrageFontSize = 28,
    String defaultBarrageLane = 'top',
    int defaultBarrageRepeat = 1,
  }) : defaultFlashColor = _normalizeColor(
         defaultFlashColor,
         fallback: '#FF0000',
       ),
       defaultFlashDuration = _normalizePositiveInt(
         defaultFlashDuration,
         fallback: 500,
       ),
       defaultFlashEdgeWidth = _normalizePositiveDouble(
         defaultFlashEdgeWidth,
         fallback: 12,
       ),
       defaultFlashEdgeOpacity = _normalizeOpacity(
         defaultFlashEdgeOpacity,
         fallback: 0.92,
       ),
       defaultFlashEdgeRepeat = _normalizePositiveInt(
         defaultFlashEdgeRepeat,
         fallback: 2,
       ),
       defaultBarrageColor = _normalizeColor(
         defaultBarrageColor,
         fallback: '#FFD84D',
       ),
       defaultBarrageDuration = _normalizePositiveInt(
         defaultBarrageDuration,
         fallback: 6000,
       ),
       defaultBarrageSpeed = _normalizePositiveDouble(
         defaultBarrageSpeed,
         fallback: 120,
       ),
       defaultBarrageFontSize = _normalizePositiveDouble(
         defaultBarrageFontSize,
         fallback: 28,
       ),
       defaultBarrageLane = _normalizeBarrageLane(defaultBarrageLane),
       defaultBarrageRepeat = _normalizeBarrageRepeat(defaultBarrageRepeat);

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      port: _parseInt(json['port']) ?? 8642,
      autoLaunchOnLogin: _parseBool(json['autoLaunchOnLogin']) ?? false,
      showNotifications: _parseBool(json['showNotifications']) ?? true,
      showFlash: _parseBool(json['showFlash']) ?? true,
      showBarrage: _parseBool(json['showBarrage']) ?? true,
      showSound: _parseBool(json['showSound']) ?? true,
      defaultFlashColor: _parseString(json['defaultFlashColor']) ?? '#FF0000',
      defaultFlashDuration: _parseInt(json['defaultFlashDuration']) ?? 500,
      defaultFlashEdgeWidth: _parseDouble(json['defaultFlashEdgeWidth']) ?? 12,
      defaultFlashEdgeOpacity:
          _parseDouble(json['defaultFlashEdgeOpacity']) ?? 0.92,
      defaultFlashEdgeRepeat: _parseInt(json['defaultFlashEdgeRepeat']) ?? 2,
      defaultBarrageColor:
          _parseString(json['defaultBarrageColor']) ?? '#FFD84D',
      defaultBarrageDuration: _parseInt(json['defaultBarrageDuration']) ?? 6000,
      defaultBarrageSpeed: _parseDouble(json['defaultBarrageSpeed']) ?? 120,
      defaultBarrageFontSize:
          _parseDouble(json['defaultBarrageFontSize']) ?? 28,
      defaultBarrageLane: _parseString(json['defaultBarrageLane']) ?? 'top',
      defaultBarrageRepeat: _parseInt(json['defaultBarrageRepeat']) ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'port': port,
      'autoLaunchOnLogin': autoLaunchOnLogin,
      'showNotifications': showNotifications,
      'showFlash': showFlash,
      'showBarrage': showBarrage,
      'showSound': showSound,
      'defaultFlashColor': defaultFlashColor,
      'defaultFlashDuration': defaultFlashDuration,
      'defaultFlashEdgeWidth': defaultFlashEdgeWidth,
      'defaultFlashEdgeOpacity': defaultFlashEdgeOpacity,
      'defaultFlashEdgeRepeat': defaultFlashEdgeRepeat,
      'defaultBarrageColor': defaultBarrageColor,
      'defaultBarrageDuration': defaultBarrageDuration,
      'defaultBarrageSpeed': defaultBarrageSpeed,
      'defaultBarrageFontSize': defaultBarrageFontSize,
      'defaultBarrageLane': defaultBarrageLane,
      'defaultBarrageRepeat': defaultBarrageRepeat,
    };
  }

  AppConfig copyWith({
    int? port,
    bool? autoLaunchOnLogin,
    bool? showNotifications,
    bool? showFlash,
    bool? showBarrage,
    bool? showSound,
    String? defaultFlashColor,
    int? defaultFlashDuration,
    double? defaultFlashEdgeWidth,
    double? defaultFlashEdgeOpacity,
    int? defaultFlashEdgeRepeat,
    String? defaultBarrageColor,
    int? defaultBarrageDuration,
    double? defaultBarrageSpeed,
    double? defaultBarrageFontSize,
    String? defaultBarrageLane,
    int? defaultBarrageRepeat,
  }) {
    return AppConfig(
      port: port ?? this.port,
      autoLaunchOnLogin: autoLaunchOnLogin ?? this.autoLaunchOnLogin,
      showNotifications: showNotifications ?? this.showNotifications,
      showFlash: showFlash ?? this.showFlash,
      showBarrage: showBarrage ?? this.showBarrage,
      showSound: showSound ?? this.showSound,
      defaultFlashColor: defaultFlashColor ?? this.defaultFlashColor,
      defaultFlashDuration: defaultFlashDuration ?? this.defaultFlashDuration,
      defaultFlashEdgeWidth:
          defaultFlashEdgeWidth ?? this.defaultFlashEdgeWidth,
      defaultFlashEdgeOpacity:
          defaultFlashEdgeOpacity ?? this.defaultFlashEdgeOpacity,
      defaultFlashEdgeRepeat:
          defaultFlashEdgeRepeat ?? this.defaultFlashEdgeRepeat,
      defaultBarrageColor: defaultBarrageColor ?? this.defaultBarrageColor,
      defaultBarrageDuration:
          defaultBarrageDuration ?? this.defaultBarrageDuration,
      defaultBarrageSpeed: defaultBarrageSpeed ?? this.defaultBarrageSpeed,
      defaultBarrageFontSize:
          defaultBarrageFontSize ?? this.defaultBarrageFontSize,
      defaultBarrageLane: defaultBarrageLane ?? this.defaultBarrageLane,
      defaultBarrageRepeat: defaultBarrageRepeat ?? this.defaultBarrageRepeat,
    );
  }

  static String _normalizeColor(String source, {required String fallback}) {
    final normalized = source.trim();
    return normalized.isEmpty ? fallback : normalized;
  }

  static int _normalizePositiveInt(int value, {required int fallback}) {
    return value > 0 ? value : fallback;
  }

  static double _normalizePositiveDouble(
    double value, {
    required double fallback,
  }) {
    return value > 0 ? value : fallback;
  }

  static double _normalizeOpacity(double value, {required double fallback}) {
    return value >= 0 && value <= 1 ? value : fallback;
  }

  static String _normalizeBarrageLane(String source) {
    final value = source.trim().toLowerCase();
    switch (value) {
      case 'middle':
      case 'bottom':
      case 'top':
        return value;
      default:
        return 'top';
    }
  }

  static int _normalizeBarrageRepeat(int value) {
    if (value <= 0) {
      return 1;
    }
    if (value > maxBarrageRepeat) {
      return maxBarrageRepeat;
    }
    return value;
  }

  static bool? _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') {
        return true;
      }
      if (normalized == 'false') {
        return false;
      }
    }
    return null;
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
}
