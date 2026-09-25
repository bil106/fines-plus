import 'package:design_system/widget/app_back_button.dart';

import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/app/router/app_router.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:fines_plus/core/theme/theme_config.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_analytics_hero.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_fines_hero.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_insurance_hero.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_maintenance_hero.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// One onboarding slide's copy/art. Built per-brand in build() rather than
/// as a fixed list, since the fines slide only applies to brands with
/// AppConfig.finesCheckEnabled - see _pages().
class _OnboardingPageSpec {
  final String title;
  final String subtitle;
  final Widget Function(Animation<double> entrance, bool isActive) hero;

  const _OnboardingPageSpec({
    required this.title,
    required this.subtitle,
    required this.hero,
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

  /// Page offset of [index] from the current scroll position (0 when it is
  /// fully shown, -1/1 when a whole page away).
  double _swipeDelta(int index) {
    final position = pageController.hasClients &&
            pageController.position.haveDimensions
        ? pageController.page ?? currentPage.toDouble()
        : currentPage.toDouble();
    return index - position;
  }

  /// Fines slide is only shown for brands with the fines-check feature
  /// (AppConfig.finesCheckEnabled) - there's no equivalent outside Ukraine,
  /// and this brand's onboarding shouldn't promise a feature it doesn't have.
  List<_OnboardingPageSpec> _pages(BuildContext context, bool finesCheckEnabled) {
    return [
      _OnboardingPageSpec(
        title: S.current.maintenance_control,
        subtitle: S.current.car_inspection,
        hero: (entrance, isActive) => OnboardingMaintenanceHero(
          entrance: entrance,
          isActive: isActive,
        ),
      ),
      _OnboardingPageSpec(
        title: S.current.insurance_control,
        subtitle: S.current.keep_track,
        hero: (entrance, _) => OnboardingInsuranceHero(
          entrance: entrance,
          accent: _accent(context),
        ),
      ),
      if (finesCheckEnabled)
        _OnboardingPageSpec(
          title: S.current.fines_control,
          subtitle: S.current.get_notified,
          hero: (entrance, isActive) => OnboardingFinesHero(
            entrance: entrance,
            isActive: isActive,
            accent: _accent(context),
          ),
        ),
      _OnboardingPageSpec(
        title: S.current.analytics,
        subtitle: S.current.track_costs,
        hero: (entrance, _) => OnboardingAnalyticsHero(entrance: entrance),
      ),
    ];
  }

  /// CTA wording per page: "Далі" on the first, "Добре" on the middle ones,
  /// "Зрозуміло" on the last.
  String _label(BuildContext context, int pageIndex, int pageCount) {
    if (pageIndex == 0) return S.of(context).next;
    return pageIndex == pageCount - 1
        ? S.of(context).of_course
        : S.of(context).good;
  }

  void _onPressed(int pageIndex, int pageCount) {
    if (pageIndex == pageCount - 1) {
      context.router.push(RegistrationRoute());
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildPage({
    required int pageIndex,
    required int pageCount,
    required _OnboardingPageSpec spec,
  }) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, _) {
        final delta = _swipeDelta(pageIndex);
        // A page counts as active once it is mostly on screen, so its
        // entrance plays while it slides in rather than after it lands.
        final isActive = delta.abs() < 0.75;
        return OnboardingPage(
          isActive: isActive,
          swipeDelta: delta,
          title: spec.title,
          subtitle: spec.subtitle,
          label: _label(context, pageIndex, pageCount),
          previousLabel: pageIndex == 0
              ? null
              : _label(context, pageIndex - 1, pageCount),
          accent: _accent(context),
          onPressed: () => _onPressed(pageIndex, pageCount),
          heroBuilder: (context, entrance) => spec.hero(entrance, isActive),
        );
      },
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
          width: isActive ? 24 : 10,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: AppBorders.radius50,
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
                  spec: pages[i],
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
