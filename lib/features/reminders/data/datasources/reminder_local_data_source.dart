import 'dart:convert';
import 'package:core_data/core_data.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';



abstract class ReminderLocalDataSource {
  Future<List<ReminderModel>> getReminders();
  Future<void> saveReminders(List<ReminderModel> reminders);
}

class ReminderLocalDataSourceImpl implements ReminderLocalDataSource {
  final SharedPrefsManager _prefsManager;
  static const _key = 'reminders';

  ReminderLocalDataSourceImpl(this._prefsManager);

  @override
  Future<List<ReminderModel>> getReminders() async {
    final jsonString = _prefsManager.getString(_key);
    if (jsonString == null) return [];
    final List decoded = json.decode(jsonString);
    return decoded.map((e) => ReminderModel.fromJson(e)).toList();
  }

  @override
  Future<void> saveReminders(List<ReminderModel> reminders) async {
    final jsonString = json.encode(reminders.map((e) => e.toJson()).toList());
    await _prefsManager.setString(_key, jsonString);
  }
}

