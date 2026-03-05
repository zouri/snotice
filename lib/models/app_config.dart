import '../config/constants.dart';
import '../utils/ip_utils.dart';

class AppConfig {
  final int port;
  final List<String> allowedIPs;
  final bool autoStart;
  final bool showNotifications;

  AppConfig({
    this.port = 8642,
    List<String>? allowedIPs,
    bool autoStart = true,
    this.showNotifications = true,
  }) : autoStart = _normalizeAutoStart(autoStart),
       allowedIPs = List.unmodifiable(
         _normalizeAllowedIPs(allowedIPs ?? AppConstants.defaultAllowedIPs),
       );

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final rawAllowedIPs = json['allowedIPs'] as List<dynamic>?;

    return AppConfig(
      port: json['port'] as int? ?? 8642,
      allowedIPs:
          rawAllowedIPs?.whereType<String>().map((ip) => ip.trim()).toList() ??
          AppConstants.defaultAllowedIPs,
      autoStart: json['autoStart'] as bool? ?? true,
      showNotifications: json['showNotifications'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'port': port,
      'allowedIPs': allowedIPs,
      'autoStart': autoStart,
      'showNotifications': showNotifications,
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
    bool? autoStart,
    bool? showNotifications,
  }) {
    return AppConfig(
      port: port ?? this.port,
      allowedIPs: allowedIPs ?? this.allowedIPs,
      autoStart: autoStart ?? this.autoStart,
      showNotifications: showNotifications ?? this.showNotifications,
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

  static bool _normalizeAutoStart(bool _) {
    // Server auto-start is mandatory for current product policy.
    return true;
  }
}
