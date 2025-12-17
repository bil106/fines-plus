import 'package:shared_preferences/shared_preferences.dart';

class TasksRepository {
  static const _key = 'existing_tasks';
  final List<String> _existingTasks = [];
final Map<String, List<String>> _tasksByCar = {};
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

  Future<void> createTask(String type, {required String carNumber}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final tasks = _tasksByCar.putIfAbsent(carNumber, () => []);
    if (!tasks.contains(type)) {
      tasks.add(type);
      await _saveTasks();
    }
  }

Future<void> removeTask(String type, {required String carNumber}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final tasks = _tasksByCar[carNumber] ?? [];
    tasks.remove(type.toLowerCase());


    _tasksByCar[carNumber] = tasks;

 
    _existingTasks.remove(type.toLowerCase());

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _existingTasks);
  }



    Future<bool> hasActiveTask({required String carNumber, required String category}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final tasks = _tasksByCar[carNumber] ?? [];
    return tasks.contains(category.toLowerCase());
  }
}
