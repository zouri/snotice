import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/log_entry.dart';
import '../../services/logger_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
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
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      _scrollController.jumpTo(0);
    });
  }

  void _clearLogs() {
    _logger.clear();
    if (_isPaused) {
      setState(() {
        _visibleLogs = const [];
        _visibleLogCount = 0;
      });
    }
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
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final filteredLogs = _filterLogs(_visibleLogs);
    final isZh = Localizations.localeOf(context).languageCode == 'zh';

    return ColoredBox(
      color: AppColors.workspaceBackgroundFor(brightness),
      child: Column(
        children: [
          PageHeader(
            title: l10n.navCallLogs,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: ShellDimensions.buttonHeight,
                  child: OutlinedButton(
                    onPressed: _togglePause,
                    child: Text(_isPaused ? (isZh ? '恢复' : 'Resume') : (isZh ? '暂停' : 'Pause')),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: ShellDimensions.buttonHeight,
                  child: FilledButton(
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
                  width: 156,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedLevel,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: _levels.map((level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text(
                          level,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelMd,
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
                      border: const OutlineInputBorder(),
                      suffixIcon: _keyword.isEmpty
                          ? const Icon(Icons.search_rounded, size: 18)
                          : IconButton(
                              tooltip: l10n.clear,
                              onPressed: _keywordController.clear,
                              icon: const Icon(Icons.close_rounded, size: 18),
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
              clipBehavior: Clip.antiAlias,
              child: filteredLogs.isEmpty
                  ? Center(
                      child: Text(
                        l10n.callLogsEmpty,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: ListView.separated(
                        controller: _scrollController,
                        itemCount: filteredLogs.length,
                        separatorBuilder: (context, index) {
                          return Divider(
                            color: colorScheme.outlineVariant,
                            height: 1,
                          );
                        },
                        itemBuilder: (context, index) {
                          final entry = filteredLogs[index];
                          final levelColor = _colorForLogType(entry.type);

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _timestampFormat.format(entry.timestamp),
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: levelColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      entry.type.code,
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: levelColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                SelectableText(
                                  entry.message,
                                  style: AppTextStyles.bodyMd.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (entry.data != null &&
                                    entry.data!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  SelectableText(
                                    entry.data.toString(),
                                    style: AppTextStyles.codeSm.copyWith(
                                      color: colorScheme.onSurfaceVariant,
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
      ),
    );
  }
}
