import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/reminder_cubit.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_repository/reminder_repository.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/presentation/screens/add_car_screen.dart';
import 'package:fines_plus/presentation/screens/car_info_screen.dart';
import 'package:fines_plus/presentation/screens/fine_check_screen.dart';
import 'package:fines_plus/presentation/screens/fines_screeen.dart';
import 'package:fines_plus/presentation/screens/history_screen.dart';
import 'package:fines_plus/presentation/screens/reminders_screen.dart';
import 'package:fines_plus/presentation/screens/settings_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class HomeScreenWrapper extends StatefulWidget {
  const HomeScreenWrapper({super.key});

  @override
  State<HomeScreenWrapper> createState() => HomeScreenWrapperState();
}

class HomeScreenWrapperState extends State<HomeScreenWrapper> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  String? _carNumber;
  String? _docSeries;
  String? _docNumber;

  static const int carInfoPageIndex = 3;
  static const int fineCheckPageIndex = 4;
  static const int historyPageIndex = 6;

  @override
  void initState() {
    super.initState();
    _loadCarNumber();
  }

  Future<void> _loadCarNumber() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _carNumber = prefs.getString('carNumber') ?? '';
      _docSeries = prefs.getString('docSeries') ?? '';
      _docNumber = prefs.getString('docNumber') ?? '';
    });
  }

  void _saveCarInfo(String carNumber, String series, String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('carNumber', carNumber);
    await prefs.setString('docSeries', series);
    await prefs.setString('docNumber', number);
    setState(() {
      _carNumber = carNumber;
      _docSeries = series;
      _docNumber = number;
    });
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void openHistoryPage() {
    _pageController.animateToPage(
      historyPageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentIndex = historyPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              setState(() => _currentIndex = fineCheckPageIndex);
            },
          ),
          BlocProvider(
            create: (_) => ReminderCubit(
              repository: context.read<ReminderRepository>(),
              carNumber: _carNumber!,
              pushHelper: RepositoryProvider.of<PushHelper>(context),
            )..load(),
            child: RemindersScreen(carNumber: _carNumber!),
          ),
          CarInfoScreen(
            onCheckFine: (carNumber, series, number) {
              _saveCarInfo(carNumber, series, number);

              openHistoryPage();
            },
          ),
          FineCheckScreen(carNumber: _carNumber!, docSeries: _docSeries ?? '', docNumber: _docNumber ?? ''),
          const SettingsScreen(),
          HistoryScreen(carNumber: _carNumber ?? ''),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.neutreBlanc,
        currentIndex: _currentIndex > 2 ? 0 : _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: S.of(context).auto),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: S.of(context).fines),
          BottomNavigationBarItem(icon: Icon(Icons.support), label: S.of(context).reminder),
        ],
      ),
    );
  }
}
