class Fine {
  final String id;
  final String violation;
  final int total;
  final DateTime date;

  Fine({
    required this.id,
    required this.violation,
    required this.total,
    required this.date,
  });

factory Fine.fromJson(Map<String, dynamic> json) {
    return Fine(
      id: json['id'].toString(),
      violation: json['violation']?.toString() ?? '',
      total: (json['total'] is int) ? json['total'] : int.tryParse(json['total'].toString()) ?? 0,
      date: (json['date'] != null) ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

}
