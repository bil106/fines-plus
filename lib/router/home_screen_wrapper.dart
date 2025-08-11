import 'package:auto_route/auto_route.dart';

import 'package:fines_plus/presentation/screens/add_car_screen.dart';
import 'package:fines_plus/presentation/screens/car_info_screen.dart';
import 'package:fines_plus/presentation/screens/fines_screeen.dart';
import 'package:fines_plus/presentation/screens/reminders_screen.dart';

import 'package:flutter/material.dart';


@RoutePage()
class HomeScreenWrapper extends StatefulWidget {
  const HomeScreenWrapper({super.key});

  @override
  State<HomeScreenWrapper> createState() => _HomeScreenWrapperState();
}

class _HomeScreenWrapperState extends State<HomeScreenWrapper> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const int carInfoPageIndex = 3; 

  void _onTabTapped(int index) {
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final config = context.read<AppConfig>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: [
        
          AddCarScreen(
            onOpenCarInfo: () {
              _pageController.animateToPage(
                carInfoPageIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              setState(() => _currentIndex = carInfoPageIndex);
            },
          ),
          const FinesScreen(),
          const RemindersScreen(),
         
          CarInfoScreen(
            onClose: () {
              
              _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              setState(() => _currentIndex = 0);
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex > 2
            ? 0
            : _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Авто'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Штрафы'),
          BottomNavigationBarItem(icon: Icon(Icons.support), label: 'Нагадування'),
        ],
      ),
    );
  }
}


