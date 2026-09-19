import 'package:core_data/core_data.dart';
import 'package:fines_plus/features/fines/domain/fines_diff.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FineHistory record(List<Map<String, dynamic>> fines, {Set<String> paid = const {}}) => FineHistory(
    id: 'h',
    userId: 'u',
    carNumber: 'AA1234AA',
    docSeries: '',
    docNumber: '',
    checkedAt: DateTime(2026, 9, 1),
    fines: fines,
    paidFines: paid,
  );

  test('unpaidIds skips fines paid at the source or marked by the user', () {
    final ids = FinesDiff.unpaidIds(
      record(
        [
          {'id': 'a', 'paid': true},
          {'id': 'b', 'paid': false},
          {'id': 'c'},
        ],
        paid: {'c'},
      ),
    );
    expect(ids, {'b'});
    expect(FinesDiff.unpaidIds(null), isEmpty);
  });

  test('newUnpaidCount counts only unpaid fines not known before', () {
    final fines = [
      {'id': 'a', 'paid': true},
      {'id': 'b', 'paid': false},
      {'id': 'new', 'paid': false},
    ];
    expect(FinesDiff.newUnpaidCount(fines, {'b'}), 1);
    expect(FinesDiff.newUnpaidCount(fines, {}), 2);
    expect(FinesDiff.newUnpaidCount([], {'b'}), 0);
  });
}
