import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reminder_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ReminderModel extends Equatable {
  final String id;
  final String title;
  final String description;
  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  final DateTime dateTime;
  final bool isCompleted;
  @JsonKey(defaultValue: '')
  final String ownerId;

  const ReminderModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.ownerId,
    this.isCompleted = false,
  });

  ReminderModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isCompleted,
    String? ownerId,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      ownerId: ownerId ?? this.ownerId,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) => _$ReminderModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReminderModelToJson(this);

  @override
  List<Object?> get props => [id, title, description, dateTime, isCompleted, ownerId];

  static DateTime _fromTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate().toLocal();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp).toLocal();
    } else {
      return DateTime.now();
    }
  }

  static Timestamp _toTimestamp(DateTime date) => Timestamp.fromDate(date.toUtc());
}
