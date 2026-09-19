import 'package:core_data/core_data.dart';

/// What a fines check found compared with the previous one.
class FinesDiff {
  /// Ids of the unpaid fines in [record] (none when there was no check yet).
  static Set<String> unpaidIds(FineHistory? record) {
    if (record == null) return {};
    return {
      for (final entry in record.fines.asMap().entries)
        if (!record.isFinePaid(_fineId(entry.key, entry.value), entry.value)) _fineId(entry.key, entry.value),
    };
  }

  /// Unpaid fines in [fines] that weren't already known as unpaid.
  static int newUnpaidCount(List<Map<String, dynamic>> fines, Set<String> knownUnpaidIds) {
    var count = 0;
    for (final entry in fines.asMap().entries) {
      if (entry.value['paid'] == true) continue;
      if (!knownUnpaidIds.contains(_fineId(entry.key, entry.value))) count++;
    }
    return count;
  }

  static String _fineId(int index, Map<String, dynamic> fine) => fine['id']?.toString() ?? '$index';
}
