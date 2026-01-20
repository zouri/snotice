import 'dart:io';

class IPUtils {
  static bool isIPInCIDR(String ip, String cidr) {
    try {
      final parts = cidr.split('/');
      if (parts.length != 2) {
        return false;
      }

      final networkIp = parts[0];
      final prefixLength = int.parse(parts[1]);

      final ipAddr = InternetAddress(ip);
      final networkAddr = InternetAddress(networkIp);

      if (ipAddr.type != networkAddr.type) {
        return false;
      }

      if (ipAddr.type == InternetAddressType.IPv4) {
        return _isIPv4InCIDR(ip, networkIp, prefixLength);
      } else if (ipAddr.type == InternetAddressType.IPv6) {
        return _isIPv6InCIDR(ip, networkIp, prefixLength);
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  static bool isCIDRFormat(String cidr) {
    final parts = cidr.split('/');
    if (parts.length != 2) return false;

    try {
      final prefixLength = int.parse(parts[1]);
      if (prefixLength < 0) return false;

      final ip = InternetAddress(parts[0]);
      if (ip.type == InternetAddressType.IPv4) {
        return prefixLength <= 32;
      } else if (ip.type == InternetAddressType.IPv6) {
        return prefixLength <= 128;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static bool isValidIPFormat(String ip) {
    try {
      InternetAddress(ip);
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool _isIPv4InCIDR(String ip, String network, int prefixLength) {
    final ipNum = _ipv4ToInt(ip);
    final networkNum = _ipv4ToInt(network);

    if (prefixLength >= 32) {
      return ipNum == networkNum;
    }

    final mask = ~(0xFFFFFFFF >> prefixLength);
    return (ipNum & mask) == (networkNum & mask);
  }

  static bool _isIPv6InCIDR(String ip, String network, int prefixLength) {
    final ipBytes = InternetAddress(ip).rawAddress;
    final networkBytes = InternetAddress(network).rawAddress;

    if (prefixLength >= 128) {
      return _bytesEqual(ipBytes, networkBytes);
    }

    final fullBytes = prefixLength ~/ 8;
    final remainingBits = prefixLength % 8;

    for (int i = 0; i < fullBytes; i++) {
      if (ipBytes[i] != networkBytes[i]) {
        return false;
      }
    }

    if (remainingBits > 0 && fullBytes < 16) {
      final mask = ~(0xFF >> remainingBits) & 0xFF;
      if ((ipBytes[fullBytes] & mask) != (networkBytes[fullBytes] & mask)) {
        return false;
      }
    }

    return true;
  }

  static int _ipv4ToInt(String ip) {
    final parts = ip.split('.');
    int result = 0;
    for (final part in parts) {
      result = result * 256 + int.parse(part);
    }
    return result;
  }

  static bool _bytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
