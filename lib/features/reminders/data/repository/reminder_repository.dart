import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fines_plus/features/reminders/data/datasources/reminder_local_data_source.dart';
import 'package:fines_plus/features/reminders/data/datasources/reminder_remote_data_source.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    final fixed = newReminder.copyWith(ownerId: newReminder.ownerId.isNotEmpty ? newReminder.ownerId : carNumber);

    await collectionRef.doc(docId).set(fixed.toJson());

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

    final fixed = reminder.copyWith(ownerId: reminder.ownerId.isNotEmpty ? reminder.ownerId : carNumber);

    await docRef.set(fixed.toJson(), SetOptions(merge: true));
  }

  Future<List<ReminderModel>> getAll(String carNumber) async {
    if (carNumber.isEmpty) {
      debugPrint('ReminderRepository.getAll skipped — carNumber empty');
      return [];
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('ReminderRepository.getAll skipped — user not authorized');
      return [];
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('reminders')
          .doc(carNumber)
          .collection('items')
          .get();

      final reminders = <ReminderModel>[];
      final invalidDocIds = <String>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        try {
          if ((data['title'] as String?)?.trim().isEmpty ?? true) {
            invalidDocIds.add(doc.id);
            continue;
          }

          data['ownerId'] ??= carNumber;
          data['description'] ??= '';

          reminders.add(ReminderModel.fromJson(data));
        } catch (_) {
          invalidDocIds.add(doc.id);
        }
      }

      if (invalidDocIds.isNotEmpty) {
        await Future.wait(
          invalidDocIds.map(
            (id) => FirebaseFirestore.instance
                .collection('reminders')
                .doc(carNumber)
                .collection('items')
                .doc(id)
                .delete(),
          ),
        );

        await localDataSource.saveReminders(reminders);
      } else {
        await localDataSource.saveReminders(reminders);
      }

      return reminders;
    } on FirebaseException catch (e, st) {
      if (e.code == 'permission-denied') {
        debugPrint('ReminderRepository.getAll permission denied for car=$carNumber (probably deleted)');
        return [];
      }

      debugPrint('ReminderRepository.getAll Firebase error: $e\n$st');
      return [];
    } catch (e, st) {
      debugPrint('ReminderRepository.getAll unknown error: $e\n$st');
      return [];
    }
  }

  Future<void> delete(String carNumber, String id) async {
    if (carNumber.isEmpty) {
      debugPrint(" ReminderRepository.delete(): carNumber is EMPTY");
      return;
    }

    if (id.isEmpty) {
      debugPrint(" ReminderRepository.delete(): id is EMPTY");
      return;
    }

    await remoteDataSource.deleteReminder(carNumber, id);

    debugPrint(" Reminder DELETED → $id");
  }
}
