import 'package:core_data/core_data.dart';

class ExpensesState {
  final bool loading;
  final List<Expense> items;
  final String? error;

  ExpensesState({this.loading = false, this.items = const [], this.error});

  ExpensesState copyWith({bool? loading, List<Expense>? items, String? error}) {
    return ExpensesState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      error: error,
    );
  }
}
