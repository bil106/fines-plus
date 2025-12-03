import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fines_plus/features/maintenance/data/models/maintenance_task.dart';

class ScheduleFirebaseRepository {
  final FirebaseFirestore firestore;

  ScheduleFirebaseRepository(this.firestore);

CollectionReference<Map<String, dynamic>> _tasksCollection(String carNumber) {
    return FirebaseFirestore.instance.collection('reminders').doc(carNumber).collection('items');
  }

  Future<void> addTask(String carNumber, MaintenanceTask task) async {
    await _tasksCollection(carNumber).doc(task.id).set(task.toJson());
  }

Future<List<MaintenanceTask>> loadTasks(String carNumber) async {
    final snapshot = await _tasksCollection(carNumber).get();
    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id; 
      return MaintenanceTask.fromJson(data);
    }).toList();
  }

Future<void> saveTask(String carNumber, MaintenanceTask task) async {
    final collection = _tasksCollection(carNumber);
    if (task.id == null) {
      final ref = collection.doc();
      final newTask = task.copyWith(id: ref.id);
      await ref.set(newTask.toJson());
    } else {
      await collection.doc(task.id).set(task.toJson(), SetOptions(merge: true));
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
