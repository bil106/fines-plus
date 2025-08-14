import 'package:equatable/equatable.dart';

class ReminderModel extends Equatable {
  final String id; // UUID или timestamp
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'dateTime': dateTime.toIso8601String(),
        'isCompleted': isCompleted,
      };

  factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        dateTime: DateTime.parse(json['dateTime']),
        isCompleted: json['isCompleted'],
      );

  @override
  List<Object?> get props => [id, title, description, dateTime, isCompleted];
}
