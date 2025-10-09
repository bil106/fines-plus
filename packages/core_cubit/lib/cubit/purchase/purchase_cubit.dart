import 'package:core_services/services/purchase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PurchaseCubit extends Cubit<void> {
  final PurchaseService _service;
  bool enabled;

  PurchaseCubit(this._service, {this.enabled = true}) : super(null);

  Future<void> buySubscription(String uid, num amount) async {
    if (!enabled) {
      debugPrint('Purchase feature disabled by Remote Config');
      return; 
    }

    final purchaseId = 'tx_${DateTime.now().millisecondsSinceEpoch}';
    await _service.recordPurchase(
      purchaseId: purchaseId,
      uid: uid,
      amount: amount,
    );

    debugPrint('Purchase completed: $purchaseId');
  }
}

