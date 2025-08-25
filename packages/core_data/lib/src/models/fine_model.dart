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
  
    final totalValue = json['total'];
    int totalInt = 0;
    if (totalValue is int) {
      totalInt = totalValue;
    } else if (totalValue is String) {
      totalInt = int.tryParse(totalValue.replaceAll(RegExp(r'\D'), '')) ?? 0;
    }

    DateTime parsedDate;
    final dateStr = json['date']?.toString() ?? '';
    try {
      parsedDate = DateTime.parse(dateStr);
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return Fine(
      id: json['id']?.toString() ?? '',
      violation: json['violation']?.toString() ?? '',
      total: totalInt,
      date: parsedDate,
    );
  }
}
