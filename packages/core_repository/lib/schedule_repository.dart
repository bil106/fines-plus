import 'dart:convert';
import 'package:core_data/core_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleRepository {
  static const _key = 'schedule_tasks';

  Future<List<MaintenanceTask>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> list = jsonDecode(jsonString);
    return list.map((e) => MaintenanceTask.fromJson(e)).toList();
  }

  Future<void> saveTasks(List<MaintenanceTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }
}
