import 'package:fines_plus/features/reminders/data/datasources/reminder_local_data_source.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';
import 'package:flutter/material.dart';

/// Reminders live purely on-device — scoped by account + car so multiple
/// accounts/cars on the same device never see each other's reminders —
/// rather than in Firestore. No cross-device sync, but no dependency on
/// being signed in either.
class ReminderRepository {
  final ReminderLocalDataSource localDataSource;

  ReminderRepository({required this.localDataSource});

  String _scopeKey(String ownerId, String carNumber) => '${ownerId.isEmpty ? 'anon' : ownerId}_$carNumber';

  Future<void> add(String ownerId, String carNumber, ReminderModel reminder) async {
    if (carNumber.isEmpty) return;

    final scope = _scopeKey(ownerId, carNumber);
    final existing = await localDataSource.getReminders(scope);
    final docId = reminder.id.isNotEmpty ? reminder.id : DateTime.now().microsecondsSinceEpoch.toString();
    final fixed = reminder.copyWith(id: docId, ownerId: reminder.ownerId.isNotEmpty ? reminder.ownerId : ownerId);

    await localDataSource.saveReminders(scope, [...existing, fixed]);
    debugPrint('Reminder SAVED locally → $docId');
  }

  Future<void> update(String ownerId, String carNumber, ReminderModel reminder) async {
    if (carNumber.isEmpty || reminder.id.isEmpty) return;

    final scope = _scopeKey(ownerId, carNumber);
    final existing = await localDataSource.getReminders(scope);
    final fixed = reminder.copyWith(ownerId: reminder.ownerId.isNotEmpty ? reminder.ownerId : ownerId);
    final updated = existing.map((r) => r.id == fixed.id ? fixed : r).toList();

    await localDataSource.saveReminders(scope, updated);
  }

  Future<List<ReminderModel>> getAll(String ownerId, String carNumber) async {
    if (carNumber.isEmpty) {
      debugPrint('ReminderRepository.getAll skipped — carNumber empty');
      return [];
    }

    return localDataSource.getReminders(_scopeKey(ownerId, carNumber));
  }

  Future<void> delete(String ownerId, String carNumber, String id) async {
    if (carNumber.isEmpty || id.isEmpty) return;

    final scope = _scopeKey(ownerId, carNumber);
    final existing = await localDataSource.getReminders(scope);
    await localDataSource.saveReminders(scope, existing.where((r) => r.id != id).toList());
    debugPrint('Reminder DELETED locally → $id');
  }
}
