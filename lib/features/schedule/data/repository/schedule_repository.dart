import 'dart:convert';

import 'package:fines_plus/features/maintenance/data/models/maintenance_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleRepository {
  String _key(String carNumber) => 'schedule_tasks_$carNumber';

  Future<List<MaintenanceTask>> loadTasks(String carNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key(carNumber));
    if (jsonString == null) return [];

    final List<dynamic> list = jsonDecode(jsonString);
    return list.map((e) => MaintenanceTask.fromJson(e)).toList();
  }

  Future<void> saveTasks(String carNumber, List<MaintenanceTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_key(carNumber), jsonString);
  }

  Future<void> clearTasks(String carNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(carNumber));
  }
}
