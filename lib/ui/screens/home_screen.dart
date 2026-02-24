import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/server_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../models/reminder.dart';
import '../widgets/home/template_panel.dart';
import '../widgets/home/active_reminders_panel.dart';
import '../widgets/home/history_stats_panel.dart';
import '../settings_screen.dart';

/// Main screen with three-column layout
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showRightPanel = true;
  Reminder? _selectedReminder;

  void _showSnackBar(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWideScreen = width > 1200;
    final isMediumScreen = width > 800 && width <= 1200;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<ServerProvider>(
        builder: (context, serverProvider, _) {
          return Column(
            children: [
              if (serverProvider.lastError != null)
                _ServerErrorBanner(
                  message: serverProvider.lastError!,
                  onClose: serverProvider.clearLastError,
                ),
              Expanded(child: _buildBody(isWideScreen, isMediumScreen)),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      title: Row(
        children: [
          const Icon(Icons.notifications_active),
          const SizedBox(width: 8),
          Text(l10n.appTitle),
        ],
      ),
      actions: [
        // Server status indicator
        Consumer<ServerProvider>(
          builder: (context, serverProvider, _) {
            return _ServerStatusIndicator(
              isRunning: serverProvider.isRunning,
              onTap: () => _showQuickSettings(context),
            );
          },
        ),
        // Right panel toggle button (shown on medium screens)
        if (MediaQuery.of(context).size.width > 800 &&
            MediaQuery.of(context).size.width <= 1200)
          IconButton(
            icon: Icon(
              _showRightPanel ? Icons.visibility_off : Icons.visibility,
            ),
            tooltip: _showRightPanel
                ? l10n.hideDetailPanel
                : l10n.showDetailPanel,
            onPressed: () {
              setState(() {
                _showRightPanel = !_showRightPanel;
              });
            },
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(bool isWideScreen, bool isMediumScreen) {
    if (isWideScreen) {
      // Wide screen: three-column layout
      return _buildThreeColumnLayout();
    } else if (isMediumScreen) {
      // Medium screen: two-column layout
      return _buildTwoColumnLayout();
    } else {
      // Narrow screen: single-column layout
      return _buildSingleColumnLayout();
    }
  }

  /// Three-column layout
  Widget _buildThreeColumnLayout() {
    return Row(
      children: [
        // Left column: quick templates
        const SizedBox(width: 250, child: TemplatePanel()),
        const VerticalDivider(width: 1),
        // Middle column: active reminders
        Expanded(
          child: ActiveRemindersPanel(
            onReminderSelected: (reminder) {
              setState(() {
                _selectedReminder = reminder;
              });
            },
          ),
        ),
        const VerticalDivider(width: 1),
        // Right column: history and stats
        SizedBox(
          width: 300,
          child: HistoryStatsPanel(selectedReminder: _selectedReminder),
        ),
      ],
    );
  }

  /// Two-column layout
  Widget _buildTwoColumnLayout() {
    return Row(
      children: [
        // Left column: quick templates
        const SizedBox(width: 220, child: TemplatePanel()),
        const VerticalDivider(width: 1),
        // Middle column: active reminders
        Expanded(
          child: ActiveRemindersPanel(
            onReminderSelected: (reminder) {
              setState(() {
                _selectedReminder = reminder;
              });
              // On medium screens, show bottom detail sheet
              _showReminderDetailSheet(reminder);
            },
          ),
        ),
      ],
    );
  }

  /// Single-column layout
  Widget _buildSingleColumnLayout() {
    return ActiveRemindersPanel(
      showQuickTemplates: true, // Show quick templates at top
      onReminderSelected: (reminder) {
        _showReminderDetailSheet(reminder);
      },
    );
  }

  void _showQuickSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  void _showReminderDetailSheet(Reminder reminder) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.25,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      reminder.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: _ReminderDetailContent(
                      reminder: reminder,
                      onSnoozed: () => _showSnackBar(l10n.snoozed5Minutes),
                      onCancelled: () => _showSnackBar(l10n.reminderCancelled),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Server status indicator
class _ServerStatusIndicator extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onTap;

  const _ServerStatusIndicator({required this.isRunning, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRunning ? Colors.green : Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: (isRunning ? Colors.green : Colors.red).withValues(
                      alpha: 0.5,
                    ),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isRunning ? l10n.statusRunning : l10n.statusStopped,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const _ServerErrorBanner({required this.message, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return MaterialBanner(
      leading: Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
      backgroundColor: colorScheme.errorContainer,
      content: Text(
        message,
        style: TextStyle(color: colorScheme.onErrorContainer),
      ),
      actions: [
        TextButton(
          onPressed: onClose,
          child: Text(
            l10n.close,
            style: TextStyle(color: colorScheme.onErrorContainer),
          ),
        ),
      ],
    );
  }
}

/// Reminder detail content
class _ReminderDetailContent extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onSnoozed;
  final VoidCallback onCancelled;

  const _ReminderDetailContent({
    required this.reminder,
    required this.onSnoozed,
    required this.onCancelled,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(context, l10n.labelTitle, reminder.title),
        _buildInfoRow(context, l10n.labelContent, reminder.body),
        _buildInfoRow(
          context,
          l10n.labelType,
          reminder.type == 'flash' ? l10n.typeFlash : l10n.typeNotification,
        ),
        _buildInfoRow(
          context,
          l10n.labelScheduledTime,
          _formatDateTime(reminder.scheduledTime),
        ),
        _buildInfoRow(
          context,
          l10n.labelCreatedAt,
          _formatDateTime(reminder.createdAt),
        ),
        if (reminder.repeatRule != null)
          _buildInfoRow(
            context,
            l10n.labelRepeat,
            reminder.repeatRule.toString(),
          ),
        if (reminder.templateId != null)
          _buildInfoRow(context, l10n.labelTemplate, reminder.templateId!),
        const SizedBox(height: 16),
        Consumer<ReminderProvider>(
          builder: (context, provider, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.snooze),
                  label: Text(l10n.snooze5Minutes),
                  onPressed: () {
                    provider.snooze(reminder.id, const Duration(minutes: 5));
                    Navigator.pop(context);
                    onSnoozed();
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: Text(l10n.cancelReminder),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    provider.removeReminder(reminder.id);
                    Navigator.pop(context);
                    onCancelled();
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
