import 'package:flutter/foundation.dart';
import '../models/reminder_template.dart';
import '../services/template_service.dart';
import '../services/logger_service.dart';

/// 模板状态管理
class TemplateProvider extends ChangeNotifier {
  final TemplateService _templateService;
  final LoggerService _logger;

  List<ReminderTemplate> _templates = [];
  bool _isLoading = false;
  String? _error;

  TemplateProvider(this._templateService, this._logger) {
    load();
  }

  /// 所有模板
  List<ReminderTemplate> get templates => _templates;

  /// 收藏的模板
  List<ReminderTemplate> get favoriteTemplates =>
      _templates.where((t) => t.isFavorite).toList();

  /// 内置模板
  List<ReminderTemplate> get builtInTemplates =>
      _templates.where((t) => t.isBuiltIn).toList();

  /// 自定义模板
  List<ReminderTemplate> get customTemplates =>
      _templates.where((t) => !t.isBuiltIn).toList();

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 错误信息
  String? get error => _error;

  /// 加载模板
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _templates = await _templateService.loadAll();
      _logger.info('TemplateProvider loaded ${_templates.length} templates');
    } catch (e) {
      _error = e.toString();
      _logger.error('Failed to load templates: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 添加自定义模板
  Future<void> addCustom(ReminderTemplate template) async {
    try {
      await _templateService.saveCustom(template);
      _templates.add(template);
      _templates.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      notifyListeners();
      _logger.info('Added custom template: ${template.name}');
    } catch (e) {
      _error = e.toString();
      _logger.error('Failed to add custom template: $e');
      rethrow;
    }
  }

  /// 更新自定义模板
  Future<void> updateCustom(ReminderTemplate template) async {
    try {
      await _templateService.saveCustom(template);
      final index = _templates.indexWhere((t) => t.id == template.id);
      if (index != -1) {
        _templates[index] = template;
        _templates.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        notifyListeners();
      }
      _logger.info('Updated custom template: ${template.name}');
    } catch (e) {
      _error = e.toString();
      _logger.error('Failed to update custom template: $e');
      rethrow;
    }
  }

  /// 删除自定义模板
  Future<void> deleteCustom(String id) async {
    try {
      await _templateService.deleteCustom(id);
      _templates.removeWhere((t) => t.id == id);
      notifyListeners();
      _logger.info('Deleted custom template: $id');
    } catch (e) {
      _error = e.toString();
      _logger.error('Failed to delete custom template: $e');
      rethrow;
    }
  }

  /// 切换收藏状态
  Future<void> toggleFavorite(String id) async {
    final index = _templates.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final template = _templates[index];
    final updated = template.copyWith(isFavorite: !template.isFavorite);

    try {
      await _templateService.toggleFavorite(template);
      _templates[index] = updated;
      notifyListeners();
      _logger.info('Toggled favorite for template: $id');
    } catch (e) {
      _error = e.toString();
      _logger.error('Failed to toggle favorite: $e');
      rethrow;
    }
  }

  /// 根据 ID 获取模板
  ReminderTemplate? getById(String id) {
    try {
      return _templates.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
