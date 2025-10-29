import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/purchase/purchase_cubit.dart';
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
        FakeProduct('sub_3_months', S.of(context).subscription_3_month, '1.99', 3),
        FakeProduct('sub_6_months', S.of(context).subscription_6_month, '2.99', 6),
        FakeProduct('sub_12_months', S.of(context).subscription_12_month, '3.99', 12),
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
    debugPrint('Current user UID: ${user?.uid}');
    if (user == null) {
      _showSnack(S.of(context).authorization_required);
      return;
    }

    if (widget.debugMode && product is FakeProduct) {
      await Future.delayed(const Duration(milliseconds: 500));
      await context.read<PurchaseCubit>().buySubscription(user.uid, double.parse(product.price), months);
      _showSnack("${S.of(context).test_subscription} $months ${S.of(context).successfully_completed}");
      return;
    }

    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);

    final price = double.tryParse(product.price.replaceAll(RegExp('[^0-9.]'), '')) ?? 0.0;
    await context.read<PurchaseCubit>().buySubscription(user.uid, price, months);

    _showSnack("${S.of(context).test_subscription} $months ${S.of(context).successfully_completed}");
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
            : ListView.separated(
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
                      : FakeProduct(product.id, product.title, product.price, months);

                  return SubscriptionPlanCard(
                    product: fakeProduct,
                    months: months,
                    isSelected: _selectedMonths == months,
                    onBuy: () => _buy(product, months),
                  );
                },
              ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.blue700));
  }
}
