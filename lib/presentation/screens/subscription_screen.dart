import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/purchase/purchase_cubit.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_available) {
      return Scaffold(body: Center(child: Text(S.of(context).store_unavailable)));
    }

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.grey50,
        leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack),
        title: Text(S.of(context).subscription),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _products.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _products.map((product) {
                  final months = product.id == 'sub_3_months'
                      ? 3
                      : product.id == 'sub_6_months'
                      ? 6
                      : 12;
                  return _buildButton("${product.title} — ${product.price}", () => _buy(product, months));
                }).toList(),
              ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue700,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        ),
        child: Text(text),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.blue700));
  }
}

class FakeProduct {
  final String id;
  final String title;
  final String price;
  final int months;
  FakeProduct(this.id, this.title, this.price, this.months);
}
