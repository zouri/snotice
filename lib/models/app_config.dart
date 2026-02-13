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
    this.autoStart = true,
    this.showNotifications = true,
  }) : allowedIPs = List.unmodifiable(
         allowedIPs ?? AppConstants.defaultAllowedIPs,
       );

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      port: json['port'] as int? ?? 8642,
      allowedIPs:
          (json['allowedIPs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
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
}
