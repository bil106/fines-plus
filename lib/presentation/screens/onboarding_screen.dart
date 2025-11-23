import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/features/subscription/presentation/screens/subscription_screen.dart';
import 'package:flutter/material.dart';

@RoutePage()
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final pageController = PageController();
  int currentPage = 0;


  Widget _buildPage({
    required int pageIndex,
    required String title,
    required String subtitle,
    required String imagePath,
  }) {
    String buttonText = (pageIndex == 0) ? "Далі" : (pageIndex <= 2 ? "Добре" : "Зрозуміло");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 60),
            Image.asset(imagePath, width: 260, height: 260),
            const SizedBox(height: 60),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                onPressed: () {
                  if (pageIndex < 4) {
                    pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  }
                 
                },
                child: Text(buttonText, style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildSubscriptionPage() {
    return SubscriptionScreen(
      debugMode: false,
      onBack: () {
        pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      },
      onPurchaseSuccess: () {

      },
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final bool isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: isActive ? AppColors.blue700 : Colors.grey.shade400),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(20),
        child: AppBar(backgroundColor: AppColors.blue700, elevation: 0),
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
              _buildSubscriptionPage(), 
            ],
          ),
          Positioned(bottom: 40, left: 0, right: 0, child: _buildDots()),
        ],
      ),
    );
  }
}


