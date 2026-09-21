import 'package:design_system/widget/app_back_button.dart';

import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

  static const _pageCount = 4;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() => _versionLabel = 'v${info.version}+${info.buildNumber}');
      }
    });
  }

  Widget _buildPage({
    required int pageIndex,
    required String title,
    required String subtitle,
    required String imagePath,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    final bool isShort = size.height < 600;
    final bool isLastInfoPage = pageIndex == 3;

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
                style: textTheme.black28W400,
              ),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: textTheme.black54fs18,
              ),

              SizedBox(height: isShort ? 20 : 100),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () {
                    if (isLastInfoPage) {
                      context.router.push(RegistrationRoute());
                    } else if (pageIndex < _pageCount - 1) {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    (pageIndex == 0)
                        ? S.of(context).next
                        : (pageIndex <= 2
                              ? S.of(context).good
                              : S.of(context).of_course),
                    style: textTheme.white18W400,
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

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pageCount, (index) {
        final bool isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.blue700 : AppColors.grey400,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(20),
        child: AppBar(
          leading: ModalRoute.of(context)?.canPop == true
              ? const AppBackButton()
              : null,
          backgroundColor: AppColors.blue700,
          elevation: 0,
        ),
      ),
      body: Stack(
        children: [
          PageView(
            controller: pageController,
            onPageChanged: (value) => setState(() => currentPage = value),
            children: [
              _buildPage(
                pageIndex: 0,
                title: S.current.maintenance_control,
                subtitle: S.current.car_inspection,
                imagePath: "assets/images/maintenance_bg.png",
              ),
              _buildPage(
                pageIndex: 1,
                title: S.current.insurance_control,
                subtitle: S.current.keep_track,
                imagePath: "assets/images/insurance_bg.png",
              ),
              _buildPage(
                pageIndex: 2,
                title: S.current.fines_control,
                subtitle: S.current.get_notified,
                imagePath: "assets/images/fines_bg.png",
              ),
              _buildPage(
                pageIndex: 3,
                title: S.current.analytics,
                subtitle: S.current.track_costs,
                imagePath: "assets/images/analytics_bg.png",
              ),
            ],
          ),
          if (!isLandscape)
            Positioned(bottom: 40, left: 0, right: 0, child: _buildDots()),
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
