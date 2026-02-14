import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder_template.dart';
import 'logger_service.dart';

/// 模板管理服务
class TemplateService {
  final LoggerService _logger;
  static const String _customTemplatesKey = 'custom_templates';

  /// 内置模板列表
  static final List<ReminderTemplate> builtInTemplates = [
    ReminderTemplate(
      id: 'break_25',
      name: '休息一下',
      icon: '☕',
      delayMinutes: 25,
      defaultTitle: '休息时间到了',
      defaultBody: '站起来活动一下，休息5分钟',
      type: 'notification',
      isBuiltIn: true,
      sortOrder: 1,
    ),
    ReminderTemplate(
      id: 'meeting_15',
      name: '会议提醒',
      icon: '📌',
      delayMinutes: 15,
      defaultTitle: '会议即将开始',
      defaultBody: '请做好准备，会议马上开始',
      type: 'flash',
      flashColor: '#FFFF00',
      flashDuration: 500,
      isBuiltIn: true,
      sortOrder: 2,
    ),
    ReminderTemplate(
      id: 'medicine_4h',
      name: '吃药提醒',
      icon: '💊',
      delayMinutes: 240, // 4小时
      defaultTitle: '该吃药了',
      defaultBody: '别忘了按时吃药',
      type: 'notification',
      soundKey: 'bell',
      isBuiltIn: true,
      sortOrder: 3,
    ),
    ReminderTemplate(
      id: 'pomodoro',
      name: '番茄钟',
      icon: '🍅',
      delayMinutes: 25,
      defaultTitle: '番茄时间结束',
      defaultBody: '专注时间结束，休息一下吧',
      type: 'notification',
      soundKey: 'chime',
      isBuiltIn: true,
      sortOrder: 4,
    ),
    ReminderTemplate(
      id: 'stretch',
      name: '伸展运动',
      icon: '🧘',
      delayMinutes: 45,
      defaultTitle: '伸展时间',
      defaultBody: '久坐伤身，起来伸展一下吧',
      type: 'notification',
      isBuiltIn: true,
      sortOrder: 5,
    ),
    ReminderTemplate(
      id: 'water',
      name: '喝水提醒',
      icon: '💧',
      delayMinutes: 30,
      defaultTitle: '喝水时间',
      defaultBody: '记得补充水分哦',
      type: 'notification',
      isBuiltIn: true,
      sortOrder: 6,
    ),
    ReminderTemplate(
      id: 'standup',
      name: '站会提醒',
      icon: '👥',
      delayMinutes: 10,
      defaultTitle: '站会即将开始',
      defaultBody: '10分钟后开始站会',
      type: 'notification',
      isBuiltIn: true,
      sortOrder: 7,
    ),
    ReminderTemplate(
      id: 'lunch',
      name: '午餐提醒',
      icon: '🍱',
      delayMinutes: 360, // 6小时
      defaultTitle: '午餐时间',
      defaultBody: '该吃午饭了，别太辛苦',
      type: 'notification',
      isBuiltIn: true,
      sortOrder: 8,
    ),
  ];

  TemplateService(this._logger);

  /// 加载所有模板（内置 + 自定义）
  Future<List<ReminderTemplate>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customJson = prefs.getString(_customTemplatesKey);

      final List<ReminderTemplate> customTemplates = [];
      if (customJson != null) {
        final List<dynamic> jsonList = jsonDecode(customJson);
        for (final json in jsonList) {
          customTemplates.add(
            ReminderTemplate.fromJson(json as Map<String, dynamic>),
          );
        }
      }

      // 合并内置和自定义模板
      final allTemplates = [...builtInTemplates, ...customTemplates];

      // 按排序权重排序
      allTemplates.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      _logger.info(
        'Loaded ${allTemplates.length} templates (${builtInTemplates.length} built-in, ${customTemplates.length} custom)',
      );

      return allTemplates;
    } catch (e) {
      _logger.error('Failed to load templates: $e');
      return builtInTemplates;
    }
  }

  /// 保存自定义模板
  Future<void> saveCustom(ReminderTemplate template) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customJson = prefs.getString(_customTemplatesKey);

      List<ReminderTemplate> customTemplates = [];
      if (customJson != null) {
        final List<dynamic> jsonList = jsonDecode(customJson);
        for (final json in jsonList) {
          customTemplates.add(
            ReminderTemplate.fromJson(json as Map<String, dynamic>),
          );
        }
      }

      // 检查是否已存在（更新）
      final existingIndex = customTemplates.indexWhere((t) => t.id == template.id);
      if (existingIndex != -1) {
        customTemplates[existingIndex] = template;
      } else {
        customTemplates.add(template);
      }

      // 保存
      final jsonList = customTemplates.map((t) => t.toJson()).toList();
      await prefs.setString(_customTemplatesKey, jsonEncode(jsonList));

      _logger.info('Saved custom template: ${template.name}');
    } catch (e) {
      _logger.error('Failed to save custom template: $e');
      rethrow;
    }
  }

  /// 删除自定义模板
  Future<void> deleteCustom(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customJson = prefs.getString(_customTemplatesKey);

      if (customJson == null) return;

      final List<ReminderTemplate> customTemplates = [];
      final List<dynamic> jsonList = jsonDecode(customJson);
      for (final json in jsonList) {
        final template = ReminderTemplate.fromJson(json as Map<String, dynamic>);
        if (template.id != id) {
          customTemplates.add(template);
        }
      }

      // 保存
      final newList = customTemplates.map((t) => t.toJson()).toList();
      await prefs.setString(_customTemplatesKey, jsonEncode(newList));

      _logger.info('Deleted custom template: $id');
    } catch (e) {
      _logger.error('Failed to delete custom template: $e');
      rethrow;
    }
  }

  /// 根据 ID 获取模板
  ReminderTemplate? getById(List<ReminderTemplate> templates, String id) {
    try {
      return templates.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 切换收藏状态
  Future<void> toggleFavorite(ReminderTemplate template) async {
    if (template.isBuiltIn) {
      // 内置模板的收藏状态也需要保存
      final updated = template.copyWith(isFavorite: !template.isFavorite);
      await saveCustom(updated);
    } else {
      // 自定义模板直接更新
      final updated = template.copyWith(isFavorite: !template.isFavorite);
      await saveCustom(updated);
    }
  }
}
