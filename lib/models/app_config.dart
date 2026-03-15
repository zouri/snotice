import '../config/constants.dart';
import '../utils/ip_utils.dart';

class AppConfig {
  static const int maxBarrageRepeat = 8;

  final int port;
  final List<String> allowedIPs;
  final bool autoLaunchOnLogin;
  final bool showNotifications;
  final bool showBarrage;
  final String defaultBarrageColor;
  final int defaultBarrageDuration;
  final double defaultBarrageSpeed;
  final double defaultBarrageFontSize;
  final String defaultBarrageLane;
  final int defaultBarrageRepeat;

  AppConfig({
    this.port = 8642,
    List<String>? allowedIPs,
    this.autoLaunchOnLogin = false,
    this.showNotifications = true,
    this.showBarrage = true,
    String defaultBarrageColor = '#FFD84D',
    int defaultBarrageDuration = 6000,
    double defaultBarrageSpeed = 120,
    double defaultBarrageFontSize = 28,
    String defaultBarrageLane = 'top',
    int defaultBarrageRepeat = 1,
  }) : allowedIPs = List.unmodifiable(
         _normalizeAllowedIPs(allowedIPs ?? AppConstants.defaultAllowedIPs),
       ),
       defaultBarrageColor = _normalizeBarrageColor(defaultBarrageColor),
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
    final rawAllowedIPs = json['allowedIPs'] as List<dynamic>?;

    return AppConfig(
      port: _parseInt(json['port']) ?? 8642,
      allowedIPs:
          rawAllowedIPs?.whereType<String>().map((ip) => ip.trim()).toList() ??
          AppConstants.defaultAllowedIPs,
      autoLaunchOnLogin: _parseBool(json['autoLaunchOnLogin']) ?? false,
      showNotifications: _parseBool(json['showNotifications']) ?? true,
      showBarrage: _parseBool(json['showBarrage']) ?? true,
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
      'allowedIPs': allowedIPs,
      'autoLaunchOnLogin': autoLaunchOnLogin,
      'showNotifications': showNotifications,
      'showBarrage': showBarrage,
      'defaultBarrageColor': defaultBarrageColor,
      'defaultBarrageDuration': defaultBarrageDuration,
      'defaultBarrageSpeed': defaultBarrageSpeed,
      'defaultBarrageFontSize': defaultBarrageFontSize,
      'defaultBarrageLane': defaultBarrageLane,
      'defaultBarrageRepeat': defaultBarrageRepeat,
    };
  }

  bool isIPAllowed(String ip) {
    if (allowedIPs.isEmpty) return true;

    for (final allowedIP in allowedIPs) {
      if (IPUtils.isCIDRFormat(allowedIP)) {
        if (IPUtils.isIPInCIDR(ip, allowedIP)) {
          return true;
        }
      } else if (allowedIP == ip) {
        return true;
      }
    }

    return false;
  }

  AppConfig copyWith({
    int? port,
    List<String>? allowedIPs,
    bool? autoLaunchOnLogin,
    bool? showNotifications,
    bool? showBarrage,
    String? defaultBarrageColor,
    int? defaultBarrageDuration,
    double? defaultBarrageSpeed,
    double? defaultBarrageFontSize,
    String? defaultBarrageLane,
    int? defaultBarrageRepeat,
  }) {
    return AppConfig(
      port: port ?? this.port,
      allowedIPs: allowedIPs ?? this.allowedIPs,
      autoLaunchOnLogin: autoLaunchOnLogin ?? this.autoLaunchOnLogin,
      showNotifications: showNotifications ?? this.showNotifications,
      showBarrage: showBarrage ?? this.showBarrage,
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

  static List<String> _normalizeAllowedIPs(List<String> source) {
    final normalized = <String>[];
    final seen = <String>{};

    for (final value in source) {
      final ip = value.trim();
      if (ip.isEmpty || !seen.add(ip)) {
        continue;
      }
      normalized.add(ip);
    }

    return normalized;
  }

  static String _normalizeBarrageColor(String source) {
    final normalized = source.trim();
    return normalized.isEmpty ? '#FFD84D' : normalized;
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
