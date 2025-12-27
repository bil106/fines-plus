import 'dart:async';

import 'package:fines_plus/features/subscription/data/repository/subscription_repository.dart';
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
    if (!enabled || _inProgress) return;

    _inProgress = true;
    emit(PurchaseInProgress());

    try {
      await repo.startPurchase(plan);
    } catch (e) {
      _inProgress = false;
      emit(PurchaseError(e.toString()));
    }
  }

  void _handleEvent(PurchaseEvent event) {
    _inProgress = false;

    if (event.type == PurchaseEventType.success) {
      emit(PurchaseSuccess());
    } else {
      emit(PurchaseError(event.message ?? 'Unknown error'));
    }
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
