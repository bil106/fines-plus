import 'dart:async';

import 'package:fines_plus/features/expenses/data/models/expense.dart';
import 'package:fines_plus/features/expenses/data/repository/expense_repository.dart';
import 'package:fines_plus/features/expenses/presentation/cubit/expenses_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';




class ExpensesCubit extends Cubit<ExpensesState> {
  final ExpenseRepository repository;
  StreamSubscription<List<Expense>>? _sub;

  ExpensesCubit({required this.repository}) : super(ExpensesState(loading: true));

  void watch(String carNumber, String techPassport) {
    _sub?.cancel();
    emit(state.copyWith(loading: true));
    _sub = repository.watchExpenses(carNumber: carNumber,).listen(
          (items) => emit(state.copyWith(loading: false, items: items, error: null)),
          onError: (e) => emit(state.copyWith(loading: false, error: e.toString())),
        );
  }

Future<void> add(String carNumber, String techPassport, Expense expense) async {
    final docRef = await repository.addExpense(
      carNumber: carNumber,
    
      expense: expense,
    );

    debugPrint('Expense added in Cubit: ${expense.toFirestore()} with ID: ${docRef.id}');
  }


  Future<void> update(String carNumber, String techPassport, String id, Map<String, dynamic> fields) async {
    await repository.updateExpense(
        carNumber: carNumber,  expenseId: id, updatedFields: fields);
  }

  Future<void> delete(String carNumber, String techPassport, String id) async {
    await repository.deleteExpense(carNumber: carNumber,  expenseId: id);
  }
void clearExpensesForCar() {
    _sub?.cancel();
    _sub = null;
    emit(ExpensesState(loading: false, items: [], error: null));
    debugPrint("ExpensesCubit unsubscribed and cleared items");
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
