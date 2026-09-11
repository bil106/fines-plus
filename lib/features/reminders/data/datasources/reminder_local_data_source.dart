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

    final reminders = <ReminderModel>[];
    for (final item in decoded) {
      try {
        final data = Map<String, dynamic>.from(item as Map);
        if ((data['title'] as String?)?.trim().isEmpty ?? true) {
          continue;
        }
        data['description'] ??= '';
        data['ownerId'] ??= '';
        reminders.add(ReminderModel.fromJson(data));
      } catch (_) {
        continue;
      }
    }

    if (reminders.length != decoded.length) {
      await saveReminders(reminders);
    }

    return reminders;
  }

  @override
  Future<void> saveReminders(List<ReminderModel> reminders) async {
    final jsonString = json.encode(
      reminders
          .map((e) => {...e.toJson(), 'dateTime': e.dateTime.toUtc().toIso8601String()})
          .toList(),
    );
    await _prefsManager.setString(_key, jsonString);
  }
}

