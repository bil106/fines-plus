import 'dart:convert';
import 'package:core_data/core_data.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';



abstract class ReminderLocalDataSource {
  Future<List<ReminderModel>> getReminders(String carNumber);
  Future<void> saveReminders(String carNumber, List<ReminderModel> reminders);
}

class ReminderLocalDataSourceImpl implements ReminderLocalDataSource {
  final SharedPrefsManager _prefsManager;

  ReminderLocalDataSourceImpl(this._prefsManager);

  String _keyForCar(String carNumber) => 'reminders_$carNumber';

  @override
  Future<List<ReminderModel>> getReminders(String carNumber) async {
    final jsonString = _prefsManager.getString(_keyForCar(carNumber));
    if (jsonString == null) return [];
    final List decoded = json.decode(jsonString);
    return decoded.map((e) => ReminderModel.fromJson(e)).toList();
  }

  @override
  Future<void> saveReminders(String carNumber, List<ReminderModel> reminders) async {
    final jsonString = json.encode(reminders.map((e) => e.toJson()).toList());
    await _prefsManager.setString(_keyForCar(carNumber), jsonString);
  }
}
