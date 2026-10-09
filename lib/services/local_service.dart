import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_data.dart';

class LocalService {
  static const String _emailKey = 'user_email';
  static const String _pointsKey = 'user_points';
  static const String _titleKey = 'user_title';
  static const String _completedTasksKey = 'completed_task_ids';
  static const String _travelHistoryKey = 'travel_history';
  static const String _activeCityKey = 'active_city';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> saveUserData(String email, int points) async {
    await init();
    final title = UserData.calculateTitle(points);
    await _prefs!.setString(_emailKey, email);
    await _prefs!.setInt(_pointsKey, points);
    await _prefs!.setString(_titleKey, title);
  }

  Future<UserData> getUserData() async {
    await init();
    final email = _prefs!.getString(_emailKey) ?? '';
    final points = _prefs!.getInt(_pointsKey) ?? 0;
    final title =
        _prefs!.getString(_titleKey) ?? UserData.calculateTitle(points);

    return UserData(email: email, points: points, title: title);
  }

  Future<bool> isLoggedIn() async {
    final userData = await getUserData();
    return userData.email.isNotEmpty;
  }

  Future<void> saveCompletedTasks(List<String> taskIds) async {
    await init();
    await _prefs!.setStringList(_completedTasksKey, taskIds);
  }

  Future<List<String>> getCompletedTaskIds() async {
    await init();
    return _prefs!.getStringList(_completedTasksKey) ?? <String>[];
  }

  Future<void> saveTravelHistory(List<Map<String, dynamic>> history) async {
    await init();
    await _prefs!.setString(_travelHistoryKey, jsonEncode(history));
  }

  Future<void> saveActiveCity(String city) async {
    await init();
    await _prefs!.setString(_activeCityKey, city);
  }

  Future<String> getActiveCity() async {
    await init();
    return _prefs!.getString(_activeCityKey) ?? '';
  }

  Future<List<Map<String, dynamic>>> getTravelHistory() async {
    await init();
    final rawValue = _prefs!.getString(_travelHistoryKey);
    if (rawValue == null || rawValue.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    final decoded = jsonDecode(rawValue);
    if (decoded is! List) {
      return <Map<String, dynamic>>[];
    }

    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> markTaskCompleted({
    required String taskId,
    required String title,
    required int points,
    required String completedAt,
  }) async {
    final existingTaskIds = await getCompletedTaskIds();
    if (existingTaskIds.contains(taskId)) {
      return;
    }

    existingTaskIds.add(taskId);
    await saveCompletedTasks(existingTaskIds);

    final history = await getTravelHistory();
    history.insert(0, {
      'title': title,
      'points': points,
      'completedAt': completedAt,
    });
    await saveTravelHistory(history);
  }

  Future<void> logout() async {
    await init();
    await _prefs!.remove(_emailKey);
    await _prefs!.remove(_pointsKey);
    await _prefs!.remove(_titleKey);
    await _prefs!.remove(_activeCityKey);
  }
}
