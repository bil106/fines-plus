sealed class PurchaseState {}

class PurchaseIdle extends PurchaseState {}

class PurchaseInProgress extends PurchaseState {}

class PurchaseSuccess extends PurchaseState {}

class PurchaseError extends PurchaseState {
  final String message;
  PurchaseError(this.message);
}
