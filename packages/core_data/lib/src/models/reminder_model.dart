import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ReminderModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final bool isCompleted;

  const ReminderModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isCompleted = false,
  });

  ReminderModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isCompleted,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }


 Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime.toUtc()), 
      'isCompleted': isCompleted,
    };
  }

 
factory ReminderModel.fromJson(Map<String, dynamic> json) {
    final dateTimeValue = json['dateTime'];
    DateTime dateTime;

    if (dateTimeValue is Timestamp) {
      dateTime = dateTimeValue.toDate().toLocal();
    } else if (dateTimeValue is String) {
      dateTime = DateTime.parse(dateTimeValue).toLocal();
    } else {
      dateTime = DateTime.now();
    }

    return ReminderModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dateTime: dateTime,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
  @override
  List<Object?> get props => [id, title, description, dateTime, isCompleted];
}
