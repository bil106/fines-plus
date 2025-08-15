import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_data/core_data.dart';

abstract class ReminderRemoteDataSource {
  Future<List<ReminderModel>> getReminders(String carNumber);
  Future<void> addReminder(String carNumber, ReminderModel reminder);
  Future<void> updateReminder(String carNumber, ReminderModel reminder);
  Future<void> deleteReminder(String carNumber, String reminderId);
}

class ReminderRemoteDataSourceImpl implements ReminderRemoteDataSource {
  final FirebaseFirestore firestore;

  ReminderRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<ReminderModel>> getReminders(String carNumber) async {
    final snapshot = await firestore.collection('reminders').doc(carNumber).collection('items').get();

    return snapshot.docs.map((doc) => ReminderModel.fromJson(doc.data())).toList();
  }

  @override
  Future<void> addReminder(String carNumber, ReminderModel reminder) async {
    final docRef = firestore.collection('reminders').doc(carNumber).collection('items').doc();

    await docRef.set(reminder.copyWith(id: docRef.id).toJson());
  }

  @override
  Future<void> updateReminder(String carNumber, ReminderModel reminder) async {
    await firestore
        .collection('reminders')
        .doc(carNumber)
        .collection('items')
        .doc(reminder.id)
        .update(reminder.toJson());
  }

  @override
  Future<void> deleteReminder(String carNumber, String reminderId) async {
    await firestore.collection('reminders').doc(carNumber).collection('items').doc(reminderId).delete();
  }
}
