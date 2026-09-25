import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/features/analytics/data/models/event_model.dart';
import 'package:fines_plus/features/export/presentation/cubit/export_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/garage_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

class ShareHelpers {
  static Future<void> sharePdf(
    BuildContext context,
    String carNumber,
    List<EventModel> history,
  ) async {
    final cubit = context.read<ExportCubit>();
    final file = await cubit.exportPdfFile(carNumber, history);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: '${S.of(context).car_history} $carNumber',
    );
  }

  static Future<void> shareCsv(
    BuildContext context,
    List<EventModel> history,
  ) async {
    final cubit = context.read<ExportCubit>();
    final carNumber = context.read<CarCubit>().state.carNumber;

    final file = await cubit.exportCsvFile(carNumber, history);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: '${S.of(context).car_history} $carNumber',
    );
  }

  static Future<void> shareBuyerReport(
    BuildContext context,
    String carNumber,
    List<EventModel> history,
  ) async {
    final cubit = context.read<ExportCubit>();
    final config = context.read<CarCubit>().config;
    final garageState = context.read<GarageCubit>().state;
    final activeCars = garageState.cars.where((c) => c.carId == garageState.activeCarId);
    final file = await cubit.exportBuyerReportFile(
      carNumber,
      history,
      carMake: activeCars.isNotEmpty ? activeCars.first.make : '',
      brandName: config.brandName,
      logoAssetPath: config.logoAssetPath,
      includeFines: config.finesCheckEnabled,
    );
    await Share.shareXFiles(
      [XFile(file.path)],
      text: '${S.of(context).buyer_report} $carNumber',
    );
  }
}
