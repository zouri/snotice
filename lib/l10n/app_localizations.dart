import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'SNotice'**
  String get appTitle;

  /// No description provided for @navCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get navCreate;

  /// No description provided for @navReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get navReminders;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navCallLogs.
  ///
  /// In en, this message translates to:
  /// **'Call Logs'**
  String get navCallLogs;

  /// No description provided for @navHttpApi.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get navHttpApi;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @httpApiIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'API Overview'**
  String get httpApiIntroTitle;

  /// No description provided for @httpApiIntroBody.
  ///
  /// In en, this message translates to:
  /// **'SNotice exposes local HTTP APIs for system notifications and flash alerts. The server listens on localhost and the port can be changed in Settings.'**
  String get httpApiIntroBody;

  /// No description provided for @httpApiBaseUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get httpApiBaseUrlLabel;

  /// No description provided for @httpApiContentTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Content-Type'**
  String get httpApiContentTypeLabel;

  /// No description provided for @httpApiAuthLabel.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get httpApiAuthLabel;

  /// No description provided for @httpApiAuthValue.
  ///
  /// In en, this message translates to:
  /// **'No authentication currently; use IP whitelist for access control'**
  String get httpApiAuthValue;

  /// No description provided for @httpApiEndpointListTitle.
  ///
  /// In en, this message translates to:
  /// **'Endpoint List'**
  String get httpApiEndpointListTitle;

  /// No description provided for @httpApiEndpointMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get httpApiEndpointMethod;

  /// No description provided for @httpApiEndpointPath.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get httpApiEndpointPath;

  /// No description provided for @httpApiEndpointDesc.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get httpApiEndpointDesc;

  /// No description provided for @httpApiEndpointStatusDesc.
  ///
  /// In en, this message translates to:
  /// **'Read server status, returning running state, port, and uptime (seconds)'**
  String get httpApiEndpointStatusDesc;

  /// No description provided for @httpApiEndpointNotifyDesc.
  ///
  /// In en, this message translates to:
  /// **'Send normal notifications or flash alerts'**
  String get httpApiEndpointNotifyDesc;

  /// No description provided for @httpApiEndpointGetConfigDesc.
  ///
  /// In en, this message translates to:
  /// **'Read current server configuration'**
  String get httpApiEndpointGetConfigDesc;

  /// No description provided for @httpApiEndpointUpdateConfigDesc.
  ///
  /// In en, this message translates to:
  /// **'Update server config (port, IP whitelist, notification switch)'**
  String get httpApiEndpointUpdateConfigDesc;

  /// No description provided for @httpApiNotifyParamsTitle.
  ///
  /// In en, this message translates to:
  /// **'POST /api/notify Parameters'**
  String get httpApiNotifyParamsTitle;

  /// No description provided for @httpApiConfigParamsTitle.
  ///
  /// In en, this message translates to:
  /// **'POST /api/config Parameters'**
  String get httpApiConfigParamsTitle;

  /// No description provided for @httpApiParamName.
  ///
  /// In en, this message translates to:
  /// **'Parameter'**
  String get httpApiParamName;

  /// No description provided for @httpApiParamType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get httpApiParamType;

  /// No description provided for @httpApiParamRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get httpApiParamRequired;

  /// No description provided for @httpApiParamDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get httpApiParamDescription;

  /// No description provided for @httpApiRequiredYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get httpApiRequiredYes;

  /// No description provided for @httpApiRequiredNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get httpApiRequiredNo;

  /// No description provided for @httpApiRequiredConditional.
  ///
  /// In en, this message translates to:
  /// **'Conditional'**
  String get httpApiRequiredConditional;

  /// No description provided for @httpApiParamTitleDesc.
  ///
  /// In en, this message translates to:
  /// **'Notification title. Must not be empty.'**
  String get httpApiParamTitleDesc;

  /// No description provided for @httpApiParamBodyDesc.
  ///
  /// In en, this message translates to:
  /// **'Notification body. Required for normal notifications; optional when category=flash. Alias: message.'**
  String get httpApiParamBodyDesc;

  /// No description provided for @httpApiParamPriorityDesc.
  ///
  /// In en, this message translates to:
  /// **'Notification priority. Allowed: low / normal / high. Default: normal.'**
  String get httpApiParamPriorityDesc;

  /// No description provided for @httpApiParamCategoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Notification category. Currently only supports: flash. Alias: type.'**
  String get httpApiParamCategoryDesc;

  /// No description provided for @httpApiParamFlashColorDesc.
  ///
  /// In en, this message translates to:
  /// **'Flash color. Supports #RRGGBB or color name. Alias: color. Default: #FF0000.'**
  String get httpApiParamFlashColorDesc;

  /// No description provided for @httpApiParamFlashDurationDesc.
  ///
  /// In en, this message translates to:
  /// **'Flash duration in milliseconds. Must be > 0. Alias: duration. Default: 500.'**
  String get httpApiParamFlashDurationDesc;

  /// No description provided for @httpApiParamFlashEffectDesc.
  ///
  /// In en, this message translates to:
  /// **'Flash effect. Allowed: full / edge. Alias: effect. Default: full.'**
  String get httpApiParamFlashEffectDesc;

  /// No description provided for @httpApiParamEdgeWidthDesc.
  ///
  /// In en, this message translates to:
  /// **'Edge glow width. Only valid when flashEffect=edge; must be > 0. Alias: width.'**
  String get httpApiParamEdgeWidthDesc;

  /// No description provided for @httpApiParamEdgeOpacityDesc.
  ///
  /// In en, this message translates to:
  /// **'Edge glow opacity. Only valid when flashEffect=edge; range 0~1. Alias: opacity.'**
  String get httpApiParamEdgeOpacityDesc;

  /// No description provided for @httpApiParamEdgeRepeatDesc.
  ///
  /// In en, this message translates to:
  /// **'Edge glow repeat count. Only valid when flashEffect=edge; must be > 0. Alias: repeat.'**
  String get httpApiParamEdgeRepeatDesc;

  /// No description provided for @httpApiParamPayloadDesc.
  ///
  /// In en, this message translates to:
  /// **'Optional passthrough object that is attached to local notification payload.'**
  String get httpApiParamPayloadDesc;

  /// No description provided for @httpApiParamPortDesc.
  ///
  /// In en, this message translates to:
  /// **'Server port, range 1~65535.'**
  String get httpApiParamPortDesc;

  /// No description provided for @httpApiParamAllowedIPsDesc.
  ///
  /// In en, this message translates to:
  /// **'Allowed IP list. Supports exact IP and CIDR. Empty list means allow all.'**
  String get httpApiParamAllowedIPsDesc;

  /// No description provided for @httpApiParamAutoStartDesc.
  ///
  /// In en, this message translates to:
  /// **'Server auto-start flag. Current product policy forces this to true.'**
  String get httpApiParamAutoStartDesc;

  /// No description provided for @httpApiParamShowNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Whether system notifications are enabled.'**
  String get httpApiParamShowNotificationsDesc;

  /// No description provided for @httpApiEnumTitle.
  ///
  /// In en, this message translates to:
  /// **'Enum Values'**
  String get httpApiEnumTitle;

  /// No description provided for @httpApiEnumCategory.
  ///
  /// In en, this message translates to:
  /// **'flash: triggers the flash alert flow.'**
  String get httpApiEnumCategory;

  /// No description provided for @httpApiEnumFlashEffect.
  ///
  /// In en, this message translates to:
  /// **'full: full-screen flash; edge: edge glow (can combine edgeWidth/edgeOpacity/edgeRepeat).'**
  String get httpApiEnumFlashEffect;

  /// No description provided for @httpApiEnumPriority.
  ///
  /// In en, this message translates to:
  /// **'low/normal/high: controls normal notification priority; default is normal.'**
  String get httpApiEnumPriority;

  /// No description provided for @httpApiExampleFlashFull.
  ///
  /// In en, this message translates to:
  /// **'POST /api/notify (flash full)'**
  String get httpApiExampleFlashFull;

  /// No description provided for @httpApiExampleFlashEdge.
  ///
  /// In en, this message translates to:
  /// **'POST /api/notify (flash edge)'**
  String get httpApiExampleFlashEdge;

  /// No description provided for @httpApiExampleConfigUpdate.
  ///
  /// In en, this message translates to:
  /// **'POST /api/config (update config)'**
  String get httpApiExampleConfigUpdate;

  /// No description provided for @httpApiResponseTitle.
  ///
  /// In en, this message translates to:
  /// **'Response Examples'**
  String get httpApiResponseTitle;

  /// No description provided for @httpApiResponseNotifySuccess.
  ///
  /// In en, this message translates to:
  /// **'POST /api/notify success response'**
  String get httpApiResponseNotifySuccess;

  /// No description provided for @httpApiResponseError.
  ///
  /// In en, this message translates to:
  /// **'Validation error response (HTTP 400)'**
  String get httpApiResponseError;

  /// No description provided for @httpApiNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get httpApiNotesTitle;

  /// No description provided for @httpApiNotesAliases.
  ///
  /// In en, this message translates to:
  /// **'Some fields accept compatibility aliases (for example body/message, category/type, flashEffect/effect).'**
  String get httpApiNotesAliases;

  /// No description provided for @httpApiNotesBodyOptional.
  ///
  /// In en, this message translates to:
  /// **'Only flash notifications allow empty body; normal notifications must include body.'**
  String get httpApiNotesBodyOptional;

  /// No description provided for @httpApiNotesEdgeOnly.
  ///
  /// In en, this message translates to:
  /// **'edgeWidth, edgeOpacity, and edgeRepeat are only valid when flashEffect=edge; otherwise validation fails.'**
  String get httpApiNotesEdgeOnly;

  /// No description provided for @httpApiEndpoints.
  ///
  /// In en, this message translates to:
  /// **'Endpoints'**
  String get httpApiEndpoints;

  /// No description provided for @httpApiExamples.
  ///
  /// In en, this message translates to:
  /// **'Examples'**
  String get httpApiExamples;

  /// No description provided for @httpApiNotifyNormal.
  ///
  /// In en, this message translates to:
  /// **'POST /api/notify (normal)'**
  String get httpApiNotifyNormal;

  /// No description provided for @httpApiNotifyFlash.
  ///
  /// In en, this message translates to:
  /// **'POST /api/notify (flash)'**
  String get httpApiNotifyFlash;

  /// No description provided for @httpApiSampleTitleHello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get httpApiSampleTitleHello;

  /// No description provided for @httpApiSampleBodyFromSnotice.
  ///
  /// In en, this message translates to:
  /// **'From SNotice'**
  String get httpApiSampleBodyFromSnotice;

  /// No description provided for @httpApiSampleTitleAlert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get httpApiSampleTitleAlert;

  /// No description provided for @httpApiSampleBodyFlash.
  ///
  /// In en, this message translates to:
  /// **'Flash'**
  String get httpApiSampleBodyFlash;

  /// Confirmation message when reminder is set
  ///
  /// In en, this message translates to:
  /// **'Reminder set for {minutes} minutes'**
  String reminderSetFor(int minutes);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get settingsSave;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @settingsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save settings'**
  String get settingsSaveFailed;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @themeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Light, Dark, or follow system'**
  String get themeSubtitle;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @serverSettings.
  ///
  /// In en, this message translates to:
  /// **'Server Settings'**
  String get serverSettings;

  /// No description provided for @serverPort.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get serverPort;

  /// No description provided for @serverPortRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a port'**
  String get serverPortRequired;

  /// No description provided for @serverPortInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid port (1-65535)'**
  String get serverPortInvalid;

  /// No description provided for @serverAutoStart.
  ///
  /// In en, this message translates to:
  /// **'Auto Start'**
  String get serverAutoStart;

  /// No description provided for @serverAutoStartDesc.
  ///
  /// In en, this message translates to:
  /// **'Start server automatically on app launch'**
  String get serverAutoStartDesc;

  /// No description provided for @allowedIPs.
  ///
  /// In en, this message translates to:
  /// **'Allowed IPs'**
  String get allowedIPs;

  /// No description provided for @addIPAddress.
  ///
  /// In en, this message translates to:
  /// **'Add IP Address'**
  String get addIPAddress;

  /// No description provided for @ipHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 127.0.0.1 or 192.168.1.0/24'**
  String get ipHint;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @noIPsAdded.
  ///
  /// In en, this message translates to:
  /// **'No IPs added. All IPs will be allowed.'**
  String get noIPsAdded;

  /// No description provided for @ipWhitelistTitle.
  ///
  /// In en, this message translates to:
  /// **'IP Whitelist'**
  String get ipWhitelistTitle;

  /// No description provided for @ipWhitelistInfo.
  ///
  /// In en, this message translates to:
  /// **'Only IPs in this list can send notifications. Leave empty to allow all IPs.\n\nYou can use:\n- Exact IP: 127.0.0.1\n- CIDR range: 192.168.1.0/24\n\nCIDR notation allows entire network ranges to be allowed.'**
  String get ipWhitelistInfo;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @showNotifications.
  ///
  /// In en, this message translates to:
  /// **'Show Notifications'**
  String get showNotifications;

  /// No description provided for @showNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Display system notifications'**
  String get showNotificationsDesc;

  /// No description provided for @statusRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get statusRunning;

  /// No description provided for @statusStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get statusStopped;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @toggleFloatingWindow.
  ///
  /// In en, this message translates to:
  /// **'Toggle Floating Window'**
  String get toggleFloatingWindow;

  /// No description provided for @floatingWindowFailed.
  ///
  /// In en, this message translates to:
  /// **'Floating window operation failed, please retry or restart the app'**
  String get floatingWindowFailed;

  /// No description provided for @hideDetailPanel.
  ///
  /// In en, this message translates to:
  /// **'Hide Detail Panel'**
  String get hideDetailPanel;

  /// No description provided for @showDetailPanel.
  ///
  /// In en, this message translates to:
  /// **'Show Detail Panel'**
  String get showDetailPanel;

  /// No description provided for @labelTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get labelTitle;

  /// No description provided for @labelContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get labelContent;

  /// No description provided for @labelType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get labelType;

  /// No description provided for @labelScheduledTime.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Time'**
  String get labelScheduledTime;

  /// No description provided for @labelCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get labelCreatedAt;

  /// No description provided for @labelRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get labelRepeat;

  /// No description provided for @labelTemplate.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get labelTemplate;

  /// No description provided for @labelStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get labelStatus;

  /// No description provided for @typeFlash.
  ///
  /// In en, this message translates to:
  /// **'Flash'**
  String get typeFlash;

  /// No description provided for @typeNotification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get typeNotification;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @snooze5Minutes.
  ///
  /// In en, this message translates to:
  /// **'Snooze 5 min'**
  String get snooze5Minutes;

  /// No description provided for @cancelReminder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Reminder'**
  String get cancelReminder;

  /// No description provided for @snoozed5Minutes.
  ///
  /// In en, this message translates to:
  /// **'Snoozed 5 minutes'**
  String get snoozed5Minutes;

  /// No description provided for @reminderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Reminder cancelled'**
  String get reminderCancelled;

  /// No description provided for @trayStartService.
  ///
  /// In en, this message translates to:
  /// **'Start Service'**
  String get trayStartService;

  /// No description provided for @trayStopService.
  ///
  /// In en, this message translates to:
  /// **'Stop Service'**
  String get trayStopService;

  /// No description provided for @trayOpenMain.
  ///
  /// In en, this message translates to:
  /// **'Open Main Window'**
  String get trayOpenMain;

  /// No description provided for @trayQuickReminders.
  ///
  /// In en, this message translates to:
  /// **'Quick Reminders'**
  String get trayQuickReminders;

  /// No description provided for @trayBreak25.
  ///
  /// In en, this message translates to:
  /// **'Break (25 min)'**
  String get trayBreak25;

  /// No description provided for @trayMeeting15.
  ///
  /// In en, this message translates to:
  /// **'Meeting (15 min)'**
  String get trayMeeting15;

  /// No description provided for @trayMedicine4h.
  ///
  /// In en, this message translates to:
  /// **'Medicine (4h)'**
  String get trayMedicine4h;

  /// No description provided for @trayPomodoro.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro (25 min)'**
  String get trayPomodoro;

  /// No description provided for @trayWater.
  ///
  /// In en, this message translates to:
  /// **'Water (30 min)'**
  String get trayWater;

  /// No description provided for @trayStretch.
  ///
  /// In en, this message translates to:
  /// **'Stretch (45 min)'**
  String get trayStretch;

  /// No description provided for @trayExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get trayExit;

  /// No description provided for @trayServiceRunning.
  ///
  /// In en, this message translates to:
  /// **'Service Running'**
  String get trayServiceRunning;

  /// No description provided for @trayServiceNotRunning.
  ///
  /// In en, this message translates to:
  /// **'Service Not Running'**
  String get trayServiceNotRunning;

  /// No description provided for @quickTime.
  ///
  /// In en, this message translates to:
  /// **'Quick Time'**
  String get quickTime;

  /// No description provided for @customTime.
  ///
  /// In en, this message translates to:
  /// **'Custom Time'**
  String get customTime;

  /// Minutes display
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutes(int minutes);

  /// Hours display
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String hours(int hours);

  /// No description provided for @reminderType.
  ///
  /// In en, this message translates to:
  /// **'Reminder Type'**
  String get reminderType;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @notificationDesc.
  ///
  /// In en, this message translates to:
  /// **'System notification'**
  String get notificationDesc;

  /// No description provided for @flashScreen.
  ///
  /// In en, this message translates to:
  /// **'Flash Screen'**
  String get flashScreen;

  /// No description provided for @flashScreenDesc.
  ///
  /// In en, this message translates to:
  /// **'Full screen overlay'**
  String get flashScreenDesc;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get titleRequired;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @messageRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a message'**
  String get messageRequired;

  /// No description provided for @flashSettings.
  ///
  /// In en, this message translates to:
  /// **'Flash Settings'**
  String get flashSettings;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// Flash duration display
  ///
  /// In en, this message translates to:
  /// **'Duration: {duration}ms'**
  String duration(int duration);

  /// No description provided for @noReminderHistory.
  ///
  /// In en, this message translates to:
  /// **'No reminder history'**
  String get noReminderHistory;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// Minutes ago display
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(int minutes);

  /// Hours ago display
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(int hours);

  /// Days ago display
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(int days);

  /// No description provided for @noActiveReminders.
  ///
  /// In en, this message translates to:
  /// **'No active reminders'**
  String get noActiveReminders;

  /// No description provided for @activeReminders.
  ///
  /// In en, this message translates to:
  /// **'Active Reminders'**
  String get activeReminders;

  /// Created message
  ///
  /// In en, this message translates to:
  /// **'Created: {name}'**
  String created(String name);

  /// No description provided for @quickCreateReminder.
  ///
  /// In en, this message translates to:
  /// **'Quick Create Reminder'**
  String get quickCreateReminder;

  /// No description provided for @noActiveRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Click quick create above or use templates on the left'**
  String get noActiveRemindersDesc;

  /// No description provided for @snooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get snooze;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @reminderMode.
  ///
  /// In en, this message translates to:
  /// **'Reminder Mode'**
  String get reminderMode;

  /// No description provided for @countdownReminder.
  ///
  /// In en, this message translates to:
  /// **'Countdown'**
  String get countdownReminder;

  /// No description provided for @timeReminder.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Time'**
  String get timeReminder;

  /// No description provided for @quickSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Quick Select Time'**
  String get quickSelectTime;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder Title'**
  String get reminderTitle;

  /// No description provided for @reminderContent.
  ///
  /// In en, this message translates to:
  /// **'Reminder Content'**
  String get reminderContent;

  /// No description provided for @reminderContentOptional.
  ///
  /// In en, this message translates to:
  /// **'Reminder content (optional)'**
  String get reminderContentOptional;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type:'**
  String get typeLabel;

  /// No description provided for @repeatLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatLabel;

  /// No description provided for @noRepeat.
  ///
  /// In en, this message translates to:
  /// **'No repeat'**
  String get noRepeat;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// No description provided for @repeatWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Repeat on weekdays (leave empty for one-time)'**
  String get repeatWeekdays;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;

  /// No description provided for @workdays.
  ///
  /// In en, this message translates to:
  /// **'Workdays'**
  String get workdays;

  /// No description provided for @everyday.
  ///
  /// In en, this message translates to:
  /// **'Everyday'**
  String get everyday;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @callLogsFilterHint.
  ///
  /// In en, this message translates to:
  /// **'Filter conditions'**
  String get callLogsFilterHint;

  /// No description provided for @callLogsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No call logs yet'**
  String get callLogsEmpty;

  /// Minutes format
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String minutesFormat(int minutes);

  /// Hours format
  ///
  /// In en, this message translates to:
  /// **'{hours} hours'**
  String hoursFormat(int hours);

  /// Hours and minutes format
  ///
  /// In en, this message translates to:
  /// **'{hours} hours {minutes} minutes'**
  String hoursMinutesFormat(int hours, int minutes);

  /// Days format
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String daysFormat(int days);

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @reminderCreated.
  ///
  /// In en, this message translates to:
  /// **'Reminder created'**
  String get reminderCreated;

  /// No description provided for @todayStats.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Stats'**
  String get todayStats;

  /// No description provided for @createdStat.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdStat;

  /// No description provided for @completedStat.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedStat;

  /// No description provided for @completionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get completionRate;

  /// No description provided for @last7DaysTrend.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days Trend'**
  String get last7DaysTrend;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No history'**
  String get noHistory;

  /// No description provided for @reminderDetail.
  ///
  /// In en, this message translates to:
  /// **'Reminder Detail'**
  String get reminderDetail;

  /// X minutes ago
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String xMinutesAgo(int minutes);

  /// X hours ago
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String xHoursAgo(int hours);

  /// X days ago
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String xDaysAgo(int days);

  /// No description provided for @quickTemplates.
  ///
  /// In en, this message translates to:
  /// **'Quick Templates'**
  String get quickTemplates;

  /// No description provided for @noTemplates.
  ///
  /// In en, this message translates to:
  /// **'No templates'**
  String get noTemplates;

  /// No description provided for @customTemplate.
  ///
  /// In en, this message translates to:
  /// **'Custom Template'**
  String get customTemplate;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @templateCreated.
  ///
  /// In en, this message translates to:
  /// **'Template created'**
  String get templateCreated;

  /// No description provided for @unfavorite.
  ///
  /// In en, this message translates to:
  /// **'Unfavorite'**
  String get unfavorite;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @createCustomTemplate.
  ///
  /// In en, this message translates to:
  /// **'Create Custom Template'**
  String get createCustomTemplate;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @templateName.
  ///
  /// In en, this message translates to:
  /// **'Template Name'**
  String get templateName;

  /// No description provided for @templateNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Water Reminder'**
  String get templateNameHint;

  /// No description provided for @templateNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get templateNameRequired;

  /// No description provided for @delayTime.
  ///
  /// In en, this message translates to:
  /// **'Delay Time:'**
  String get delayTime;

  /// No description provided for @reminderTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title shown when reminder triggers'**
  String get reminderTitleHint;

  /// No description provided for @reminderContentHint.
  ///
  /// In en, this message translates to:
  /// **'Content shown when reminder triggers'**
  String get reminderContentHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageChinese;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
