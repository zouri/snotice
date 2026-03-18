import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/server_provider.dart';
import '../../theme/app_animation.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
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
        minimum: const EdgeInsets.fromLTRB(6, 0, 6, 6),
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
            Container(width: 1, color: colorScheme.outlineVariant),
            Expanded(
              child: ColoredBox(
                color: colorScheme.surface,
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
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = colorScheme.outlineVariant;

    return SizedBox(
      width: ShellDimensions.sidebarWidth,
      child: Padding(
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
            const SizedBox(height: 8),
            Divider(color: dividerColor, height: 1),
            const SizedBox(height: 8),
            _SideNavItem(
              label: callLogsLabel,
              active: selectedTab == _ShellTab.callLogs,
              icon: Icons.view_list_rounded,
              onTap: () => onSelect(_ShellTab.callLogs),
            ),
            const SizedBox(height: 6),
            _SideNavItem(
              label: httpApiLabel,
              active: selectedTab == _ShellTab.httpApi,
              icon: Icons.code_rounded,
              onTap: () => onSelect(_ShellTab.httpApi),
            ),
            const SizedBox(height: 6),
            _SideNavItem(
              label: settingsLabel,
              active: selectedTab == _ShellTab.settings,
              icon: Icons.settings_rounded,
              onTap: () => onSelect(_ShellTab.settings),
            ),
            const Spacer(),
            Divider(color: dividerColor, height: 1),
            const SizedBox(height: 8),
            Consumer<ServerProvider>(
              builder: (context, serverProvider, _) {
                final isRunning = serverProvider.isRunning;
                final indicatorColor = isRunning
                    ? AppColors.success
                    : AppColors.error;

                return Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: indicatorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isRunning ? serverRunningLabel : serverStoppedLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelMd.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  const _SideNavItem({
    required this.label,
    required this.active,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool active;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = active
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    final selectedBackground = Color.alphaBlend(
      colorScheme.primary.withValues(
        alpha: colorScheme.brightness == Brightness.dark ? 0.22 : 0.12,
      ),
      colorScheme.surface,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(ShellDimensions.navItemRadius),
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppAnimation.fast,
          curve: AppAnimation.easeOut,
          height: ShellDimensions.navItemHeight,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ShellDimensions.navItemRadius),
            color: active ? selectedBackground : Colors.transparent,
            border: Border.all(
              color: active
                  ? colorScheme.primary.withValues(alpha: 0.45)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: foregroundColor,
                size: ShellDimensions.navIconSize,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontSize: ShellDimensions.navLabelSize,
                    color: foregroundColor,
                    fontWeight: FontWeight.w600,
                  ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 34,
      child: Row(
        children: [
          Icon(
            Icons.notifications_active_outlined,
            color: colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'SNotice',
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.headlineMd.copyWith(
                fontSize: ShellDimensions.brandLabelSize,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
