import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder.dart';
import '../models/notification_request.dart';
import '../services/logger_service.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  final LoggerService _logger;
  final NotificationService _notificationService;
  final List<Reminder> _reminders = [];
  final Set<String> _triggeredReminders = {};
  Timer? _timer;

  ReminderProvider(this._logger, this._notificationService) {
    _init();
  }

  List<Reminder> get activeReminders =>
      _reminders.where((r) => !r.isExpired).toList();
  List<Reminder> get expiredReminders =>
      _reminders.where((r) => r.isExpired).toList();

  Future<void> _init() async {
    await _loadReminders();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkExpiredReminders();
    });
  }

  void _checkExpiredReminders() {
    final expiredReminders = _reminders
        .where((r) => r.isExpired && !_triggeredReminders.contains(r.id))
        .toList();

    for (final reminder in expiredReminders) {
      _triggeredReminders.add(reminder.id);
      unawaited(_triggerReminder(reminder));
    }

    if (expiredReminders.isNotEmpty || _reminders.any((r) => !r.isExpired)) {
      notifyListeners();
    }
  }

  Future<void> _loadReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getString('reminders');
      if (remindersJson != null) {
        final List<dynamic> jsonList = jsonDecode(remindersJson);
        _reminders.clear();
        _reminders.addAll(
          jsonList.map(
            (json) => Reminder.fromJson(json as Map<String, dynamic>),
          ),
        );
        notifyListeners();
        _checkExpiredReminders();
      }
    } catch (e) {
      _logger.error('Failed to load reminders: $e');
    }
  }

  Future<void> _saveReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = jsonEncode(
        _reminders.map((r) => r.toJson()).toList(),
      );
      await prefs.setString('reminders', remindersJson);
    } catch (e) {
      _logger.error('Failed to save reminders: $e');
    }
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_reminders.length}';
  }

  Reminder addReminder({
    required String title,
    required String body,
    required Duration delay,
    String type = 'notification',
    String? flashColor,
    int? flashDuration,
  }) {
    final reminder = Reminder(
      id: _generateId(),
      title: title,
      body: body,
      scheduledTime: DateTime.now().add(delay),
      createdAt: DateTime.now(),
      type: type,
      flashColor: flashColor,
      flashDuration: flashDuration,
    );

    _reminders.add(reminder);
    _saveReminders();
    notifyListeners();

    _logger.info(
      'Reminder added: ${reminder.title} at ${reminder.scheduledTime}',
    );

    return reminder;
  }

  Future<void> _triggerReminder(Reminder reminder) async {
    if (!_reminders.any((r) => r.id == reminder.id)) {
      return;
    }

    _logger.info('Reminder triggered: ${reminder.title}');

    // Show notification or flash screen based on type
    final request = NotificationRequest(
      title: reminder.title,
      body: reminder.body,
      priority: 'normal',
      category: reminder.type == 'flash' ? 'flash' : 'info',
      flashColor: reminder.flashColor,
      flashDuration: reminder.flashDuration,
    );

    await _notificationService.showNotification(request);
    notifyListeners();
  }

  void removeReminder(String id) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final reminder = _reminders[index];
      _reminders.removeAt(index);
      _triggeredReminders.remove(id);
      _saveReminders();
      notifyListeners();
      _logger.info('Reminder removed: ${reminder.title}');
    }
  }

  void clearExpired() {
    final count = _reminders.length;
    final expiredIds = _reminders
        .where((r) => r.isExpired)
        .map((r) => r.id)
        .toSet();

    _reminders.removeWhere((r) => r.isExpired);
    _triggeredReminders.removeAll(expiredIds);
    final removed = count - _reminders.length;
    if (removed > 0) {
      _saveReminders();
      notifyListeners();
      _logger.info('Cleared $removed expired reminders');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
