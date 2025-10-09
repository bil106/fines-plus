

import 'package:fines_plus/features/maintenance/data/repository/maintenance_repository.dart';

class MaintenanceTask {
  final String title;
  final String? lastServiceDate;
  final int lastMileage;
  final int? actualMileage;
  final int? intervalKm;
  final Duration? intervalTime;
  final String? comment;

  MaintenanceTask({
    required this.title,
    this.lastServiceDate,
    required this.lastMileage,
    this.actualMileage,
    this.intervalKm,
    this.intervalTime,
    this.comment,
  });

  MaintenanceTask copyWith({
    String? title,
    String? lastServiceDate,
    int? lastMileage,
    int? actualMileage,
    int? intervalKm,
    Duration? intervalTime,
    String? comment,
  }) {
    return MaintenanceTask(
      title: title ?? this.title,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      lastMileage: lastMileage ?? this.lastMileage,
      actualMileage: actualMileage ?? this.actualMileage,
      intervalKm: intervalKm ?? this.intervalKm,
      intervalTime: intervalTime ?? this.intervalTime,
      comment: comment ?? this.comment,
    );
  }

  double getProgress() {
    if (intervalKm != null && actualMileage != null) {
      final kmPassed = actualMileage! - lastMileage;
      final progress = kmPassed / intervalKm!;
      return progress.clamp(0.0, 1.0);
    }

    if (intervalTime != null && lastServiceDate != null) {
      try {
        final lastDate = DateTime.parse(_convertToISO(lastServiceDate!));
        final daysPassed = DateTime.now().difference(lastDate).inDays;
        final progress = daysPassed / intervalTime!.inDays;
        return progress.clamp(0.0, 1.0);
      } catch (_) {
        return 0.0;
      }
    }

    return 0.0;
  }

  String _convertToISO(String date) {
    final parts = date.split('.');
    if (parts.length != 3) return date;
    return "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
  }

  factory MaintenanceTask.fromJson(Map<String, dynamic> json) {
    return MaintenanceTask(
      title: json['title'],
      lastServiceDate: json['lastServiceDate'],
      lastMileage: json['lastMileage'],
      actualMileage: json['actualMileage'],
      intervalKm: json['intervalKm'],
      intervalTime: json['intervalTime'] != null ? Duration(days: json['intervalTime']) : null,
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'lastServiceDate': lastServiceDate,
        'lastMileage': lastMileage,
        'actualMileage': actualMileage,
        'intervalKm': intervalKm,
        'intervalTime': intervalTime?.inDays,
        'comment': comment,
      };
}

class LoadTasksUseCase {
  final IMaintenanceRepository repository;
  LoadTasksUseCase(this.repository);

  Future<List<MaintenanceTask>> call() => repository.getTasks();
}

class SaveTasksUseCase {
  final IMaintenanceRepository repository;
  SaveTasksUseCase(this.repository);

  Future<void> call(List<MaintenanceTask> tasks) => repository.saveTasks(tasks);
}
