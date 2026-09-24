import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fines_plus/features/maintenance/data/models/maintenance_task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ScheduleFirebaseRepository {
  final FirebaseFirestore firestore;

  ScheduleFirebaseRepository(this.firestore);

  CollectionReference<Map<String, dynamic>> _tasksCollection(String carNumber) {
    if (carNumber.isEmpty) {
      throw ArgumentError('carNumber cannot be empty');
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('User not logged in');

    return firestore.collection('users').doc(user.uid).collection('cars').doc(carNumber).collection('scheduleTasks');
  }

  // Pre-migration path: reminders were stored unscoped by carNumber only, with no
  // owner check, so any signed-in user could read/write another user's data.
  CollectionReference<Map<String, dynamic>> _legacyTasksCollection(String carNumber) {
    return firestore.collection('reminders').doc(carNumber).collection('items');
  }

  Future<void> migrateLegacyIfNeeded(String carNumber) async {
    if (carNumber.isEmpty) return;
    if (FirebaseAuth.instance.currentUser == null) return;

    final newCollection = _tasksCollection(carNumber);
    final existing = await newCollection.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final legacySnap = await _legacyTasksCollection(carNumber).get();
    if (legacySnap.docs.isEmpty) return;

    // The legacy collection is shared with ReminderRepository's current
    // reminders - only move docs that are actually maintenance tasks, or
    // live reminders get pulled out of `reminders` into `scheduleTasks`.
    final taskDocs = legacySnap.docs.where((doc) => _parseTask(doc) != null).toList();
    if (taskDocs.isEmpty) return;

    final batch = firestore.batch();
    for (final doc in taskDocs) {
      batch.set(newCollection.doc(doc.id), doc.data());
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> addTask(String carNumber, MaintenanceTask task) async {
    await _tasksCollection(carNumber).doc(task.id).set(task.toJson());
  }

  Future<List<MaintenanceTask>> loadTasks(String carNumber) async {
    final snapshot = await _tasksCollection(carNumber).get();
    return snapshot.docs.map(_parseTask).whereType<MaintenanceTask>().toList();
  }

  /// Returns null for a doc that isn't a valid [MaintenanceTask] (e.g. a
  /// reminder moved here by an earlier, unfiltered legacy migration), so one
  /// malformed doc doesn't fail loading the whole list.
  MaintenanceTask? _parseTask(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      return MaintenanceTask.fromJson(data);
    } catch (e) {
      debugPrint('Skipping malformed maintenance task ${doc.reference.path}: $e');
      return null;
    }
  }

  Future<MaintenanceTask> saveTask(String carNumber, MaintenanceTask task) async {
    final collection = _tasksCollection(carNumber);
    if (task.id == null || task.id!.isEmpty) {
      final ref = collection.doc();
      final newTask = task.copyWith(id: ref.id);
      await ref.set(newTask.toJson());
      return newTask;
    } else {
      await collection.doc(task.id).set(task.toJson(), SetOptions(merge: true));
      return task;
    }
  }

  Future<void> updateTask(String carNumber, MaintenanceTask task) async {
    if (task.id == null) return;

    await _tasksCollection(carNumber).doc(task.id).set(task.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteTask(String carNumber, MaintenanceTask task) async {
    if (task.id == null) return;

    await _tasksCollection(carNumber).doc(task.id).delete();
  }

  Future<void> clearTasks(String carNumber) async {
    final query = await _tasksCollection(carNumber).get();
    for (var doc in query.docs) {
      await doc.reference.delete();
    }
  }
}
