import 'package:core_services/services/purchase_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PurchaseCubit extends Cubit<void> {
  final PurchaseService _service;

  PurchaseCubit(this._service) : super(null);

  Future<void> buySubscription(String uid, num amount) async {
    final purchaseId = 'tx_${DateTime.now().millisecondsSinceEpoch}';
    await _service.recordPurchase(
      purchaseId: purchaseId,
      uid: uid,
      amount: amount,
    );
  }
}
