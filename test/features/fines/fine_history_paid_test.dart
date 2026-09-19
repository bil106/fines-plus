import 'package:core_data/core_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FineHistory history(List<Map<String, dynamic>> fines, {Set<String> paid = const {}}) => FineHistory(
    id: 'h',
    userId: 'u',
    carNumber: 'AA1234AA',
    docSeries: '',
    docNumber: '',
    checkedAt: DateTime(2026, 9, 1),
    fines: fines,
    paidFines: paid,
  );

  test('a fine is paid when the source says so or the user marked it', () {
    final record = history(
      [
        {'id': 'a', 'paid': true},
        {'id': 'b', 'paid': false},
        {'id': 'c'},
      ],
      paid: {'c'},
    );

    expect(record.isFinePaid('a', record.fines[0]), isTrue);
    expect(record.isFinePaid('b', record.fines[1]), isFalse);
    expect(record.isFinePaid('c', record.fines[2]), isTrue);
    expect(record.paidCount, 2);
  });
}
