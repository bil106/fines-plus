import 'dart:convert';

import 'package:core_data/core_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IMaintenanceRepository {
  Future<List<MaintenanceTask>> getTasks();
  Future<void> saveTasks(List<MaintenanceTask> tasks);
}

class SharedPrefsMaintenanceRepository implements IMaintenanceRepository {
  final SharedPreferences prefs;
  SharedPrefsMaintenanceRepository(this.prefs);

  @override
  Future<List<MaintenanceTask>> getTasks() async {
    final jsonString = prefs.getString('tasks');
    if (jsonString == null) return [];
    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => MaintenanceTask.fromJson(e)).toList();
  }

  @override
  Future<void> saveTasks(List<MaintenanceTask> tasks) async {
    final jsonList = tasks.map((t) => t.toJson()).toList();
    await prefs.setString('tasks', jsonEncode(jsonList));
  }
}
