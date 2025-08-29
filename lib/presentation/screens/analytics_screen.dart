
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_cubit/cubit/analytics_cubit.dart';
import 'package:core_data/core_data.dart';
import 'package:core_repository/analytics_repository.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/widgets/ad_banner_widget.dart';
import 'package:fines_plus/core/widgets/extensions/analytics/analytics_field.dart';
import 'package:fines_plus/core/widgets/extensions/analytics/analytics_fuel_field.dart';
import 'package:fines_plus/core/widgets/extensions/analytics/analytics_period_field.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class AnalyticsScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final String carNumber;

  const AnalyticsScreen({super.key, this.onBack, required this.carNumber});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AnalyticsCubit(repository: AnalyticsRepository(firestore: FirebaseFirestore.instance)),
      child: _AnalyticsScreenView(onBack: onBack),
    );
  }
}

class _AnalyticsScreenView extends StatefulWidget {
  final VoidCallback? onBack;

  const _AnalyticsScreenView({this.onBack});

  @override
  State<_AnalyticsScreenView> createState() => _AnalyticsScreenViewState();
}

class _AnalyticsScreenViewState extends State<_AnalyticsScreenView> {
  final TextEditingController _mileageController = TextEditingController();
BannerAd? _bannerAd;
@override
  void initState() {
    super.initState();
   
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.largeBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() {}),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint("Ad failed: $error");
        },
      ),
    )..load();
  }
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.grey50,
        leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack ?? () {}),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Аналитіка", style: textTheme.title),
              AppSpacers.verticalMedium,

              Text("За період", style: textTheme.historyText),
              AppSpacers.verticalXSmall,
              AnalyticsPeriodField(initialDate: DateTime.now(), onChanged: (date) {}),
             AppSpacers.verticalMedium,

              Text("Заправил  (літров)", style: textTheme.historyText),
              const SizedBox(height: 4),
              AnalyticsFuelField(pricePerLiter: 45),
             AppSpacers.verticalMedium,

              Text("Пробіг (км)", style: textTheme.historyText),
              AppSpacers.verticalXSmall,
              AnalyticsField(controller: _mileageController),
              AppSpacers.verticalMedium,

              
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Center(
                  child: SizedBox(
                    height: 180,
                    width: 180,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            value: 60,
                            color: Colors.green,
                            title: "60%",
                            radius: 80,
                            titleStyle: textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          PieChartSectionData(
                            value: 40,
                            color: Colors.blue,
                            title: "40%",
                            radius: 80,
                            titleStyle: textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              AppSpacers.verticalLargeXL,
               const AdBannerWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
