import 'package:auto_route/auto_route.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/router/app_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter/material.dart';

@RoutePage()
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Widget _buildPage({required String title, required String subtitle, required String imagePath}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Align(
          alignment: Alignment.center,
          child: Transform.translate(
            offset: const Offset(0, -40),
            child: Image.asset(imagePath, fit: BoxFit.contain, width: double.infinity),
          ),
        ),

        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.grey50, Color.fromARGB(31, 43, 43, 43)],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 10),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(seconds: 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(subtitle, style: TextStyle(fontSize: 28, color: Colors.white.withOpacity(0.9))),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.grey50),
      body: IntroductionScreen(
        globalBackgroundColor: AppColors.grey50,
        pages: [
          PageViewModel(
            titleWidget: const SizedBox.shrink(),
            bodyWidget: const SizedBox.shrink(),
            decoration: const PageDecoration(fullScreen: true),
            image: _buildPage(
              title: "Контроль ТО",
              subtitle: "Нагадування про техогляд та сервіс авто",
              imagePath: "assets/images/maintenance_bg.png",
            ),
          ),
          PageViewModel(
            titleWidget: const SizedBox.shrink(),
            bodyWidget: const SizedBox.shrink(),
            decoration: const PageDecoration(fullScreen: true),
            image: _buildPage(
              title: "Контроль страховки",
              subtitle: "Слідкуйте за термінами страховки авто",
              imagePath: "assets/images/insurance_bg.png",
            ),
          ),
          PageViewModel(
            titleWidget: const SizedBox.shrink(),
            bodyWidget: const SizedBox.shrink(),
            decoration: const PageDecoration(fullScreen: true),
            image: _buildPage(
              title: "Контроль штрафів",
              subtitle: "Отримуйте сповіщення і оплачуйте вчасно",
              imagePath: "assets/images/fines_bg.png",
            ),
          ),
          PageViewModel(
            titleWidget: const SizedBox.shrink(),
            bodyWidget: const SizedBox.shrink(),
            decoration: const PageDecoration(fullScreen: true),
            image: _buildPage(
              title: "Аналітика",
              subtitle: "Стежте за витратами, пробігом та ефективністю",
              imagePath: "assets/images/analytics_bg.png",
            ),
          ),
        ],

        showSkipButton: true,
        skip: const Text(
          "Пропустити",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        next: const Icon(Icons.arrow_forward, color: Colors.white, size: 30),

        done: const Text(
          "Готово",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),

        dotsDecorator: const DotsDecorator(
          activeColor: Colors.white,
          color: Colors.white54,
          size: Size(10, 10),
          activeSize: Size(22, 10),
          activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
        ),
onSkip: () {
          context.router.replaceAll([SubscriptionRoute()]);
        },
        onDone: () {
          context.router.replaceAll([SubscriptionRoute()]);
        },
      ),
    );
  }
}
