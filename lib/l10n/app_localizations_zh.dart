// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'SNotice';

  @override
  String get navCreate => '创建';

  @override
  String get navReminders => '提醒';

  @override
  String get navHistory => '历史';

  @override
  String get navCallLogs => '调用日志';

  @override
  String get navHttpApi => '使用说明';

  @override
  String get navSettings => '设置';

  @override
  String get httpApiIntroTitle => 'API 概览';

  @override
  String get httpApiIntroBody =>
      'SNotice 提供 HTTP 接口用于触发系统通知、闪屏提醒和弹幕覆盖提醒。服务监听在当前配置端口，可在设置页调整。';

  @override
  String get httpApiBaseUrlLabel => 'Base URL';

  @override
  String get httpApiContentTypeLabel => 'Content-Type';

  @override
  String get httpApiAuthLabel => '认证方式';

  @override
  String get httpApiAuthValue => '当前无鉴权，任何可访问到该服务的 IP 都可以调用。';

  @override
  String get httpApiEndpointListTitle => '接口清单';

  @override
  String get httpApiEndpointMethod => '方法';

  @override
  String get httpApiEndpointPath => '路径';

  @override
  String get httpApiEndpointDesc => '说明';

  @override
  String get httpApiEndpointStatusDesc => '读取服务状态，返回运行状态、端口、运行时长（秒）';

  @override
  String get httpApiEndpointNotifyDesc => '发送普通通知、闪屏提醒或弹幕覆盖提醒';

  @override
  String get httpApiMcpSectionTitle => 'MCP 使用说明';

  @override
  String get httpApiMcpEndpointTitle => 'MCP Endpoint';

  @override
  String get httpApiMcpToolsTitle => '内置工具';

  @override
  String get httpApiMcpExampleListTitle => 'MCP tools/list 示例';

  @override
  String get httpApiMcpExampleCallTitle => 'MCP tools/call 示例（读取状态）';

  @override
  String get httpApiNotifyParamsTitle => 'POST /api/notify 参数';

  @override
  String get httpApiParamName => '参数';

  @override
  String get httpApiParamType => '类型';

  @override
  String get httpApiParamRequired => '必填';

  @override
  String get httpApiParamDescription => '说明';

  @override
  String get httpApiRequiredYes => '是';

  @override
  String get httpApiRequiredNo => '否';

  @override
  String get httpApiRequiredConditional => '条件必填';

  @override
  String get httpApiParamTitleDesc => '通知标题。不能为空。';

  @override
  String get httpApiParamBodyDesc =>
      '通知消息内容。普通通知必填；当 category=flash_full / flash_edge / barrage 时可为空。';

  @override
  String get httpApiParamPriorityDesc =>
      '通知优先级。可选: low / normal / high。默认: normal。';

  @override
  String get httpApiParamCategoryDesc =>
      '通知类别。可选: flash_full / flash_edge / barrage。';

  @override
  String get httpApiParamFlashColorDesc => '闪屏颜色。支持 #RRGGBB 或颜色名。默认: #FF0000。';

  @override
  String get httpApiParamFlashDurationDesc => '闪屏时长（毫秒）。必须 > 0。默认: 500。';

  @override
  String get httpApiParamEdgeWidthDesc =>
      '边缘发光宽度，仅 category=flash_edge 时有效，必须 > 0。';

  @override
  String get httpApiParamEdgeOpacityDesc =>
      '边缘发光透明度，仅 category=flash_edge 时有效，范围 0~1。';

  @override
  String get httpApiParamEdgeRepeatDesc =>
      '边缘发光重复次数，仅 category=flash_edge 时有效，必须 > 0。';

  @override
  String get httpApiParamBarrageRepeatDesc =>
      '弹幕重复条数，仅 category=barrage 时有效，范围 1~8。';

  @override
  String get httpApiParamPayloadDesc => '透传字段，会随本地通知 payload 一起下发（可选）。';

  @override
  String get httpApiParamPortDesc => '服务端口，范围 1~65535。';

  @override
  String get httpApiParamAllowedIPsDesc =>
      '允许访问的 IP 列表，支持精确 IP 和 CIDR。为空表示允许所有 IP。';

  @override
  String get httpApiParamShowNotificationsDesc => '是否显示系统通知。';

  @override
  String get httpApiEnumTitle => '枚举值说明';

  @override
  String get httpApiEnumCategory =>
      'flash_full: 全屏闪烁；flash_edge: 边缘发光（可结合 edgeWidth/edgeOpacity/edgeRepeat）；barrage: 弹幕覆盖提醒（可结合 barrageRepeat）。';

  @override
  String get httpApiEnumPriority => 'low/normal/high: 影响普通通知优先级，默认 normal。';

  @override
  String get httpApiExampleFlashFull => 'POST /api/notify（闪屏 flash_full）';

  @override
  String get httpApiExampleFlashEdge => 'POST /api/notify（闪屏 flash_edge）';

  @override
  String get httpApiResponseTitle => '响应示例';

  @override
  String get httpApiResponseNotifySuccess => 'POST /api/notify 成功响应';

  @override
  String get httpApiResponseError => '参数校验失败响应（HTTP 400）';

  @override
  String get httpApiNotesTitle => '注意事项';

  @override
  String get httpApiNotesAliases => '请使用标准字段名 message。旧字段 body 仅作为兼容别名保留。';

  @override
  String get httpApiNotesBodyOptional =>
      '仅 flash_full / flash_edge / barrage 通知允许 message 为空；普通通知必须提供 message。';

  @override
  String get httpApiNotesEdgeOnly =>
      'edgeWidth、edgeOpacity、edgeRepeat 仅在 category=flash_edge 时可用，否则会返回校验错误。';

  @override
  String get httpApiEndpoints => '接口地址';

  @override
  String get httpApiExamples => '请求示例';

  @override
  String get httpApiNotifyNormal => 'POST /api/notify（普通通知）';

  @override
  String get httpApiNotifyFlash => 'POST /api/notify（闪屏）';

  @override
  String get httpApiSampleTitleHello => '你好';

  @override
  String get httpApiSampleBodyFromSnotice => '来自 SNotice';

  @override
  String get httpApiSampleTitleAlert => '警报';

  @override
  String get httpApiSampleBodyFlash => '闪屏';

  @override
  String reminderSetFor(int minutes) {
    return '提醒已设置为 $minutes 分钟后';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSave => '保存设置';

  @override
  String get settingsSaved => '设置已保存';

  @override
  String get settingsSaveFailed => '保存设置失败';

  @override
  String get themeTitle => '外观主题';

  @override
  String get themeSubtitle => '可切换浅色、深色或跟随系统';

  @override
  String get themeModeSystem => '跟随系统';

  @override
  String get themeModeLight => '浅色';

  @override
  String get themeModeDark => '深色';

  @override
  String get serverSettings => '服务器设置';

  @override
  String get serverPort => '端口';

  @override
  String get serverPortRequired => '请输入端口';

  @override
  String get serverPortInvalid => '请输入有效端口 (1-65535)';

  @override
  String get autoLaunchOnLogin => '开机启动应用';

  @override
  String get autoLaunchOnLoginDesc => '系统登录后自动启动 SNotice';

  @override
  String get autoLaunchOnLoginUpdateFailed => '更新开机启动设置失败';

  @override
  String get allowedIPs => '允许的 IP';

  @override
  String get addIPAddress => '添加 IP 地址';

  @override
  String get ipHint => '例如：127.0.0.1 或 192.168.1.0/24';

  @override
  String get add => '添加';

  @override
  String get noIPsAdded => '未添加 IP。将允许所有 IP。';

  @override
  String get ipWhitelistTitle => 'IP 白名单';

  @override
  String get ipWhitelistInfo =>
      '只有在此列表中的 IP 才能发送通知。留空则允许所有 IP。\n\n支持的格式：\n- 精确 IP：127.0.0.1\n- CIDR 范围：192.168.1.0/24\n\nCIDR 表示法允许整个网络范围。';

  @override
  String get ok => '确定';

  @override
  String get notificationSettings => '通知设置';

  @override
  String get notificationModesDesc => '选择需要保持启用的提醒方式';

  @override
  String get notificationDefaultsTitle => '提醒默认参数';

  @override
  String get notificationDefaultsDesc => '配置闪屏与弹幕在请求未传可选字段时使用的默认参数';

  @override
  String get showNotifications => '显示通知';

  @override
  String get showNotificationsDesc => '显示系统通知';

  @override
  String get showFlash => '启用闪屏提醒';

  @override
  String get showFlashDesc => '允许显示闪屏覆盖提醒';

  @override
  String get showBarrage => '启用弹幕提醒';

  @override
  String get showBarrageDesc => '允许显示滚动弹幕覆盖提醒';

  @override
  String get showSound => '启用声音提醒';

  @override
  String get showSoundDesc => '为系统通知播放声音';

  @override
  String get flashDefaultsTitle => '闪屏默认参数';

  @override
  String get flashColorLabel => '闪屏颜色';

  @override
  String get flashDurationLabel => '闪屏时长（毫秒）';

  @override
  String get flashEdgeWidthLabel => '边缘宽度';

  @override
  String get flashEdgeOpacityLabel => '边缘透明度';

  @override
  String get flashEdgeRepeatLabel => '边缘重复次数';

  @override
  String get flashConfigInvalid => '请填写有效的闪屏默认参数';

  @override
  String get barrageDefaultsTitle => '弹幕默认参数';

  @override
  String get barrageColorLabel => '文字颜色';

  @override
  String get barrageDurationLabel => '时长（毫秒）';

  @override
  String get barrageSpeedLabel => '速度（像素/秒）';

  @override
  String get barrageFontSizeLabel => '字号';

  @override
  String get barrageRepeatLabel => '重复条数';

  @override
  String get barrageLaneLabel => '轨道';

  @override
  String get barrageLaneTop => '顶部';

  @override
  String get barrageLaneMiddle => '中部';

  @override
  String get barrageLaneBottom => '底部';

  @override
  String get barrageConfigInvalid => '请填写有效的弹幕默认参数';

  @override
  String get statusRunning => '运行中';

  @override
  String get statusStopped => '已停止';

  @override
  String get close => '关闭';

  @override
  String get toggleFloatingWindow => '切换悬浮窗';

  @override
  String get floatingWindowFailed => '悬浮窗操作失败，请重试或重启应用';

  @override
  String get hideDetailPanel => '隐藏详情面板';

  @override
  String get showDetailPanel => '显示详情面板';

  @override
  String get labelTitle => '标题';

  @override
  String get labelContent => '内容';

  @override
  String get labelType => '类型';

  @override
  String get labelScheduledTime => '计划时间';

  @override
  String get labelCreatedAt => '创建时间';

  @override
  String get labelRepeat => '重复';

  @override
  String get labelTemplate => '来源模板';

  @override
  String get labelStatus => '状态';

  @override
  String get typeFlash => '闪屏';

  @override
  String get typeNotification => '通知';

  @override
  String get statusExpired => '已过期';

  @override
  String get statusInProgress => '进行中';

  @override
  String get snooze5Minutes => '贪睡 5 分钟';

  @override
  String get cancelReminder => '取消提醒';

  @override
  String get snoozed5Minutes => '已延后 5 分钟';

  @override
  String get reminderCancelled => '已取消提醒';

  @override
  String get trayStartService => '启动服务';

  @override
  String get trayStopService => '停止服务';

  @override
  String get trayOpenMain => '打开主界面';

  @override
  String get trayQuickReminders => '快速提醒';

  @override
  String get trayBreak25 => '休息 (25分钟)';

  @override
  String get trayMeeting15 => '会议 (15分钟)';

  @override
  String get trayMedicine4h => '吃药 (4小时)';

  @override
  String get trayPomodoro => '番茄钟 (25分钟)';

  @override
  String get trayWater => '喝水 (30分钟)';

  @override
  String get trayStretch => '伸展 (45分钟)';

  @override
  String get trayExit => '退出';

  @override
  String get trayServiceRunning => '服务运行中';

  @override
  String get trayServiceNotRunning => '服务未运行';

  @override
  String get quickTime => '快速时间';

  @override
  String get customTime => '自定义时间';

  @override
  String minutes(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String hours(int hours) {
    return '$hours小时';
  }

  @override
  String get reminderType => '提醒类型';

  @override
  String get notification => '通知';

  @override
  String get notificationDesc => '系统通知';

  @override
  String get flashScreen => '闪屏';

  @override
  String get flashScreenDesc => '全屏覆盖';

  @override
  String get titleRequired => '请输入标题';

  @override
  String get message => '内容';

  @override
  String get messageRequired => '请输入内容';

  @override
  String get flashSettings => '闪屏设置';

  @override
  String get color => '颜色';

  @override
  String duration(int duration) {
    return '持续时间：$duration毫秒';
  }

  @override
  String get noReminderHistory => '暂无提醒历史';

  @override
  String get clearHistory => '清除历史';

  @override
  String minutesAgo(int minutes) {
    return '$minutes分钟前';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours小时前';
  }

  @override
  String daysAgo(int days) {
    return '$days天前';
  }

  @override
  String get noActiveReminders => '暂无活动提醒';

  @override
  String get activeReminders => '活动提醒';

  @override
  String created(String name) {
    return '已创建：$name';
  }

  @override
  String get quickCreateReminder => '快速创建提醒';

  @override
  String get noActiveRemindersDesc => '点击上方快速创建或使用左侧模板';

  @override
  String get snooze => '贪睡';

  @override
  String get cancel => '取消';

  @override
  String get reminderMode => '提醒方式';

  @override
  String get countdownReminder => '计时提醒';

  @override
  String get timeReminder => '时间提醒';

  @override
  String get quickSelectTime => '快速选择时间';

  @override
  String get reminderTitle => '提醒标题';

  @override
  String get reminderContent => '提醒内容';

  @override
  String get reminderContentOptional => '提醒内容（可选）';

  @override
  String get typeLabel => '类型：';

  @override
  String get repeatLabel => '重复';

  @override
  String get noRepeat => '不重复';

  @override
  String get daily => '每天';

  @override
  String get weekly => '每周';

  @override
  String get monthly => '每月';

  @override
  String get create => '创建';

  @override
  String get reminderTime => '提醒时间';

  @override
  String get repeatWeekdays => '重复星期（留空表示仅一次）';

  @override
  String get weekdayMon => '一';

  @override
  String get weekdayTue => '二';

  @override
  String get weekdayWed => '三';

  @override
  String get weekdayThu => '四';

  @override
  String get weekdayFri => '五';

  @override
  String get weekdaySat => '六';

  @override
  String get weekdaySun => '日';

  @override
  String get workdays => '工作日';

  @override
  String get everyday => '每天';

  @override
  String get clear => '清空';

  @override
  String get callLogsFilterHint => '过滤条件';

  @override
  String get callLogsEmpty => '暂无调用日志';

  @override
  String minutesFormat(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String hoursFormat(int hours) {
    return '$hours 小时';
  }

  @override
  String hoursMinutesFormat(int hours, int minutes) {
    return '$hours 小时 $minutes 分钟';
  }

  @override
  String daysFormat(int days) {
    return '$days 天';
  }

  @override
  String get reminder => '提醒';

  @override
  String get reminderCreated => '提醒已创建';

  @override
  String get todayStats => '今日统计';

  @override
  String get createdStat => '创建';

  @override
  String get completedStat => '完成';

  @override
  String get completionRate => '完成率';

  @override
  String get last7DaysTrend => '最近7天趋势';

  @override
  String get noData => '暂无数据';

  @override
  String get history => '历史记录';

  @override
  String get clearAll => '清除';

  @override
  String get noHistory => '暂无历史记录';

  @override
  String get reminderDetail => '提醒详情';

  @override
  String xMinutesAgo(int minutes) {
    return '$minutes 分钟前';
  }

  @override
  String xHoursAgo(int hours) {
    return '$hours 小时前';
  }

  @override
  String xDaysAgo(int days) {
    return '$days 天前';
  }

  @override
  String get quickTemplates => '快捷模板';

  @override
  String get noTemplates => '暂无模板';

  @override
  String get customTemplate => '自定义模板';

  @override
  String get undo => '撤销';

  @override
  String get templateCreated => '模板已创建';

  @override
  String get unfavorite => '取消收藏';

  @override
  String get favorite => '收藏';

  @override
  String get createCustomTemplate => '创建自定义模板';

  @override
  String get icon => '图标';

  @override
  String get templateName => '模板名称';

  @override
  String get templateNameHint => '如：喝水提醒';

  @override
  String get templateNameRequired => '请输入名称';

  @override
  String get delayTime => '延迟时间：';

  @override
  String get reminderTitleHint => '提醒时显示的标题';

  @override
  String get reminderContentHint => '提醒时显示的内容';

  @override
  String get save => '保存';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';
}
