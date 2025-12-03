import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/features/reminders/data/datasources/reminder_local_data_source.dart';
import 'package:fines_plus/features/reminders/data/datasources/reminder_remote_data_source.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';
import 'package:flutter/material.dart';

class ReminderRepository {
  final ReminderLocalDataSource localDataSource;
  final ReminderRemoteDataSource remoteDataSource;

  ReminderRepository({required this.localDataSource, required this.remoteDataSource});

  Future<void> add(String carNumber, ReminderModel reminder) async {
    if (carNumber.isEmpty) {

      return;
    }

    final collectionRef = FirebaseFirestore.instance.collection('reminders').doc(carNumber).collection('items');

    final docId = reminder.id.isNotEmpty ? reminder.id : collectionRef.doc().id;

    final newReminder = reminder.copyWith(id: docId);

    await collectionRef.doc(docId).set(newReminder.toJson());

    debugPrint("Reminder SAVED → $docId");
  }

  Future<void> update(String carNumber, ReminderModel reminder) async {
    if (carNumber.isEmpty) {
     
      return;
    }

    if (reminder.id.isEmpty) {
    
      return;
    }

    final docRef = FirebaseFirestore.instance
        .collection('reminders')
        .doc(carNumber)
        .collection('items')
        .doc(reminder.id);

    await docRef.set(reminder.toJson(), SetOptions(merge: true));


  }

Future<List<ReminderModel>> getAll(String carNumber) async {
    if (carNumber.isEmpty) return [];

    final snapshot = await FirebaseFirestore.instance.collection('reminders').doc(carNumber).collection('items').get();

   

    final reminders = <ReminderModel>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();

      try {
     
        data['title'] ??= S.current.no_name;
        data['description'] ??= '';

        reminders.add(ReminderModel.fromJson(data));
      } catch (e, st) {
        debugPrint('Failed to parse reminder: $e\n$st');
        continue;
      }
    }

    return reminders;
  }




  Future<void> delete(String carNumber, String id) async {
    if (carNumber.isEmpty) {
      debugPrint("❌ ReminderRepository.delete(): carNumber is EMPTY");
      return;
    }

    if (id.isEmpty) {
      debugPrint("❌ ReminderRepository.delete(): id is EMPTY");
      return;
    }

    await remoteDataSource.deleteReminder(carNumber, id);

    debugPrint("✔ Reminder DELETED → $id");
  }
}
