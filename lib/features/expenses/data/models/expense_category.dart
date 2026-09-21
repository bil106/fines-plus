enum ExpenseCategory { fuel, service, tuning, carWash, insurance, other }
String expenseCategoryToString(ExpenseCategory c) => c.toString().split('.').last;

ExpenseCategory expenseCategoryFromString(String name) {
  try {
    return ExpenseCategory.values.firstWhere(
      (e) => expenseCategoryToString(e) == name,
    );
  } catch (_) {
    return ExpenseCategory.other;
  }
}
