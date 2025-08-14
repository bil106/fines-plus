import 'package:core_data/core_data.dart';
import 'package:uuid/uuid.dart';

class ReminderRepository {
  final ReminderLocalDataSource localDataSource;

  ReminderRepository(this.localDataSource);

  Future<List<ReminderModel>> getAll() => localDataSource.getReminders();

  Future<void> add(ReminderModel reminder) async {
    final reminders = await getAll();
    reminders.add(reminder.copyWith(id: const Uuid().v4()));
    await localDataSource.saveReminders(reminders);
  }

  Future<void> update(ReminderModel reminder) async {
    final reminders = await getAll();
    final index = reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      reminders[index] = reminder;
      await localDataSource.saveReminders(reminders);
    }
  }

  Future<void> delete(String id) async {
    final reminders = await getAll();
    reminders.removeWhere((r) => r.id == id);
    await localDataSource.saveReminders(reminders);
  }
}
