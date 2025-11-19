import 'package:core_localization/generated/l10n.dart';
import 'package:core_utils/formatters/date_formatter.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/features/expenses/data/models/car_wash_record.dart';
import 'package:fines_plus/features/expenses/data/models/expense.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';
import 'package:fines_plus/features/expenses/data/models/tuning_record.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:json_annotation/json_annotation.dart';
part 'last_event_ui_model.g.dart';

@JsonSerializable()
class LastEventUiModel {
  final String title;
  final String date;
  final String description;
  final double amountValue;
  final String amount;
  final String? category;

  final double? amountOriginal;
  final String? originalCurrency;

  final double? mileage; 

  @JsonKey(ignore: true)
  Widget get icon {
    switch (category) {
      case 'fuel':
        return const Icon(Icons.local_gas_station, color: AppColors.redAccent, size: 58);
      case 'service':
        return const Icon(Icons.build, color: AppColors.blue700, size: 58);
      case 'tuning':
        return Image.asset('assets/icons/tuning.jpg', height: 58, width: 58);
      case 'carWash':
        return const Icon(Icons.local_car_wash, color: AppColors.energyBlue, size: 58);
      case 'other':
      default:
        return const Icon(Icons.event_note, color: Colors.grey, size: 58);
    }
  }

  const LastEventUiModel({
    required this.title,
    required this.date,
    required this.description,
    required this.amountValue,
    required this.amount,
    this.category,
    this.amountOriginal,
    this.originalCurrency,
    this.mileage, 
  });

static LastEventUiModel fromCarWash(CarWashRecord r) => LastEventUiModel(
    title: 'Last Event',
    date: DateFormatter.formatLongDate(r.date),
    description: r.comment ?? 'Car Wash',
    amountValue: r.amount,
    amountOriginal: r.amount,
    originalCurrency: r.currency?.isNotEmpty == true ? r.currency : 'UAH', 
    amount: '${r.amount} ${r.currency?.isNotEmpty == true ? r.currency : 'UAH'}',
    category: 'carWash',
    mileage: r.mileage.toDouble(),
  );


  static LastEventUiModel fromService(ServiceRecord r) => LastEventUiModel(
    title: 'Last Event',
    date: r.date,
    description: r.serviceName,
    amountValue: r.cost,
    amountOriginal: r.cost,
    originalCurrency: r.currency.isNotEmpty == true ? r.currency : 'UAH',
    amount: '${r.cost} ${r.currency.isNotEmpty == true ? r.currency : 'UAH'}',
    category: 'service',
    mileage: r.mileage.toDouble(),
  );

  static LastEventUiModel fromTuning(TuningRecord r) => LastEventUiModel(
    title: 'Last Event',
    date: DateFormatter.formatLongDate(r.date),
    description: r.tuningName,
    amountValue: r.cost,
    amountOriginal: r.cost,
    originalCurrency: r.currency.isNotEmpty == true ? r.currency : 'UAH',
    amount: '${r.cost} ${r.currency.isNotEmpty == true ? r.currency : 'UAH'}',
    category: 'tuning',
    mileage: r.mileage.toDouble(),
  );




static LastEventUiModel fromFuel(FuelRecord r) => LastEventUiModel(
    title: 'Last Event',
    date: DateFormatter.formatLongDate(r.date),
    description: '${r.volume} L',
    amountValue: r.cost,
    amountOriginal: r.cost,
    originalCurrency: r.currency,
    amount: '${r.cost} ${r.currency}',
    category: 'fuel',
    mileage: r.mileage.toDouble(),
  );



  factory LastEventUiModel.fromExpense(Expense expense) {
    final date = DateFormat('dd MMM yyyy').format(expense.date);

    String description;
    switch (expense.category) {
      case ExpenseCategory.fuel:
        final fuelMap = {
          'ai98': S.current.fuel_ai98,
          'ai95+': S.current.fuel_ai95_plus,
          'ai95': S.current.fuel_ai95,
          'ai92': S.current.fuel_ai92,
          'lpg': S.current.fuel_gas_lpg,
        };
        final fuelType = fuelMap[(expense.comment ?? '').toLowerCase()] ?? 'Fuel';
        description = "$fuelType / ${expense.fuelVolume?.toInt() ?? 0}L";
        break;
      case ExpenseCategory.service:
        description = expense.comment ?? "Service";
        break;
      case ExpenseCategory.tuning:
        description = expense.comment ?? "Tuning";
        break;
      case ExpenseCategory.carWash:
        description = expense.comment ?? "Car Wash";
        break;
      case ExpenseCategory.other:
        description = expense.comment ?? "Other";
        break;
    }

    return LastEventUiModel(
      title: 'Last Event',
      date: date,
      description: description,
      amountValue: expense.amount.toDouble(),
      amountOriginal: expense.amount.toDouble(),
      originalCurrency: expense.currency,
      amount: "${expense.amount} ${expense.currency}",
      category: expense.category.name,
      mileage: expense.mileage?.toDouble(),
    );
  }

  // JSON
  factory LastEventUiModel.fromJson(Map<String, dynamic> json) => _$LastEventUiModelFromJson(json);

  Map<String, dynamic> toJson() => _$LastEventUiModelToJson(this);
}
