import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/car_info_cubit.dart';
import 'package:core_cubit/cubit/car_info_state.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_text_theme.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/widgets/ad_banner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


@RoutePage()
class FinesScreen extends StatefulWidget {
  final VoidCallback? onFineCheck;
  const FinesScreen({super.key, this.onFineCheck});

  @override
  State<FinesScreen> createState() => _FinesScreenState();
}

class _FinesScreenState extends State<FinesScreen> {

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
    final carInfoCubit = context.read<CarInfoCubit>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Container(
        color: AppColors.grey50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppSpacers.verticalGigantic,
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(color: AppColors.blue700, borderRadius: BorderRadius.circular(50)),
                alignment: Alignment.center,
                child: Text('LOGO', style: textTheme.whiteBigBold),
              ),
              AppSpacers.verticalMassive,

              BlocBuilder<CarInfoCubit, CarInfoState>(
                builder: (context, state) {
                  final isLoading = state.status is CarInfoLoadingStatus;

                  return SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue700,
                        shape: RoundedRectangleBorder(borderRadius: AppBorders.radius16),
                      ),
                      onPressed: carInfoCubit.isFormValid && !isLoading ? () => carInfoCubit.checkFines() : null,
                      child: Text(S.of(context).check_fines, style: textTheme.whiteNormal),
                    ),
                  );
                },
              ),

              AppSpacers.verticalXXLarge,
              Container(
                width: double.infinity,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.neutreBlanc,
                  borderRadius: AppBorders.radius16,
                  boxShadow: [
                    BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    AppSpacers.horizontalLarge,
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(color: AppColors.blue700, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: AppColors.neutreBlanc, size: 26),
                    ),
                    AppSpacers.horizontalLarge,
                    Expanded(child: Text(S.of(context).no_fines, style: textTheme.noFinesText)),
                  ],
                ),
              ),
                AppSpacers.verticalMaxMassive,
            const AdBannerWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
