import 'dart:async';

import 'package:fines_plus/features/subscription/data/repository/subscription_repository.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fines_plus/features/subscription/domain/entities/subscription.dart';
import 'purchase_state.dart';
import 'purchase_event.dart';

class PurchaseCubit extends Cubit<PurchaseState> {
  final ISubscriptionRepository repo;
  bool enabled;
  bool _inProgress = false;
  late final StreamSubscription _sub;

  PurchaseCubit(this.repo, {this.enabled = true}) : super(PurchaseIdle()) {
    _sub = repo.events.listen(_handleEvent);
  }
Future<void> buy(SubscriptionPlan plan) async {
    if (!enabled || _inProgress || isClosed) return;

    _inProgress = true;
    emit(PurchaseInProgress());

    try {
      FirebaseCrashlytics.instance.log('PurchaseCubit.startPurchase: ${plan.id}');

      await repo.startPurchase(plan);
    } catch (e, s) {
      _inProgress = false;

      FirebaseCrashlytics.instance.recordError(e, s);

      if (!isClosed) {
        emit(PurchaseError(e.toString()));
      }
    }
  }


 void _handleEvent(PurchaseEvent event) {
    if (isClosed) return;

    _inProgress = false;

    if (event.type == PurchaseEventType.success) {
      emit(PurchaseSuccess());
    } else if (event.message == 'canceled' || event.message == 'pending') {
      // User dismissed dialog or payment is pending — silently return to Idle
      // so the buy button becomes available again without showing an error.
      emit(PurchaseIdle());
    } else {
      emit(PurchaseError(event.message ?? 'Unknown error'));
    }
  }
Future<void> restore() async {
    if (!enabled || _inProgress || isClosed) return;

    _inProgress = true;
    emit(PurchaseInProgress());

    try {
      FirebaseCrashlytics.instance.log('PurchaseCubit.restorePurchases');
      await repo.restorePurchases();
    } catch (e, s) {
      _inProgress = false;
      FirebaseCrashlytics.instance.recordError(e, s);
      if (!isClosed) {
        emit(PurchaseError(e.toString()));
      }
    }
  }


 @override
  Future<void> close() async {
    FirebaseCrashlytics.instance.log('PurchaseCubit closed');
    await _sub.cancel();
    return super.close();
  }

}
