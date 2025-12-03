import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fines_plus/features/reminders/data/datasources/reminder_local_data_source.dart';
import 'package:fines_plus/features/reminders/data/datasources/reminder_remote_data_source.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';
import 'package:flutter/material.dart';



class ReminderRepository {
  final ReminderLocalDataSource localDataSource;
  final ReminderRemoteDataSource remoteDataSource;

  ReminderRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

 Future<void> add(String carNumber, ReminderModel reminder) async {
    final collectionRef = FirebaseFirestore.instance.collection('reminders').doc(carNumber).collection('items');

    final docRef = reminder.id.isNotEmpty ? collectionRef.doc(reminder.id) : collectionRef.doc();
    await docRef.set(reminder.toJson());
  }

  Future<void> update(String carNumber, ReminderModel reminder) async {
    final docRef =
        FirebaseFirestore.instance.collection('reminders').doc(carNumber).collection('items').doc(reminder.id);
    await docRef.set(reminder.toJson());
  }

Future<List<ReminderModel>> getAll(String carNumber) async {
    final snapshot = await FirebaseFirestore.instance.collection('reminders').doc(carNumber).collection('items').get();
    debugPrint('getAll() found ${snapshot.docs.length} reminders for carNumber: $carNumber');

    return snapshot.docs.map((doc) => ReminderModel.fromJson(doc.data())).toList();
  }



  Future<void> delete(String carNumber, String id) async {
    await remoteDataSource.deleteReminder(carNumber, id);
  }
}
