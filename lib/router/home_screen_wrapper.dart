import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/reminder_cubit.dart';
import 'package:core_repository/reminder_repository.dart';
import 'package:design_system/colors/app_colors.dart';

import 'package:fines_plus/presentation/screens/add_car_screen.dart';
import 'package:fines_plus/presentation/screens/car_info_screen.dart';
import 'package:fines_plus/presentation/screens/fine_check_screen.dart';
import 'package:fines_plus/presentation/screens/fines_screeen.dart';
import 'package:fines_plus/presentation/screens/reminders_screen.dart';
import 'package:fines_plus/presentation/screens/settings_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class HomeScreenWrapper extends StatefulWidget {
  const HomeScreenWrapper({super.key});

  @override
  State<HomeScreenWrapper> createState() => _HomeScreenWrapperState();
}

class _HomeScreenWrapperState extends State<HomeScreenWrapper> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  String? _carNumber; 

  static const int carInfoPageIndex = 3;
  static const int fineCheckPageIndex = 4;

  @override
  void initState() {
    super.initState();
    _loadCarNumber();
  }

  Future<void> _loadCarNumber() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _carNumber = prefs.getString('carNumber') ?? '';
    });
  }

  void _saveCarNumber(String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('carNumber', number);
    setState(() {
      _carNumber = number;
    });
  }

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
    // Пока загружаем номер — показываем индикатор
    if (_carNumber == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.grey50,
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
          FinesScreen(
            onFineCheck: () {
              _pageController.animateToPage(
                fineCheckPageIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              setState(() => _currentIndex = 0);
            },
          ),

          /// Передаём carNumber из памяти
          BlocProvider(
            create: (_) =>
                ReminderCubit(repository: context.read<ReminderRepository>(), carNumber: _carNumber!)..load(),
            child: RemindersScreen(carNumber: _carNumber!),
          ),

          CarInfoScreen(
            onCheckFine: (number) {
              _saveCarNumber(number); // сохраняем в память
              _pageController.animateToPage(
                fineCheckPageIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          FineCheckScreen(carNumber: _carNumber!),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.neutreBlanc,
        currentIndex: _currentIndex > 2 ? 0 : _currentIndex,
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
