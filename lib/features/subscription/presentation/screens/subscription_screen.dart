import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/purchase/purchase_cubit.dart';
import 'package:fines_plus/features/subscription/data/models/trial_manager.dart';
import 'package:fines_plus/features/subscription/domain/entities/subscription.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:fines_plus/router/app_router.dart';
import 'package:fines_plus/router/home_screen_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/features/subscription/data/models/fake_product.dart';
import 'package:fines_plus/features/subscription/presentation/widgets/subscription_plan_card.dart';


@RoutePage()
class SubscriptionScreen extends StatefulWidget {
  final bool debugMode;
  final VoidCallback? onBack;
  final VoidCallback? onPurchaseSuccess;
  const SubscriptionScreen({super.key, this.debugMode = true, this.onBack, this.onPurchaseSuccess});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = false;
  bool _isLoading = true;
  bool get _isUserLoggedIn => FirebaseAuth.instance.currentUser != null;

  List<dynamic> _products = [];
  int? _selectedMonths;
TrialStatus _trialStatus = TrialStatus.none;
  bool _trialLoading = true;
  @override
  void initState() {
    super.initState();
    _initStoreInfo();
    _loadTrialStatus();
  }
Future<void> _loadTrialStatus() async {
    final status = await TrialManager.getTrialStatus();
    if (mounted) {
      setState(() {
        _trialStatus = status;
        _trialLoading = false;
      });
    }
  }
Future<void> _startTrial() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      context.router.push(CarInfoRoute());
      return;
    }

    await TrialManager.startTrial();
    await context.read<PurchaseCubit>().buySubscription(user.uid, 0.0, 1);

    setState(() => _trialStatus = TrialStatus.active);
    _showSnack("Пробний період активовано ✅");

 
    final rootRouter = context.router.root;

    await Future.delayed(const Duration(seconds: 1));

   
    widget.onPurchaseSuccess?.call();

 
    rootRouter.replaceAll([HomeRouteWrapper(initialPage: HomePage.addCar)]);
  }




  Future<void> _initStoreInfo() async {
    setState(() => _isLoading = true);

    if (widget.debugMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      final testProducts = [
        FakeProduct(id:'sub_3_months',title: S.of(context).subscription_3_month,price: '1.99',months: 3),
        FakeProduct(id: 'sub_6_months', title: S.of(context).subscription_6_month, price: '2.99', months: 6),
        FakeProduct(id: 'sub_12_months', title: S.of(context).subscription_12_month, price: '3.99', months: 12),
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


  @override
  Widget build(BuildContext context) {
     final textTheme = Theme.of(context).textTheme;
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_available) {
      return Scaffold(body: Center(child: Text(S.of(context).store_unavailable)));
    }

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text(S.of(context).subscription, style: textTheme.headlineMedium),
        backgroundColor: AppColors.grey50,
        elevation: 0,
         leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack),
      ),
    body: Padding(
        padding: const EdgeInsets.all(16),
        child: _products.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
             
                  if (_trialLoading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                  
                    if (_trialStatus == TrialStatus.none)
                      ElevatedButton(onPressed: _startTrial, child: Text("7 днів безкоштовно 🎁")),

                    if (_trialStatus == TrialStatus.active)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          "Пробний період активний ✅",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),

                    if (_trialStatus == TrialStatus.expired)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          "Пробний період минув❗️",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 12),
                  ],

                  // Subscription plans list
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = _products[index];

                        final months = product is FakeProduct
                            ? product.months
                            : product.id == 'sub_3_months'
                            ? 3
                            : product.id == 'sub_6_months'
                            ? 6
                            : 12;

                        final fakeProduct = product is FakeProduct
                            ? product
                            : FakeProduct(id: product.id, title: product.title, price: product.price, months: months);

                        return SubscriptionPlanCard(
                          product: fakeProduct,
                          months: months,
                          isSelected: _selectedMonths == months,
                        onBuy: () {
                            final plan = SubscriptionPlan(
                              id: product.id,
                              title: product.title,
                              price: double.tryParse(product.price.toString()) ?? 0.0,
                              months: months,
                              features: [],
                            );

                            context.read<SubscriptionCubit>().selectPlan(plan);

                            if (_isUserLoggedIn) {
                              // ✅ Уже зарегистрирован — переходим в основной экран
                              widget.onPurchaseSuccess?.call();
                            } else {
                              // ❌ Не зарегистрирован — идём на ввод данных авто (CarInfoScreen)
                              context.router.push(CarInfoRoute());
                            }
                          },


                        );
                      },
                    ),
                  ),
                ],
              ),
      ),

    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.blue700));
  }
}
