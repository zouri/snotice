import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/log_entry.dart';
import '../../services/logger_service.dart';
import '../../theme/app_colors.dart';
import '../widgets/common/page_header.dart';
import '../widgets/main/shell_dimensions.dart';

class CallLogPage extends StatefulWidget {
  const CallLogPage({super.key});

  @override
  State<CallLogPage> createState() => _CallLogPageState();
}

class _CallLogPageState extends State<CallLogPage> {
  static const String _allLevel = 'ALL';
  static final List<String> _levels = [
    _allLevel,
    ...LogType.values.map((type) => type.code),
  ];

  final TextEditingController _keywordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DateFormat _timestampFormat = DateFormat('MM-dd HH:mm:ss');

  late final LoggerService _logger;
  List<LogEntry> _visibleLogs = const [];
  int _visibleLogCount = 0;
  String _selectedLevel = _allLevel;
  String _keyword = '';
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _logger = context.read<LoggerService>();
    _visibleLogs = _logger.logs;
    _visibleLogCount = _visibleLogs.length;
    _logger.addListener(_onLogsChanged);
    _keywordController.addListener(_onKeywordChanged);
  }

  @override
  void dispose() {
    _logger.removeListener(_onLogsChanged);
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

  void _onLogsChanged() {
    if (_isPaused) {
      return;
    }
    _refreshVisibleLogs(scrollToTop: true);
  }

  void _refreshVisibleLogs({bool scrollToTop = false}) {
    final logs = _logger.logs;
    if (logs.length == _visibleLogCount) {
      return;
    }

    setState(() {
      _visibleLogs = logs;
      _visibleLogCount = logs.length;
    });

    if (!scrollToTop) {
      return;
    }

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
    _logger.clear();
    if (!_isPaused) {
      return;
    }

    setState(() {
      _visibleLogs = const [];
      _visibleLogCount = 0;
    });
  }

  void _togglePause() {
    if (_isPaused) {
      setState(() {
        _isPaused = false;
      });
      _refreshVisibleLogs(scrollToTop: true);
      return;
    }

    setState(() {
      _isPaused = true;
    });
  }

  List<LogEntry> _filterLogs(List<LogEntry> logs) {
    final keyword = _keyword.toLowerCase();

    return logs
        .where((entry) {
          final levelMatch =
              _selectedLevel == _allLevel || entry.type.code == _selectedLevel;
          if (!levelMatch) {
            return false;
          }

          if (keyword.isEmpty) {
            return true;
          }

          final message = entry.message.toLowerCase();
          final type = entry.type.code.toLowerCase();
          final data = entry.data?.toString().toLowerCase() ?? '';
          return message.contains(keyword) ||
              type.contains(keyword) ||
              data.contains(keyword);
        })
        .toList()
        .reversed
        .toList();
  }

  Color _colorForLogType(LogType type) {
    switch (type) {
      case LogType.error:
        return AppColors.logError;
      case LogType.warning:
        return AppColors.logWarning;
      case LogType.info:
      case LogType.request:
      case LogType.notification:
      case LogType.debug:
        return AppColors.logInfo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredLogs = _filterLogs(_visibleLogs);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        PageHeader(
          title: l10n.navCallLogs,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _togglePause,
                icon: Icon(
                  _isPaused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_circle_outline,
                  size: 22,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ShellDimensions.radiusSm,
                      ),
                    ),
                  ),
                  onPressed: _clearLogs,
                  child: Text(l10n.clear),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            ShellDimensions.pagePadding,
            0,
            ShellDimensions.pagePadding,
            ShellDimensions.sectionGap,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 148,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedLevel,
                  isExpanded: true,
                  decoration: InputDecoration(
                    isDense: true,
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
                        overflow: TextOverflow.ellipsis,
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
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _keywordController,
                  decoration: InputDecoration(
                    isDense: true,
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
                      horizontal: 10,
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
                          padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
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
                                  const SizedBox(width: 8),
                                  Text(
                                    entry.type.code,
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
                              const SizedBox(height: 3),
                              SelectableText(
                                entry.message,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      fontSize: ShellDimensions.logMessageSize,
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                      height: 1.28,
                                    ),
                              ),
                              if (entry.data != null &&
                                  entry.data!.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                SelectableText(
                                  entry.data.toString(),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontSize: ShellDimensions.codeSize,
                                        color: colorScheme.onSurfaceVariant,
                                        fontFamily: 'monospace',
                                        height: 1.3,
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
