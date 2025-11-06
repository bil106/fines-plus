import 'package:json_annotation/json_annotation.dart';

part 'trial_info.g.dart';

@JsonSerializable()
class TrialInfo {
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? startDate;

  final int durationDays;

  TrialInfo({this.startDate, this.durationDays = 7});

  bool get isActive => startDate != null && DateTime.now().difference(startDate!).inDays < durationDays;

  bool get isExpired => startDate != null && DateTime.now().difference(startDate!).inDays >= durationDays;

  factory TrialInfo.fromJson(Map<String, dynamic> json) => _$TrialInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TrialInfoToJson(this);

  static DateTime? _dateFromJson(int? millis) => millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);

  static int? _dateToJson(DateTime? date) => date?.millisecondsSinceEpoch;
}
