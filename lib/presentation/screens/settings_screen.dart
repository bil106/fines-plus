import 'package:auto_route/auto_route.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/widgets/ad_banner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool finesCheck = true;
  bool reminders = true;
  bool pushNotifications = true;
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.grey50,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacers.verticalXLarge,
                Text(S.of(context).settings, style: textTheme.title),
                AppSpacers.verticalHuge,
                Card(
                  color: AppColors.neutreBlanc,
                  shape: RoundedRectangleBorder(borderRadius: AppBorders.radius22),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Column(
                      children: [
                        AppSpacers.verticalLarge,
                        _buildSettingRow(
                          title: S.of(context).checking_fines,
                          value: finesCheck,
                          onChanged: (val) => setState(() => finesCheck = val),
                        ),
                        AppSpacers.verticalMediumLarge,
                        Divider(thickness: 3, color: AppColors.grey50),
                        AppSpacers.verticalMediumLarge,
                        _buildSettingRow(
                          title: S.of(context).reminder,
                          value: reminders,
                          onChanged: (val) => setState(() => reminders = val),
                        ),
                        AppSpacers.verticalMediumLarge,
                        Divider(thickness: 3, color: AppColors.grey50),
                        AppSpacers.verticalMediumLarge,
                        _buildSettingRow(
                          title: S.of(context).push_notifications,
                          value: pushNotifications,
                          onChanged: (val) => setState(() => pushNotifications = val),
                        ),
                        
                      ],
                    ),
                  ),
                ),
                AppSpacers.verticalLargeXL,
              const AdBannerWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: textTheme.titleLarge)),
        Switch(value: value, onChanged: onChanged, activeColor: AppColors.neutreBlanc, activeTrackColor: Colors.blue),
      ],
    );
  }
}
