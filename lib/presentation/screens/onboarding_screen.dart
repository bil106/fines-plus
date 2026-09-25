import 'package:design_system/widget/app_back_button.dart';

import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/app/router/app_router.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:fines_plus/core/theme/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// One onboarding slide's copy/art. Built per-brand in build() rather than
/// as a fixed list, since the fines slide only applies to brands with
/// AppConfig.finesCheckEnabled - see _pages().
class _OnboardingPageSpec {
  final String title;
  final String subtitle;
  final String imagePath;

  const _OnboardingPageSpec({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}

@RoutePage()
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final pageController = PageController();
  int currentPage = 0;
  String _versionLabel = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() => _versionLabel = 'v${info.version}+${info.buildNumber}');
      }
    });
  }

  /// Fines slide is only shown for brands with the fines-check feature
  /// (AppConfig.finesCheckEnabled) - there's no equivalent outside Ukraine,
  /// and this brand's onboarding shouldn't promise a feature it doesn't have.
  List<_OnboardingPageSpec> _pages(BuildContext context, bool finesCheckEnabled) {
    return [
      _OnboardingPageSpec(
        title: S.current.maintenance_control,
        subtitle: S.current.car_inspection,
        imagePath: "assets/images/maintenance_bg.png",
      ),
      _OnboardingPageSpec(
        title: S.current.insurance_control,
        subtitle: S.current.keep_track,
        imagePath: "assets/images/insurance_bg.png",
      ),
      if (finesCheckEnabled)
        _OnboardingPageSpec(
          title: S.current.fines_control,
          subtitle: S.current.get_notified,
          imagePath: "assets/images/fines_bg.png",
        ),
      _OnboardingPageSpec(
        title: S.current.analytics,
        subtitle: S.current.track_costs,
        imagePath: "assets/images/analytics_bg.png",
      ),
    ];
  }

  Widget _buildPage({
    required int pageIndex,
    required int pageCount,
    required String title,
    required String subtitle,
    required String imagePath,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    final bool isShort = size.height < 600;
    final bool isLastInfoPage = pageIndex == pageCount - 1;
    final accent = _accent(context);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(height: isShort ? 1 : 60),

              Image.asset(
                imagePath,
                width: isShort ? 150 : 260,
                height: isShort ? 150 : 260,
                fit: BoxFit.contain,
              ),

              SizedBox(height: isShort ? 1 : 60),

              Text(
                title,
                textAlign: TextAlign.center,
                style: context.brandTheme.displayTextStyle.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: textTheme.black16.copyWith(color: AppColors.textSecondary),
              ),

              SizedBox(height: isShort ? 20 : 100),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: AppColors.neutreBlanc,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    if (isLastInfoPage) {
                      context.router.push(RegistrationRoute());
                    } else if (pageIndex < pageCount - 1) {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    (pageIndex == 0)
                        ? S.of(context).next
                        : (isLastInfoPage
                              ? S.of(context).of_course
                              : S.of(context).good),
                    style: textTheme.black18bold.copyWith(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutreBlanc,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  /// The mockup's accent is the raw brand hex, not Material3's tonal
  /// colorScheme.primary - same source the registration/subscription
  /// screens use for their own CTA.
  Color _accent(BuildContext context) =>
      ThemeConfig.hexToColor(context.watch<AppConfig>().primaryColorHex);

  Widget _buildDots(int pageCount) {
    final accent = _accent(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final bool isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? accent : AppColors.inactiveDot,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final background = context.brandTheme.surfaceBg;
    final finesCheckEnabled = context.watch<AppConfig>().finesCheckEnabled;
    final pages = _pages(context, finesCheckEnabled);
    return Scaffold(
      backgroundColor: background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(20),
        child: AppBar(
          leading: ModalRoute.of(context)?.canPop == true
              ? const AppBackButton()
              : null,
          backgroundColor: background,
          surfaceTintColor: AppColors.transparent,
          elevation: 0,
        ),
      ),
      body: Stack(
        children: [
          PageView(
            controller: pageController,
            onPageChanged: (value) => setState(() => currentPage = value),
            children: [
              for (var i = 0; i < pages.length; i++)
                _buildPage(
                  pageIndex: i,
                  pageCount: pages.length,
                  title: pages[i].title,
                  subtitle: pages[i].subtitle,
                  imagePath: pages[i].imagePath,
                ),
            ],
          ),
          if (!isLandscape)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: _buildDots(pages.length),
            ),
          Positioned(
            bottom: 6,
            right: 12,
            child: Text(
              _versionLabel,
              style: const TextStyle(color: AppColors.black26, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
