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

    // On a cold start (notably on iOS, where restoring the session from the
    // Keychain is slower than Android's SharedPreferences-backed restore)
    // FirebaseAuth.currentUser can still be null for a moment after the app
    // is usable - writing then hits `firestore.rules`' isSignedIn() check
    // and fails with permission-denied, silently, right as the very first
    // reminder a fresh install creates is saved.
    await _ensureSignedIn();

    final collectionRef = FirebaseFirestore.instance.collection('reminders').doc(carNumber).collection('items');

    final docId = reminder.id.isNotEmpty ? reminder.id : collectionRef.doc().id;

    final newReminder = reminder.copyWith(id: docId);

    final fixed = newReminder.copyWith(ownerId: newReminder.ownerId.isNotEmpty ? newReminder.ownerId : carNumber);

    try {
      await collectionRef.doc(docId).set(fixed.toJson());
      debugPrint("Reminder SAVED → $docId");
    } catch (e, st) {
      debugPrint("ReminderRepository.add failed for $docId: $e\n$st");
      rethrow;
    }
  }

  /// Waits (briefly) for [FirebaseAuth.currentUser] to be non-null if it
  /// isn't already - see [add]'s doc comment for why this matters on iOS.
  Future<void> _ensureSignedIn() async {
    if (FirebaseAuth.instance.currentUser != null) return;
    try {
      await FirebaseAuth.instance.authStateChanges().firstWhere((u) => u != null).timeout(const Duration(seconds: 5));
    } catch (_) {
      // Falls through to the write attempt below either way - if auth
      // genuinely never resolves, the existing permission-denied handling
      // (now propagated instead of swallowed) still applies.
    }
  }

  Future<void> update(String carNumber, ReminderModel reminder) async {
    if (carNumber.isEmpty) {
      return;
    }

    if (reminder.id.isEmpty) {
      return;
    }

    await _ensureSignedIn();

    final docRef = FirebaseFirestore.instance
        .collection('reminders')
        .doc(carNumber)
        .collection('items')
        .doc(reminder.id);

    final fixed = reminder.copyWith(ownerId: reminder.ownerId.isNotEmpty ? reminder.ownerId : carNumber);

    try {
      await docRef.set(fixed.toJson(), SetOptions(merge: true));
    } catch (e, st) {
      debugPrint("ReminderRepository.update failed for ${reminder.id}: $e\n$st");
      rethrow;
    }
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
