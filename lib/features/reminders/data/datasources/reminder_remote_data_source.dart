import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';

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

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ReminderModel.fromJson({...data, 'id': doc.id});
    }).toList();
  }

@override
  Future<void> addReminder(String carNumber, ReminderModel reminder) async {
    final collectionRef = firestore.collection('reminders').doc(carNumber).collection('items');

    if (reminder.id.isEmpty) {
     
      final newDoc = collectionRef.doc();
      final newReminder = reminder.copyWith(id: newDoc.id);
      await newDoc.set(newReminder.toJson());
    } else {
     
      await collectionRef.doc(reminder.id).set(reminder.toJson());
    }
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
