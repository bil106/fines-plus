enum PurchaseEventType { success, error }

class PurchaseEvent {
  final PurchaseEventType type;
  final String? message;

  PurchaseEvent.success() : type = PurchaseEventType.success, message = null;

  PurchaseEvent.error(this.message) : type = PurchaseEventType.error;
}
