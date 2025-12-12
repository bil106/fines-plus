import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:fines_plus/features/subscription/data/repository/subscription_repository_impl.dart';
import 'package:fines_plus/features/subscription/domain/entities/subscription.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:fines_plus/router/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  Future<void> _onPlanSelected(int index) async {
    setState(() => _selectedIndex = index);
  }

  Future<void> _buySelectedPlan() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      context.router.push(CarInfoRoute());
      return;
    }

    final planData = plans[_selectedIndex];

    final subscriptionPlan = SubscriptionPlan(
      id: planData["productId"],
      title: planData["title"],
      price: planData["price"],
      months: planData["months"],
      features: [],
    );

    await context.read<SubscriptionRepositoryImpl>().buySubscription(user.uid, subscriptionPlan);
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
          title: Text(S.of(context).subscription, style: textTheme.headlineMedium),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // _buildFeatureRow('assets/icons/no_ad.svg', S.of(context).no_ads, isSvg: true),
                    // _buildFeatureRow(Icons.cloud_upload, S.of(context).increased_download_limit),
                    // _buildFeatureRow(Icons.analytics, S.of(context).analitics),
                    // _buildFeatureRow(Icons.search, S.of(context).search_fines),
                  ],
                ),
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
                            color: isSelected ? null : Colors.white,
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
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),

                              AppSpacers.verticalMedium,
                              if (plan["hasTrial"])
                                Text(
                                  "7-day free trial",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : AppColors.blue700,
                                  ),
                                ),

                              AppSpacers.verticalMedium,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    plan["title"],
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : AppColors.blue700,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "\$${plan["pricePerDay"]} / day",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : AppColors.blue700,
                                        ),
                                      ),
                                      Text(
                                        "\$${plan["oldPrice"]}",
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
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: _buySelectedPlan,

                        child: Text(
                          S.of(context).get_plan,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    AppSpacers.verticalLarge,

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 6),
                        Text(S.of(context).money_back, style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),

                    AppSpacers.verticalLarge,

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        S.of(context).text_automatically_renew,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                    ),

                    AppSpacers.verticalLarge,

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, color: Colors.green),
                        SizedBox(width: 6),
                        Text(S.of(context).pay_safe, style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),

                    AppSpacers.verticalLarge,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildFeatureRow(dynamic iconOrPath, String text, {bool isSvg = false}) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4),
  //     child: Row(
  //       children: [
  //         isSvg
  //             ? SvgPicture.asset(
  //                 iconOrPath,
  //                 width: 28,
  //                 height: 28,
  //                 colorFilter: const ColorFilter.mode(AppColors.blue700, BlendMode.srcIn),
  //               )
  //             : Icon(iconOrPath, color: AppColors.blue700),
  //         AppSpacers.verticalSmallMedium,
  //         Text(text, style: Theme.of(context).textTheme.bodyLarge),
  //       ],
  //     ),
  //   );
  // }
}
