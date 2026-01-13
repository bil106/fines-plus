import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/app/router/home_screen_wrapper.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/features/subscription/domain/entities/subscription.dart';
import 'package:fines_plus/app/router/app_router.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/purchase/purchase_cubit.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/purchase/purchase_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  bool _navigated = false;
  final List<Map<String, dynamic>> plans = [
    {
      "title": "Quarterly Plan",
      "productId": "sub_quarter",
      "price": 20.0,
      "pricePerDay": "0.22",
      "oldPrice": "1.11",
      "months": 3,
      "popular": false,
      "hasTrial": true,
    },
    {
      "title": "Yearly Plan",
      "productId": "yearly_2549",
      "price": 50.0,
      "pricePerDay": "0.14",
      "oldPrice": "1.00",
      "months": 12,
      "popular": true,
      "hasTrial": true,
    },
  ];
  @override
  void initState() {
    super.initState();

    FirebaseCrashlytics.instance.setCustomKey('screen', 'SubscriptionScreen');
  }

  Future<void> _onPlanSelected(int index) async {
    setState(() => _selectedIndex = index);
  }

  Future<void> _buySelectedPlan() async {
    FirebaseCrashlytics.instance.log('buySelectedPlan tapped, selectedIndex=$_selectedIndex');
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      FirebaseCrashlytics.instance.log('user is null, redirecting');

      final wrapperState = context.findAncestorStateOfType<HomeScreenWrapperState>();

      if (wrapperState != null) {
        FirebaseCrashlytics.instance.log('redirect via HomeScreenWrapper');
        wrapperState.openPage(HomePage.addCar);
        return;
      }

      FirebaseCrashlytics.instance.log('redirect via router to CarInfo');
      context.router.push(CarInfoRoute());
      return;
    }

    final planData = plans[_selectedIndex];
    FirebaseCrashlytics.instance.log(
      'selected plan: '
      'productId=${planData["productId"]}, '
      'title=${planData["title"]}',
    );
    final plan = SubscriptionPlan(
      id: planData["productId"],
      title: planData["title"],
      price: planData["price"],
      months: planData["months"],
      features: [],
    );
    FirebaseCrashlytics.instance.log('calling PurchaseCubit.buy');
    context.read<PurchaseCubit>().buy(plan);
  }

  void _handlePurchaseSuccess() {
    if (!mounted) {
      FirebaseCrashlytics.instance.log('PurchaseSuccess but widget not mounted');
      return;
    }

    FirebaseCrashlytics.instance.log('Handling purchase success navigation');

    if (widget.onPurchaseSuccess != null) {
      widget.onPurchaseSuccess!.call();
      return;
    }

    final wrapperState = context.findAncestorStateOfType<HomeScreenWrapperState>();

    if (wrapperState != null) {
      wrapperState.openPage(HomePage.home);
      return;
    }

    context.router.replaceAll([HomeRouteWrapper(initialPage: HomePage.home)]);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocListener<PurchaseCubit, PurchaseState>(
      listener: (context, state) {
        if (state is PurchaseSuccess && !_navigated) {
          _navigated = true;
          FirebaseCrashlytics.instance.log('PurchaseSuccess received');
          _handlePurchaseSuccess();
        }

        if (state is PurchaseError) {
          FirebaseCrashlytics.instance.log('PurchaseError: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.energyBlue50,
        appBar: AppBar(
          backgroundColor: AppColors.energyBlue50,
          elevation: 0,

          title: Text(S.of(context).subscription, style: textTheme.headlineMedium),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 50),
                child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: []),
              ),
              AppSpacers.verticalMedium,

              Expanded(
                child: ListView(
                  children: [
                    ...List.generate(plans.length, (index) {
                      final plan = plans[index];
                      final isSelected = index == _selectedIndex;

                      return GestureDetector(
                        onTap: () => _onPlanSelected(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [AppColors.blue700, AppColors.blue700.withOpacity(0.4)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isSelected ? null : AppColors.neutreBlanc,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (plan["popular"])
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    S.of(context).most_popular,
                                    style: TextStyle(
                                      color: AppColors.neutreBlanc,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),

                              AppSpacers.verticalMedium,
                              if (plan["hasTrial"])
                                Text(
                                  "7-day free trial",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? AppColors.neutreBlanc : AppColors.blue700,
                                  ),
                                ),

                              AppSpacers.verticalMedium,
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      plan["title"],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? AppColors.neutreBlanc : AppColors.blue700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "\$${plan["pricePerDay"]} / day",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? AppColors.neutreBlanc : AppColors.blue700,
                                        ),
                                      ),
                                      Text(
                                        "\$${plan["oldPrice"]}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          decoration: TextDecoration.lineThrough,
                                          color: isSelected ? Colors.white70 : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    AppSpacers.verticalLarge,

                    SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<PurchaseCubit, PurchaseState>(
                        builder: (context, state) {
                          final loading = state is PurchaseInProgress;

                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.orange,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: loading ? null : _buySelectedPlan,
                            child: loading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    S.of(context).get_plan,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                          );
                        },
                      ),
                    ),

                    AppSpacers.verticalLarge,

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle, color: AppColors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            S.of(context).money_back,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    AppSpacers.verticalLarge,

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        S.of(context).text_automatically_renew,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.grey700),
                      ),
                    ),

                    AppSpacers.verticalLarge,

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, color: AppColors.green),
                        SizedBox(width: 6),
                        Text(S.of(context).pay_safe, style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    AppSpacers.verticalLarge,
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

                        AppSpacers.verticalLarge,
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
