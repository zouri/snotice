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
import 'notification_test_page.dart';

enum _ShellTab { callLogs, httpApi, notificationTest, settings }

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  _ShellTab _currentTab = _ShellTab.callLogs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final l10n = AppLocalizations.of(context)!;
    final windowBackground = AppColors.windowBackgroundFor(brightness);
    final shellBorder = AppColors.shellBorderFor(brightness);

    return Scaffold(
      backgroundColor: windowBackground,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: windowBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: shellBorder),
          ),
          clipBehavior: Clip.antiAlias,
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
                notificationTestLabel: l10n.navNotificationTest,
                settingsLabel: l10n.navSettings,
                serverRunningLabel: l10n.trayServiceRunning,
                serverStoppedLabel: l10n.trayServiceNotRunning,
              ),
              Expanded(
                child: ColoredBox(
                  color: colorScheme.surface,
                  child: IndexedStack(
                    index: _currentTab.index,
                    children: const [
                      CallLogPage(),
                      HttpApiPage(),
                      NotificationTestPage(),
                      HomeScreen(),
                    ],
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

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.selectedTab,
    required this.onSelect,
    required this.callLogsLabel,
    required this.httpApiLabel,
    required this.notificationTestLabel,
    required this.settingsLabel,
    required this.serverRunningLabel,
    required this.serverStoppedLabel,
  });

  final _ShellTab selectedTab;
  final ValueChanged<_ShellTab> onSelect;
  final String callLogsLabel;
  final String httpApiLabel;
  final String notificationTestLabel;
  final String settingsLabel;
  final String serverRunningLabel;
  final String serverStoppedLabel;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final shellBorder = AppColors.shellBorderFor(brightness);

    return Container(
      width: ShellDimensions.sidebarWidth,
      decoration: BoxDecoration(
        color: AppColors.sidebarBackgroundFor(brightness),
        border: Border(right: BorderSide(color: shellBorder)),
      ),
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
            const SizedBox(height: 14),
            _SideNavItem(
              label: callLogsLabel,
              active: selectedTab == _ShellTab.callLogs,
              icon: Icons.bolt_rounded,
              onTap: () => onSelect(_ShellTab.callLogs),
            ),
            const SizedBox(height: 8),
            _SideNavItem(
              label: httpApiLabel,
              active: selectedTab == _ShellTab.httpApi,
              icon: Icons.menu_book_rounded,
              onTap: () => onSelect(_ShellTab.httpApi),
            ),
            const SizedBox(height: 8),
            _SideNavItem(
              label: notificationTestLabel,
              active: selectedTab == _ShellTab.notificationTest,
              icon: Icons.science_rounded,
              onTap: () => onSelect(_ShellTab.notificationTest),
            ),
            const SizedBox(height: 8),
            _SideNavItem(
              label: settingsLabel,
              active: selectedTab == _ShellTab.settings,
              icon: Icons.tune_rounded,
              onTap: () => onSelect(_ShellTab.settings),
            ),
            const Spacer(),
            Consumer<ServerProvider>(
              builder: (context, serverProvider, _) {
                final isRunning = serverProvider.isRunning;
                final indicatorColor = isRunning
                    ? AppColors.successFor(brightness)
                    : AppColors.errorFor(brightness);

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.panelBackgroundFor(brightness),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: shellBorder),
                  ),
                  child: Row(
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
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
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
    final brightness = Theme.of(context).brightness;
    final foregroundColor = active
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(ShellDimensions.navItemRadius),
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppAnimation.fast,
          curve: AppAnimation.easeOut,
          height: ShellDimensions.navItemHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ShellDimensions.navItemRadius),
            color: active
                ? AppColors.sidebarSelectedFor(brightness)
                : Colors.transparent,
            border: Border.all(
              color: active
                  ? colorScheme.primary.withValues(alpha: 0.22)
                  : AppColors.shellBorderFor(brightness),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: foregroundColor,
                size: ShellDimensions.navIconSize,
              ),
              const SizedBox(width: 10),
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
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'SNotice',
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.headlineMd.copyWith(
                fontSize: ShellDimensions.brandLabelSize,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
