import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TasksRepository {
  static const _key = 'tasks_by_car_map';
  final Map<String, List<String>> _tasksByCar = {};

  TasksRepository() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_key);
    if (encodedData != null) {
      final Map<String, dynamic> decoded = jsonDecode(encodedData);
      decoded.forEach((key, value) {
        _tasksByCar[key] = List<String>.from(value);
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_tasksByCar);
    await prefs.setString(_key, encodedData);
  }

  Future<void> createTask(String type, {required String carNumber}) async {
    final key = type.toLowerCase();
    final tasks = _tasksByCar.putIfAbsent(carNumber, () => []);
    if (!tasks.contains(key)) {
      tasks.add(key);
      await _saveTasks();
    }
  }

  Future<void> removeTask(String type, {required String carNumber}) async {
    final key = type.toLowerCase();
    final tasks = _tasksByCar[carNumber];
    if (tasks != null) {
      tasks.remove(key);
      await _saveTasks();
    }
  }

  Future<bool> hasActiveTask({required String carNumber, required String category}) async {
    // Ждем загрузки, если она еще идет (или убедитесь, что await _loadTasks в main)
    final tasks = _tasksByCar[carNumber] ?? [];
    return tasks.contains(category.toLowerCase());
  }

  // Для совместимости с вашим init в Cubit
  Future<bool> hasTaskOfType(String type) async {
    return _tasksByCar.values.any((list) => list.contains(type.toLowerCase()));
  }
}
