import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/purchase/purchase_cubit.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/features/subscription/data/models/fake_product.dart';
import 'package:fines_plus/features/subscription/data/repository/subscription_repository.dart';
import 'package:fines_plus/features/subscription/domain/entities/subscription.dart';
import 'package:fines_plus/features/subscription/domain/usecases/buy_subscription.dart';
import 'package:fines_plus/features/subscription/domain/usecases/get_available_plans.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:fines_plus/features/subscription/presentation/widgets/subscription_plan_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';


@RoutePage()
class SubscriptionScreen extends StatefulWidget {
  final bool debugMode;
  final VoidCallback? onBack;

  const SubscriptionScreen({super.key, this.debugMode = true, this.onBack});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = false;
  bool _isLoading = true;
  List<dynamic> _products = [];
  int? _selectedMonths;

  @override
  void initState() {
    super.initState();
    _initStoreInfo();
  }

  Future<void> _initStoreInfo() async {
    setState(() => _isLoading = true);

    if (widget.debugMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      final testProducts = [
        FakeProduct('sub_3_months', '3 months', '1.99', 3),
        FakeProduct('sub_6_months', '6 months', '2.99', 6),
        FakeProduct('sub_12_months', '12 months', '3.99', 12),
      ];
      if (mounted) {
        setState(() {
          _available = true;
          _products = testProducts;
          _isLoading = false;
        });
      }
      return;
    }

    final isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      if (mounted) {
        setState(() {
          _available = false;
          _isLoading = false;
        });
      }
      return;
    }

    const productIds = {'sub_3_months', 'sub_6_months', 'sub_12_months'};
    final response = await _iap.queryProductDetails(productIds);

    if (mounted) {
      setState(() {
        _available = true;
        _products = response.productDetails;
        _isLoading = false;
      });
    }
  }

  Future<void> _buy(dynamic product, int months) async {
    setState(() => _selectedMonths = months);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showSnack("Authorization required");
      return;
    }

    if (widget.debugMode && product is FakeProduct) {
      await Future.delayed(const Duration(milliseconds: 500));
      context.read<SubscriptionCubit>().purchase(user.uid, product as SubscriptionPlan);
      _showSnack("Test subscription for $months months completed");
      return;
    }

    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);

    final price = double.tryParse(product.price.replaceAll(RegExp('[^0-9.]'), '')) ?? 0.0;
    await context.read<PurchaseCubit>().buySubscription(user.uid, price, months);

    _showSnack("Subscription for $months months completed");
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.blue700));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => SubscriptionCubit(
        GetAvailablePlansUseCase(context.read<ISubscriptionRepository>()),
        BuySubscriptionUseCase(context.read<ISubscriptionRepository>()),
      )..loadPlans(),
      child: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionBought) {
            _showSnack("Subscription for ${state.plan.months} months completed");
          } else if (state is SubscriptionError) {
            _showSnack(state.message);
          }
        },
        builder: (context, state) {
          if (_isLoading) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!_available) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: Text("Store unavailable")),
            );
          }

          return Scaffold(
            backgroundColor: AppColors.grey50,
            appBar: AppBar(
              backgroundColor: AppColors.grey50,
              elevation: 0,
              leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack),
              title: Text(
                S.of(context).subscription,
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            body: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    final months = product.id == 'sub_3_months'
                        ? 3
                        : product.id == 'sub_6_months'
                        ? 6
                        : 12;
                    return SubscriptionPlanCard(
                      product: product,
                      months: months,
                      isSelected: _selectedMonths == months,
                      onBuy: () => _buy(product, months),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}

