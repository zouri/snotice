// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SNotice';

  @override
  String get navCreate => 'Create';

  @override
  String get navReminders => 'Reminders';

  @override
  String get navHistory => 'History';

  @override
  String get navCallLogs => 'Call Logs';

  @override
  String get navHttpApi => 'Usage';

  @override
  String get navSettings => 'Settings';

  @override
  String get httpApiIntroTitle => 'API Overview';

  @override
  String get httpApiIntroBody =>
      'SNotice exposes local HTTP APIs for system notifications and flash alerts. The server listens on localhost and the port can be changed in Settings.';

  @override
  String get httpApiBaseUrlLabel => 'Base URL';

  @override
  String get httpApiContentTypeLabel => 'Content-Type';

  @override
  String get httpApiAuthLabel => 'Authentication';

  @override
  String get httpApiAuthValue =>
      'No authentication currently; use IP whitelist for access control';

  @override
  String get httpApiEndpointListTitle => 'Endpoint List';

  @override
  String get httpApiEndpointMethod => 'Method';

  @override
  String get httpApiEndpointPath => 'Path';

  @override
  String get httpApiEndpointDesc => 'Description';

  @override
  String get httpApiEndpointStatusDesc =>
      'Read server status, returning running state, port, and uptime (seconds)';

  @override
  String get httpApiEndpointNotifyDesc =>
      'Send normal notifications or flash alerts';

  @override
  String get httpApiEndpointGetConfigDesc =>
      'Read current server configuration';

  @override
  String get httpApiEndpointUpdateConfigDesc =>
      'Update server config (port, IP whitelist, notification switch)';

  @override
  String get httpApiNotifyParamsTitle => 'POST /api/notify Parameters';

  @override
  String get httpApiConfigParamsTitle => 'POST /api/config Parameters';

  @override
  String get httpApiParamName => 'Parameter';

  @override
  String get httpApiParamType => 'Type';

  @override
  String get httpApiParamRequired => 'Required';

  @override
  String get httpApiParamDescription => 'Description';

  @override
  String get httpApiRequiredYes => 'Yes';

  @override
  String get httpApiRequiredNo => 'No';

  @override
  String get httpApiRequiredConditional => 'Conditional';

  @override
  String get httpApiParamTitleDesc => 'Notification title. Must not be empty.';

  @override
  String get httpApiParamBodyDesc =>
      'Notification body. Required for normal notifications; optional when category=flash. Alias: message.';

  @override
  String get httpApiParamPriorityDesc =>
      'Notification priority. Allowed: low / normal / high. Default: normal.';

  @override
  String get httpApiParamCategoryDesc =>
      'Notification category. Currently only supports: flash. Alias: type.';

  @override
  String get httpApiParamFlashColorDesc =>
      'Flash color. Supports #RRGGBB or color name. Alias: color. Default: #FF0000.';

  @override
  String get httpApiParamFlashDurationDesc =>
      'Flash duration in milliseconds. Must be > 0. Alias: duration. Default: 500.';

  @override
  String get httpApiParamFlashEffectDesc =>
      'Flash effect. Allowed: full / edge. Alias: effect. Default: full.';

  @override
  String get httpApiParamEdgeWidthDesc =>
      'Edge glow width. Only valid when flashEffect=edge; must be > 0. Alias: width.';

  @override
  String get httpApiParamEdgeOpacityDesc =>
      'Edge glow opacity. Only valid when flashEffect=edge; range 0~1. Alias: opacity.';

  @override
  String get httpApiParamEdgeRepeatDesc =>
      'Edge glow repeat count. Only valid when flashEffect=edge; must be > 0. Alias: repeat.';

  @override
  String get httpApiParamPayloadDesc =>
      'Optional passthrough object that is attached to local notification payload.';

  @override
  String get httpApiParamPortDesc => 'Server port, range 1~65535.';

  @override
  String get httpApiParamAllowedIPsDesc =>
      'Allowed IP list. Supports exact IP and CIDR. Empty list means allow all.';

  @override
  String get httpApiParamAutoStartDesc =>
      'Server auto-start flag. Current product policy forces this to true.';

  @override
  String get httpApiParamShowNotificationsDesc =>
      'Whether system notifications are enabled.';

  @override
  String get httpApiEnumTitle => 'Enum Values';

  @override
  String get httpApiEnumCategory => 'flash: triggers the flash alert flow.';

  @override
  String get httpApiEnumFlashEffect =>
      'full: full-screen flash; edge: edge glow (can combine edgeWidth/edgeOpacity/edgeRepeat).';

  @override
  String get httpApiEnumPriority =>
      'low/normal/high: controls normal notification priority; default is normal.';

  @override
  String get httpApiExampleFlashFull => 'POST /api/notify (flash full)';

  @override
  String get httpApiExampleFlashEdge => 'POST /api/notify (flash edge)';

  @override
  String get httpApiExampleConfigUpdate => 'POST /api/config (update config)';

  @override
  String get httpApiResponseTitle => 'Response Examples';

  @override
  String get httpApiResponseNotifySuccess =>
      'POST /api/notify success response';

  @override
  String get httpApiResponseError => 'Validation error response (HTTP 400)';

  @override
  String get httpApiNotesTitle => 'Notes';

  @override
  String get httpApiNotesAliases =>
      'Some fields accept compatibility aliases (for example body/message, category/type, flashEffect/effect).';

  @override
  String get httpApiNotesBodyOptional =>
      'Only flash notifications allow empty body; normal notifications must include body.';

  @override
  String get httpApiNotesEdgeOnly =>
      'edgeWidth, edgeOpacity, and edgeRepeat are only valid when flashEffect=edge; otherwise validation fails.';

  @override
  String get httpApiEndpoints => 'Endpoints';

  @override
  String get httpApiExamples => 'Examples';

  @override
  String get httpApiNotifyNormal => 'POST /api/notify (normal)';

  @override
  String get httpApiNotifyFlash => 'POST /api/notify (flash)';

  @override
  String get httpApiSampleTitleHello => 'Hello';

  @override
  String get httpApiSampleBodyFromSnotice => 'From SNotice';

  @override
  String get httpApiSampleTitleAlert => 'Alert';

  @override
  String get httpApiSampleBodyFlash => 'Flash';

  @override
  String reminderSetFor(int minutes) {
    return 'Reminder set for $minutes minutes';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSave => 'Save Settings';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get settingsSaveFailed => 'Failed to save settings';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeSubtitle => 'Light, Dark, or follow system';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get serverSettings => 'Server Settings';

  @override
  String get serverPort => 'Port';

  @override
  String get serverPortRequired => 'Please enter a port';

  @override
  String get serverPortInvalid => 'Please enter a valid port (1-65535)';

  @override
  String get serverAutoStart => 'Auto Start';

  @override
  String get serverAutoStartDesc => 'Start server automatically on app launch';

  @override
  String get allowedIPs => 'Allowed IPs';

  @override
  String get addIPAddress => 'Add IP Address';

  @override
  String get ipHint => 'e.g., 127.0.0.1 or 192.168.1.0/24';

  @override
  String get add => 'Add';

  @override
  String get noIPsAdded => 'No IPs added. All IPs will be allowed.';

  @override
  String get ipWhitelistTitle => 'IP Whitelist';

  @override
  String get ipWhitelistInfo =>
      'Only IPs in this list can send notifications. Leave empty to allow all IPs.\n\nYou can use:\n- Exact IP: 127.0.0.1\n- CIDR range: 192.168.1.0/24\n\nCIDR notation allows entire network ranges to be allowed.';

  @override
  String get ok => 'OK';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get showNotifications => 'Show Notifications';

  @override
  String get showNotificationsDesc => 'Display system notifications';

  @override
  String get statusRunning => 'Running';

  @override
  String get statusStopped => 'Stopped';

  @override
  String get close => 'Close';

  @override
  String get toggleFloatingWindow => 'Toggle Floating Window';

  @override
  String get floatingWindowFailed =>
      'Floating window operation failed, please retry or restart the app';

  @override
  String get hideDetailPanel => 'Hide Detail Panel';

  @override
  String get showDetailPanel => 'Show Detail Panel';

  @override
  String get labelTitle => 'Title';

  @override
  String get labelContent => 'Content';

  @override
  String get labelType => 'Type';

  @override
  String get labelScheduledTime => 'Scheduled Time';

  @override
  String get labelCreatedAt => 'Created At';

  @override
  String get labelRepeat => 'Repeat';

  @override
  String get labelTemplate => 'Template';

  @override
  String get labelStatus => 'Status';

  @override
  String get typeFlash => 'Flash';

  @override
  String get typeNotification => 'Notification';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get snooze5Minutes => 'Snooze 5 min';

  @override
  String get cancelReminder => 'Cancel Reminder';

  @override
  String get snoozed5Minutes => 'Snoozed 5 minutes';

  @override
  String get reminderCancelled => 'Reminder cancelled';

  @override
  String get trayStartService => 'Start Service';

  @override
  String get trayStopService => 'Stop Service';

  @override
  String get trayOpenMain => 'Open Main Window';

  @override
  String get trayQuickReminders => 'Quick Reminders';

  @override
  String get trayBreak25 => 'Break (25 min)';

  @override
  String get trayMeeting15 => 'Meeting (15 min)';

  @override
  String get trayMedicine4h => 'Medicine (4h)';

  @override
  String get trayPomodoro => 'Pomodoro (25 min)';

  @override
  String get trayWater => 'Water (30 min)';

  @override
  String get trayStretch => 'Stretch (45 min)';

  @override
  String get trayExit => 'Exit';

  @override
  String get trayServiceRunning => 'Service Running';

  @override
  String get trayServiceNotRunning => 'Service Not Running';

  @override
  String get quickTime => 'Quick Time';

  @override
  String get customTime => 'Custom Time';

  @override
  String minutes(int minutes) {
    return '$minutes min';
  }

  @override
  String hours(int hours) {
    return '${hours}h';
  }

  @override
  String get reminderType => 'Reminder Type';

  @override
  String get notification => 'Notification';

  @override
  String get notificationDesc => 'System notification';

  @override
  String get flashScreen => 'Flash Screen';

  @override
  String get flashScreenDesc => 'Full screen overlay';

  @override
  String get titleRequired => 'Please enter a title';

  @override
  String get message => 'Message';

  @override
  String get messageRequired => 'Please enter a message';

  @override
  String get flashSettings => 'Flash Settings';

  @override
  String get color => 'Color';

  @override
  String duration(int duration) {
    return 'Duration: ${duration}ms';
  }

  @override
  String get noReminderHistory => 'No reminder history';

  @override
  String get clearHistory => 'Clear History';

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String daysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get noActiveReminders => 'No active reminders';

  @override
  String get activeReminders => 'Active Reminders';

  @override
  String created(String name) {
    return 'Created: $name';
  }

  @override
  String get quickCreateReminder => 'Quick Create Reminder';

  @override
  String get noActiveRemindersDesc =>
      'Click quick create above or use templates on the left';

  @override
  String get snooze => 'Snooze';

  @override
  String get cancel => 'Cancel';

  @override
  String get reminderMode => 'Reminder Mode';

  @override
  String get countdownReminder => 'Countdown';

  @override
  String get timeReminder => 'Scheduled Time';

  @override
  String get quickSelectTime => 'Quick Select Time';

  @override
  String get reminderTitle => 'Reminder Title';

  @override
  String get reminderContent => 'Reminder Content';

  @override
  String get reminderContentOptional => 'Reminder content (optional)';

  @override
  String get typeLabel => 'Type:';

  @override
  String get repeatLabel => 'Repeat';

  @override
  String get noRepeat => 'No repeat';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get create => 'Create';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get repeatWeekdays => 'Repeat on weekdays (leave empty for one-time)';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get workdays => 'Workdays';

  @override
  String get everyday => 'Everyday';

  @override
  String get clear => 'Clear';

  @override
  String get callLogsFilterHint => 'Filter conditions';

  @override
  String get callLogsEmpty => 'No call logs yet';

  @override
  String minutesFormat(int minutes) {
    return '$minutes minutes';
  }

  @override
  String hoursFormat(int hours) {
    return '$hours hours';
  }

  @override
  String hoursMinutesFormat(int hours, int minutes) {
    return '$hours hours $minutes minutes';
  }

  @override
  String daysFormat(int days) {
    return '$days days';
  }

  @override
  String get reminder => 'Reminder';

  @override
  String get reminderCreated => 'Reminder created';

  @override
  String get todayStats => 'Today\'s Stats';

  @override
  String get createdStat => 'Created';

  @override
  String get completedStat => 'Completed';

  @override
  String get completionRate => 'Completion Rate';

  @override
  String get last7DaysTrend => 'Last 7 Days Trend';

  @override
  String get noData => 'No data';

  @override
  String get history => 'History';

  @override
  String get clearAll => 'Clear All';

  @override
  String get noHistory => 'No history';

  @override
  String get reminderDetail => 'Reminder Detail';

  @override
  String xMinutesAgo(int minutes) {
    return '$minutes minutes ago';
  }

  @override
  String xHoursAgo(int hours) {
    return '$hours hours ago';
  }

  @override
  String xDaysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get quickTemplates => 'Quick Templates';

  @override
  String get noTemplates => 'No templates';

  @override
  String get customTemplate => 'Custom Template';

  @override
  String get undo => 'Undo';

  @override
  String get templateCreated => 'Template created';

  @override
  String get unfavorite => 'Unfavorite';

  @override
  String get favorite => 'Favorite';

  @override
  String get createCustomTemplate => 'Create Custom Template';

  @override
  String get icon => 'Icon';

  @override
  String get templateName => 'Template Name';

  @override
  String get templateNameHint => 'e.g., Water Reminder';

  @override
  String get templateNameRequired => 'Please enter a name';

  @override
  String get delayTime => 'Delay Time:';

  @override
  String get reminderTitleHint => 'Title shown when reminder triggers';

  @override
  String get reminderContentHint => 'Content shown when reminder triggers';

  @override
  String get save => 'Save';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';
}
