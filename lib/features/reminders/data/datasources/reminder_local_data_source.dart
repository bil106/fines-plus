import 'dart:convert';
import 'package:core_data/core_data.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';

abstract class ReminderLocalDataSource {
  Future<List<ReminderModel>> getReminders(String scopeKey);
  Future<void> saveReminders(String scopeKey, List<ReminderModel> reminders);
}

class ReminderLocalDataSourceImpl implements ReminderLocalDataSource {
  final SharedPrefsManager _prefsManager;
  // Deliberately distinct from the "reminders" key the Settings screen uses
  // for its on/off toggle (SharedPreferences has one namespace) — that
  // collision let getBoolSafe misread this cached JSON list as "not true"
  // and stomp it back to a bare `false`, silently wiping the local cache
  // every time the toggle's value was read.
  static const _keyPrefix = 'cached_reminders_list';

  ReminderLocalDataSourceImpl(this._prefsManager);

  String _key(String scopeKey) => '${_keyPrefix}_$scopeKey';

  @override
  Future<List<ReminderModel>> getReminders(String scopeKey) async {
    final jsonString = _prefsManager.getString(_key(scopeKey));
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
      await saveReminders(scopeKey, reminders);
    }

    return reminders;
  }

  @override
  Future<void> saveReminders(String scopeKey, List<ReminderModel> reminders) async {
    final jsonString = json.encode(
      reminders
          .map((e) => {...e.toJson(), 'dateTime': e.dateTime.toUtc().toIso8601String()})
          .toList(),
    );
    await _prefsManager.setString(_key(scopeKey), jsonString);
  }
}
