import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fines_plus/features/maintenance/data/models/maintenance_task.dart';

class ScheduleFirebaseRepository {
  final FirebaseFirestore firestore;

  ScheduleFirebaseRepository(this.firestore);

  CollectionReference _tasksCollection(String carNumber) {
    return firestore.collection('cars').doc(carNumber).collection('maintenance_tasks');
  }

  Future<List<MaintenanceTask>> loadTasks(String carNumber) async {
    final snap = await _tasksCollection(carNumber).orderBy('lastServiceDate', descending: true).get();

    return snap.docs.map((doc) => MaintenanceTask.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> saveTask(String carNumber, MaintenanceTask task) async {
    await _tasksCollection(carNumber).add(task.toJson());
  }

  Future<void> clearTasks(String carNumber) async {
    final collection = _tasksCollection(carNumber);
    final query = await collection.get();

    final batch = firestore.batch();
    for (var doc in query.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
