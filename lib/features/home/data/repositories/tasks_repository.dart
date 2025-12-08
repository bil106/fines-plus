import 'package:shared_preferences/shared_preferences.dart';

class TasksRepository {
  static const _key = 'existing_tasks';
  final List<String> _existingTasks = [];

  TasksRepository() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTasks = prefs.getStringList(_key) ?? [];
    _existingTasks.clear();
    _existingTasks.addAll(storedTasks);
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _existingTasks);
  }

  Future<bool> hasTaskOfType(String type) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _existingTasks.contains(type);
  }

  Future<void> createTask(String type) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!_existingTasks.contains(type)) {
      _existingTasks.add(type);
      await _saveTasks();
    }
  }

  Future<void> removeTask(String type) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _existingTasks.remove(type);
    await _saveTasks();
  }
}
