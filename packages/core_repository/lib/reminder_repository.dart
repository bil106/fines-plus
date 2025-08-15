import 'package:core_data/core_data.dart';



class ReminderRepository {
  final ReminderLocalDataSource localDataSource;
  final ReminderRemoteDataSource remoteDataSource;

  ReminderRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  Future<List<ReminderModel>> getAll(String carNumber) async {
    final reminders = await remoteDataSource.getReminders(carNumber);
    await localDataSource.saveReminders(reminders);
    return reminders;
  }

  Future<void> add(String carNumber, ReminderModel reminder) async {
    await remoteDataSource.addReminder(carNumber, reminder);
  }

  Future<void> update(String carNumber, ReminderModel reminder) async {
    await remoteDataSource.updateReminder(carNumber, reminder);
  }

  Future<void> delete(String carNumber, String id) async {
    await remoteDataSource.deleteReminder(carNumber, id);
  }
}
