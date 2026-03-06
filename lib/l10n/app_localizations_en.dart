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
  String get navHttpApi => 'HTTP API';

  @override
  String get navSettings => 'Settings';

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
