import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/log_entry.dart';
import '../../services/logger_service.dart';
import '../../theme/app_colors.dart';
import '../widgets/main/shell_dimensions.dart';

class CallLogPage extends StatefulWidget {
  const CallLogPage({super.key});

  @override
  State<CallLogPage> createState() => _CallLogPageState();
}

class _CallLogPageState extends State<CallLogPage> {
  static const String _allLevel = 'ALL';
  static const List<String> _levels = [
    _allLevel,
    'REQUEST',
    'INFO',
    'NOTIFICATION',
    'WARNING',
    'ERROR',
    'DEBUG',
  ];

  final TextEditingController _keywordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DateFormat _timestampFormat = DateFormat('MM-dd HH:mm:ss');

  Timer? _refreshTimer;
  String _selectedLevel = _allLevel;
  String _keyword = '';
  bool _isPaused = false;
  int _lastLogCount = 0;

  @override
  void initState() {
    super.initState();
    _keywordController.addListener(_onKeywordChanged);
    _refreshTimer = Timer.periodic(
      const Duration(milliseconds: 700),
      (_) => _refreshLogsIfNeeded(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _keywordController
      ..removeListener(_onKeywordChanged)
      ..dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onKeywordChanged() {
    final nextKeyword = _keywordController.text.trim();
    if (nextKeyword == _keyword) {
      return;
    }

    setState(() {
      _keyword = nextKeyword;
    });
  }

  void _refreshLogsIfNeeded() {
    if (!mounted || _isPaused) {
      return;
    }

    final logCount = context.read<LoggerService>().logs.length;
    if (logCount == _lastLogCount) {
      return;
    }

    setState(() {
      _lastLogCount = logCount;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.jumpTo(0);
    });
  }

  void _clearLogs() {
    context.read<LoggerService>().clear();
    setState(() {
      _lastLogCount = 0;
    });
  }

  List<LogEntry> _filterLogs(List<LogEntry> logs) {
    final keyword = _keyword.toLowerCase();

    return logs
        .where((entry) {
          final levelMatch =
              _selectedLevel == _allLevel ||
              entry.type.toUpperCase() == _selectedLevel;
          if (!levelMatch) {
            return false;
          }

          if (keyword.isEmpty) {
            return true;
          }

          final message = entry.message.toLowerCase();
          final type = entry.type.toLowerCase();
          final data = entry.data?.toString().toLowerCase() ?? '';
          return message.contains(keyword) ||
              type.contains(keyword) ||
              data.contains(keyword);
        })
        .toList()
        .reversed
        .toList();
  }

  Color _colorForLogType(String type) {
    switch (type.toUpperCase()) {
      case 'ERROR':
        return AppColors.logError;
      case 'WARNING':
        return AppColors.logWarning;
      case 'INFO':
      case 'REQUEST':
      case 'NOTIFICATION':
      case 'DEBUG':
      default:
        return AppColors.logInfo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final logger = context.read<LoggerService>();
    final filteredLogs = _filterLogs(logger.logs);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _PageHeader(
          title: l10n.navCallLogs,
          isPaused: _isPaused,
          onPauseToggle: () {
            setState(() {
              _isPaused = !_isPaused;
            });
          },
          onClear: _clearLogs,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            ShellDimensions.pagePadding,
            ShellDimensions.pagePadding,
            ShellDimensions.pagePadding,
            ShellDimensions.sectionGap,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 156,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedLevel,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ShellDimensions.radiusSm,
                      ),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ShellDimensions.radiusSm,
                      ),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: ShellDimensions.inputVerticalPadding,
                    ),
                  ),
                  items: _levels.map((level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(
                        level,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: ShellDimensions.metaSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null || value == _selectedLevel) {
                      return;
                    }

                    setState(() {
                      _selectedLevel = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _keywordController,
                  decoration: InputDecoration(
                    hintText: l10n.callLogsFilterHint,
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ShellDimensions.radiusSm,
                      ),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ShellDimensions.radiusSm,
                      ),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: ShellDimensions.inputVerticalPadding,
                    ),
                    suffixIcon: _keyword.isEmpty
                        ? const Icon(Icons.search_rounded)
                        : IconButton(
                            tooltip: l10n.clear,
                            onPressed: () {
                              _keywordController.clear();
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(
              ShellDimensions.pagePadding,
              0,
              ShellDimensions.pagePadding,
              ShellDimensions.pagePadding,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(ShellDimensions.radiusMd),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: filteredLogs.isEmpty
                ? Center(
                    child: Text(
                      l10n.callLogsEmpty,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: ListView.separated(
                      controller: _scrollController,
                      primary: false,
                      itemCount: filteredLogs.length,
                      separatorBuilder: (context, index) =>
                          Divider(color: colorScheme.outlineVariant, height: 1),
                      itemBuilder: (context, index) {
                        final entry = filteredLogs[index];
                        final levelColor = _colorForLogType(entry.type);

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _timestampFormat.format(entry.timestamp),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: ShellDimensions.metaSize,
                                          color: colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    entry.type.toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          fontSize:
                                              ShellDimensions.logLevelSize,
                                          color: levelColor,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.15,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              SelectableText(
                                entry.message,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      fontSize: ShellDimensions.logMessageSize,
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                      height: 1.35,
                                    ),
                              ),
                              if (entry.data != null &&
                                  entry.data!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                SelectableText(
                                  entry.data.toString(),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontSize: ShellDimensions.codeSize,
                                        color: colorScheme.onSurfaceVariant,
                                        fontFamily: 'monospace',
                                      ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.isPaused,
    required this.onPauseToggle,
    required this.onClear,
  });

  final String title;
  final bool isPaused;
  final VoidCallback onPauseToggle;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: ShellDimensions.headerHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: ShellDimensions.headerHorizontalPadding,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
              fontSize: ShellDimensions.pageTitleSize,
              height: 1.2,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onPauseToggle,
            icon: Icon(
              isPaused ? Icons.play_arrow_rounded : Icons.pause_circle_outline,
              size: 26,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            height: ShellDimensions.buttonHeight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                textStyle: textTheme.titleSmall?.copyWith(
                  fontSize: ShellDimensions.buttonTextSize,
                  fontWeight: FontWeight.w700,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ShellDimensions.radiusSm),
                ),
              ),
              onPressed: onClear,
              child: Text(AppLocalizations.of(context)!.clear),
            ),
          ),
        ],
      ),
    );
  }
}
