import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/features/analytics/data/models/event_model.dart';
import 'package:fines_plus/features/export/presentation/cubit/export_cubit.dart';
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
    String carNumber,
    List<EventModel> history,
  ) async {
    final cubit = context.read<ExportCubit>();
    final file = await cubit.exportCsvFile(carNumber, history);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: '${S.of(context).car_history} $carNumber',
    );
  }
}
