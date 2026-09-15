import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasksRepository {
  static const _legacyKey = 'tasks_by_car_map';
  static const _legacyMigratedKey = 'tasks_by_car_map_migrated';

  final FirebaseFirestore firestore;
  bool _migrationAttempted = false;

  TasksRepository(this.firestore);

  CollectionReference<Map<String, dynamic>> _carsCollection(String uid) =>
      firestore.collection('users').doc(uid).collection('cars');

  Future<void> _migrateLegacyDataIfNeeded() async {
    if (_migrationAttempted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _migrationAttempted = true;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_legacyMigratedKey) == true) return;

    final encodedData = prefs.getString(_legacyKey);
    if (encodedData != null) {
      final Map<String, dynamic> decoded = jsonDecode(encodedData);
      for (final entry in decoded.entries) {
        final carNumber = entry.key;
        final types = List<String>.from(entry.value);
        if (carNumber.isEmpty || types.isEmpty) continue;

        await _carsCollection(
          user.uid,
        ).doc(carNumber).set({'quickActionTasks': FieldValue.arrayUnion(types)}, SetOptions(merge: true));
      }
      await prefs.remove(_legacyKey);
    }

    await prefs.setBool(_legacyMigratedKey, true);
  }

  Future<void> createTask(String type, {required String carNumber}) async {
    if (carNumber.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _migrateLegacyDataIfNeeded();

    final key = type.toLowerCase();
    await _carsCollection(user.uid).doc(carNumber).set({
      'quickActionTasks': FieldValue.arrayUnion([key]),
    }, SetOptions(merge: true));
  }

  Future<void> removeTask(String type, {required String carNumber}) async {
    if (carNumber.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _migrateLegacyDataIfNeeded();

    final key = type.toLowerCase();
    await _carsCollection(user.uid).doc(carNumber).set({
      'quickActionTasks': FieldValue.arrayRemove([key]),
    }, SetOptions(merge: true));
  }

  Future<bool> hasActiveTask({required String carNumber, required String category}) async {
    if (carNumber.isEmpty) return false;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    await _migrateLegacyDataIfNeeded();

    final doc = await _carsCollection(user.uid).doc(carNumber).get();
    final tasks = List<String>.from(doc.data()?['quickActionTasks'] ?? []);
    return tasks.contains(category.toLowerCase());
  }

  /// Live-updates as the active car's `quickActionTasks` change in Firestore
  /// — a task created/removed on another device reaches this one
  /// immediately instead of only on the next explicit [hasActiveTask] poll.
  Stream<List<String>> watchActiveCategories({required String carNumber}) {
    final user = FirebaseAuth.instance.currentUser;
    if (carNumber.isEmpty || user == null) return const Stream.empty();

    return _carsCollection(user.uid).doc(carNumber).snapshots().map((doc) {
      final tasks = List<String>.from(doc.data()?['quickActionTasks'] ?? []);
      return tasks.map((t) => t.toLowerCase()).toList();
    });
  }

  Future<bool> hasTaskOfType(String type) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    await _migrateLegacyDataIfNeeded();

    final key = type.toLowerCase();
    final query = await _carsCollection(user.uid).where('quickActionTasks', arrayContains: key).limit(1).get();
    return query.docs.isNotEmpty;
  }
}
