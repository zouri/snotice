import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/server_provider.dart';
import '../widgets/main/shell_dimensions.dart';
import 'call_log_page.dart';
import 'home_screen.dart';
import 'http_api_page.dart';

enum _ShellTab { callLogs, httpApi, settings }

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  _ShellTab _currentTab = _ShellTab.callLogs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Row(
          children: [
            _SideNav(
              selectedTab: _currentTab,
              onSelect: (tab) {
                if (_currentTab == tab) {
                  return;
                }
                setState(() {
                  _currentTab = tab;
                });
              },
              callLogsLabel: l10n.navCallLogs,
              httpApiLabel: l10n.navHttpApi,
              settingsLabel: l10n.navSettings,
              serverRunningLabel: l10n.trayServiceRunning,
              serverStoppedLabel: l10n.trayServiceNotRunning,
            ),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(color: colorScheme.surface),
                child: IndexedStack(
                  index: _currentTab.index,
                  children: const [CallLogPage(), HttpApiPage(), HomeScreen()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.selectedTab,
    required this.onSelect,
    required this.callLogsLabel,
    required this.httpApiLabel,
    required this.settingsLabel,
    required this.serverRunningLabel,
    required this.serverStoppedLabel,
  });

  final _ShellTab selectedTab;
  final ValueChanged<_ShellTab> onSelect;
  final String callLogsLabel;
  final String httpApiLabel;
  final String settingsLabel;
  final String serverRunningLabel;
  final String serverStoppedLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final sidebarBackground = Color.alphaBlend(
      colorScheme.primary.withValues(
        alpha: colorScheme.brightness == Brightness.dark ? 0.14 : 0.06,
      ),
      colorScheme.surface,
    );

    return Container(
      width: ShellDimensions.sidebarWidth,
      decoration: BoxDecoration(
        color: sidebarBackground,
        border: Border(
          right: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        ShellDimensions.sidebarHorizontalPadding,
        ShellDimensions.sidebarTopPadding,
        ShellDimensions.sidebarHorizontalPadding,
        ShellDimensions.sidebarBottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SideNavBrand(),
          const SizedBox(height: 6),
          Divider(color: colorScheme.outlineVariant, height: 1),
          const SizedBox(height: ShellDimensions.sectionGap),
          _SideNavItem(
            label: callLogsLabel,
            active: selectedTab == _ShellTab.callLogs,
            icon: Icons.list_alt_rounded,
            iconColor: const Color(0xFFEE5A24),
            onTap: () => onSelect(_ShellTab.callLogs),
          ),
          const SizedBox(height: ShellDimensions.sectionGap),
          _SideNavItem(
            label: httpApiLabel,
            active: selectedTab == _ShellTab.httpApi,
            icon: Icons.terminal_rounded,
            iconColor: const Color(0xFF2F7CF6),
            onTap: () => onSelect(_ShellTab.httpApi),
          ),
          const SizedBox(height: ShellDimensions.sectionGap),
          _SideNavItem(
            label: settingsLabel,
            active: selectedTab == _ShellTab.settings,
            icon: Icons.settings_rounded,
            iconColor: const Color(0xFF4C6E93),
            onTap: () => onSelect(_ShellTab.settings),
          ),
          const Spacer(),
          Divider(color: colorScheme.outlineVariant, height: 1),
          const SizedBox(height: 10),
          Consumer<ServerProvider>(
            builder: (context, serverProvider, _) {
              final isRunning = serverProvider.isRunning;
              final indicatorColor = isRunning
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444);

              return Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: indicatorColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRunning ? serverRunningLabel : serverStoppedLabel,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: ShellDimensions.metaSize,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  const _SideNavItem({
    required this.label,
    required this.active,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String label;
  final bool active;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = active
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;
    final selectedBackground = Color.alphaBlend(
      colorScheme.primary.withValues(
        alpha: colorScheme.brightness == Brightness.dark ? 0.28 : 0.16,
      ),
      colorScheme.surface,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(ShellDimensions.navItemRadius),
        onTap: onTap,
        child: Ink(
          height: ShellDimensions.navItemHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ShellDimensions.navItemRadius),
            color: active ? selectedBackground : Colors.transparent,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                width: ShellDimensions.navIconContainer,
                height: ShellDimensions.navIconContainer,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: ShellDimensions.navIconSize,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: ShellDimensions.navLabelSize,
                  height: 1.2,
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideNavBrand extends StatelessWidget {
  const _SideNavBrand();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 50,
      child: Row(
        children: [
          Image.asset(
            'assets/icons/tray_icon.png',
            width: 34,
            height: 34,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.notifications_active_rounded,
                color: Theme.of(context).colorScheme.onSurface,
                size: 30,
              );
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'SNotice',
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleLarge?.copyWith(
                fontSize: ShellDimensions.brandLabelSize,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
