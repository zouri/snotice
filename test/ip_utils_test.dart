import 'package:flutter_test/flutter_test.dart';
import '../lib/utils/ip_utils.dart';
import '../lib/models/app_config.dart';

void main() {
  group('IPUtils Tests', () {
    test('isValidIPFormat should validate correct IPs', () {
      expect(IPUtils.isValidIPFormat('127.0.0.1'), true);
      expect(IPUtils.isValidIPFormat('192.168.1.1'), true);
      expect(IPUtils.isValidIPFormat('::1'), true);
      expect(IPUtils.isValidIPFormat('2001:db8::1'), true);
      expect(IPUtils.isValidIPFormat('invalid'), false);
    });

    test('isCIDRFormat should detect CIDR notation', () {
      expect(IPUtils.isCIDRFormat('192.168.1.0/24'), true);
      expect(IPUtils.isCIDRFormat('10.0.0.0/8'), true);
      expect(IPUtils.isCIDRFormat('::/0'), true);
      expect(IPUtils.isCIDRFormat('127.0.0.1'), false);
      expect(IPUtils.isCIDRFormat('invalid'), false);
    });

    test('isIPInCIDR should match IPv4 ranges', () {
      expect(IPUtils.isIPInCIDR('192.168.1.100', '192.168.1.0/24'), true);
      expect(IPUtils.isIPInCIDR('192.168.1.1', '192.168.1.0/24'), true);
      expect(IPUtils.isIPInCIDR('192.168.1.255', '192.168.1.0/24'), true);
      expect(IPUtils.isIPInCIDR('192.168.2.1', '192.168.1.0/24'), false);

      expect(IPUtils.isIPInCIDR('10.5.3.2', '10.0.0.0/8'), true);
      expect(IPUtils.isIPInCIDR('10.255.255.255', '10.0.0.0/8'), true);
      expect(IPUtils.isIPInCIDR('11.0.0.1', '10.0.0.0/8'), false);
    });

    test('isIPInCIDR should handle exact matches (/32)', () {
      expect(IPUtils.isIPInCIDR('127.0.0.1', '127.0.0.1/32'), true);
      expect(IPUtils.isIPInCIDR('127.0.0.2', '127.0.0.1/32'), false);
    });

    test('isIPInCIDR should match IPv6 ranges', () {
      expect(IPUtils.isIPInCIDR('::1', '::/0'), true);
      expect(IPUtils.isIPInCIDR('::1', '::1/128'), true);
      expect(IPUtils.isIPInCIDR('::1', '2001:db8::/32'), false);
      expect(IPUtils.isIPInCIDR('2001:db8::1', '2001:db8::/32'), true);
    });
  });

  group('AppConfig isIPAllowed Tests', () {
    test('should allow all IPs when list is empty', () {
      final config = AppConfig(allowedIPs: []);
      expect(config.isIPAllowed('192.168.1.1'), true);
      expect(config.isIPAllowed('10.0.0.1'), true);
    });

    test('should match exact IPs', () {
      final config = AppConfig(allowedIPs: ['127.0.0.1', '192.168.1.1']);
      expect(config.isIPAllowed('127.0.0.1'), true);
      expect(config.isIPAllowed('192.168.1.1'), true);
      expect(config.isIPAllowed('192.168.1.2'), false);
    });

    test('should match CIDR ranges', () {
      final config = AppConfig(allowedIPs: ['192.168.1.0/24', '10.0.0.0/8']);
      expect(config.isIPAllowed('192.168.1.100'), true);
      expect(config.isIPAllowed('192.168.1.1'), true);
      expect(config.isIPAllowed('192.168.1.255'), true);
      expect(config.isIPAllowed('192.168.2.1'), false);

      expect(config.isIPAllowed('10.5.3.2'), true);
      expect(config.isIPAllowed('10.255.255.255'), true);
      expect(config.isIPAllowed('11.0.0.1'), false);
    });

    test('should support mixed exact IPs and CIDR ranges', () {
      final config = AppConfig(allowedIPs: ['127.0.0.1', '192.168.1.0/24']);
      expect(config.isIPAllowed('127.0.0.1'), true);
      expect(config.isIPAllowed('127.0.0.2'), false);

      expect(config.isIPAllowed('192.168.1.100'), true);
      expect(config.isIPAllowed('192.168.2.1'), false);
    });

    test('should reject unmatched IPs', () {
      final config = AppConfig(allowedIPs: ['192.168.1.0/24']);
      expect(config.isIPAllowed('172.16.0.1'), false);
      expect(config.isIPAllowed('10.0.0.1'), false);
    });
  });
}
