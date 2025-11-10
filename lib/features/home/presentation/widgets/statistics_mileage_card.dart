import 'package:fines_plus/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class StatisticsMileageCard extends StatelessWidget {
  const StatisticsMileageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsCubit, StatisticsState>(
      builder: (context, state) {
        final monthLabel = _monthName(DateTime.now().month);
        final mileageThisMonth = state.currentMonthMileage.toInt();
        final prevMileage = state.previousMonthMileage.toInt();
        final changePercent = prevMileage > 0 ? ((mileageThisMonth - prevMileage) / prevMileage * 100).toInt() : 0;

        final isIncreased = changePercent >= 0;
        final arrowIcon = Icon(
          isIncreased ? Icons.arrow_upward : Icons.arrow_downward,
          color: isIncreased ? Colors.red : Colors.green,
          size: 20,
        );

        return _buildCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$monthLabel '${DateTime.now().year.toString().substring(2)}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  Text(
                    "${NumberFormat.decimalPattern('uk').format(mileageThisMonth)} км",
                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ],
              ),

             
              Row(
                children: [
                  arrowIcon,
                  const SizedBox(width: 4),
                  Text(
                    "${changePercent.abs()}% за місяць",
                    style: TextStyle(color: isIncreased ? Colors.red : Colors.green, fontWeight: FontWeight.w500,fontSize:20),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }


  String _monthName(int month) {
    const months = [
      "Січ",
      "Лют",
      "Бер",
      "Квіт",
      "Трав",
      "Черв",
      "Лип",
      "Серп",
      "Верес",
      "Жовт",
      "Лист",
      "Груд",
    ];
    return months[month - 1];
  }
}
