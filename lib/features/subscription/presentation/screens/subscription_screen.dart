import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_services/services/purchase_service.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_info_cubit.dart';
import 'package:fines_plus/router/app_router.dart';
import 'package:fines_plus/router/home_screen_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
  int _selectedIndex = 0;
  final List<Map<String, String>> plans = [
    {"title": "7 днів", "price": "129,99 грн. в нед."},
    {"title": "1 місяць", "price": "429,99 грн. в мес."},
    {"title": "3 дні безплатно,далі", "price": "підписатися за 899,99 грн. в рік"},
  ];
  Future<void> _onPlanSelected(int index) async {
    setState(() => _selectedIndex = index);

    final prefs = await SharedPreferences.getInstance();
    final carNumber = context.read<CarInfoCubit>().state.carNumber;
    final user = FirebaseAuth.instance.currentUser;

    final isTrial = index == 2;
    if (isTrial) {
      if (user == null) {
        // First launch - send to enter the car number, like the other plans
        context.router.push(CarInfoRoute());
        return;
      }

      final now = DateTime.now();
      final trialEnd = now.add(const Duration(days: 7));

      await FirebaseFirestore.instance.collection("purchases").doc('tx_trial_${user.uid}').set({
        "uid": user.uid,
        "carNumber": carNumber,
        "amount": 0,
        "currency": "USD",
        "months": 0,
        "source": "trial",
        "subscriptionEndDate": trialEnd,
        "trialStartDate": now,
        "trialEndDate": trialEnd,
        "isTrial": true,
        "isSubscribed": false,
        "createdAt": FieldValue.serverTimestamp(),
      });

      await prefs.setInt('trial_end_timestamp', trialEnd.millisecondsSinceEpoch);

      final wrapperState = context.findAncestorStateOfType<HomeScreenWrapperState>();
      if (wrapperState != null) {
        wrapperState.openPage(HomePage.home);
      } else {
        context.router.replaceAll([HomeRoute()]);
      }

      return;
    }

    if (carNumber.isEmpty) {
      context.router.push(CarInfoRoute());
      return;
    }

    if (user == null) {
      context.router.push(CarInfoRoute());
      return;
    }

    final plan = plans[index];
    final priceString = plan["price"]!;
    final priceDouble = double.tryParse(priceString.replaceAll(RegExp(r'[^0-9,]'), '').replaceAll(',', '.')) ?? 0.0;

    final months = plan["title"]!.contains("7 днів")
        ? 0
        : plan["title"]!.contains("1 місяць")
        ? 1
        : 12;

    final subscriptionEnd = DateTime.now().add(Duration(days: months * 30));

    await prefs.setInt('subscription_end_timestamp', subscriptionEnd.millisecondsSinceEpoch);

    final purchaseService = PurchaseService();
    await purchaseService.recordPurchase(
      purchaseId: 'tx_${user.uid}_${carNumber}_${DateTime.now().millisecondsSinceEpoch}',
      uid: user.uid,
      amount: priceDouble,
      months: months,
    );

    final wrapper = context.findAncestorStateOfType<HomeScreenWrapperState>();
    if (wrapper != null) {
      wrapper.openPage(HomePage.carInfo);
    } else {
      context.router.push(CarInfoRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocListener<SubscriptionCubit, SubscriptionState>(
      listener: (context, state) async {},
      child: Scaffold(
        backgroundColor: AppColors.energyBlue50,
        appBar: AppBar(
          backgroundColor: AppColors.energyBlue50,
          elevation: 0,
          leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack),
          title: Text(S.of(context).try_premium, style: textTheme.headlineMedium),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50, bottom: 50, left: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildFeatureRow('assets/icons/no_ad.svg', S.of(context).no_ads, isSvg: true),
                    _buildFeatureRow(Icons.cloud_upload, S.of(context).increased_download_limit),
                    _buildFeatureRow(Icons.analytics, S.of(context).analitics),
                    _buildFeatureRow(Icons.search, S.of(context).search_fines),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView.builder(
                  itemCount: plans.length + 1,
                  itemBuilder: (context, index) {
                    final textTheme = Theme.of(context).textTheme;

                    if (index < plans.length) {
                      final plan = plans[index];
                      final isSelected = index == _selectedIndex;

                      return GestureDetector(
                        onTap: () => _onPlanSelected(index),

                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [AppColors.blue700, AppColors.blue700.withOpacity(0.4)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isSelected ? null : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  plan["title"]!,
                                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  softWrap: true,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  plan["price"]!,
                                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.right,
                                  maxLines: 2,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              S.of(context).cancel_anytime,
                              style: textTheme.hintAnalitText,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => launchUrl(Uri.parse(Env.termsUrl)),
                                    child: Text(
                                      S.of(context).terms_of_use,
                                      style: textTheme.black16bold.copyWith(color: AppColors.blue700),
                                      maxLines: 2,
                                      softWrap: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Flexible(
                                  child: GestureDetector(
                                    onTap: _openPrivacy,
                                    child: Text(
                                      S.of(context).privacy_policy,
                                      style: textTheme.black16bold.copyWith(color: AppColors.blue700),
                                      maxLines: 2,
                                      softWrap: true,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(dynamic iconOrPath, String text, {bool isSvg = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          isSvg
              ? SvgPicture.asset(
                  iconOrPath,
                  width: 28,
                  height: 28,
                  colorFilter: const ColorFilter.mode(AppColors.blue700, BlendMode.srcIn),
                )
              : Icon(iconOrPath, color: AppColors.blue700),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  Future<void> _openPrivacy() async {
    final url = Uri.parse(Env.privacyPolicyUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
