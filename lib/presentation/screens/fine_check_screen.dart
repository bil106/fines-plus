import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/fines_cubit.dart';
import 'package:core_cubit/cubit/fines_state.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_repository/fines_repository.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

@RoutePage()
class FineCheckScreen extends StatefulWidget {
  final String carNumber;
  final String docSeries;
  final String docNumber;

  const FineCheckScreen({super.key, required this.carNumber, required this.docSeries, required this.docNumber});

  @override
  State<FineCheckScreen> createState() => _FineCheckScreenState();
}

class _FineCheckScreenState extends State<FineCheckScreen> {
  late final FinesCubit finesCubit;

  @override
  void initState() {
    super.initState();
    final dataSource = FinesBackendDataSource(http.Client());
    final repository = FinesRepositoryImpl(dataSource);
    finesCubit = FinesCubit(repository);

    finesCubit.checkFines(carNumber: widget.carNumber, docSeries: widget.docSeries, docNumber: widget.docNumber);
  }

  @override
  void dispose() {
    finesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider.value(
      value: finesCubit,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.grey50,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacers.verticalXLarge,
                  Text(S.of(context).check_fine_title, style: textTheme.title),
                  AppSpacers.verticalHuge,

                  BlocBuilder<FinesCubit, FinesState>(
                    builder: (context, state) {
                      if (state is FinesLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is FinesError) {
                        if (kDebugMode) {
                          print('Error:${state.message}');
                        }
                        return Text("Error: ${state.message}", style: textTheme.bodyMedium);
                      
                      } else if (state is FinesEmpty) {
                        return Container(
                          width: double.infinity,
                          height: 110,
                          decoration: BoxDecoration(
                            color: AppColors.neutreBlanc,
                            borderRadius: AppBorders.radius16,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              AppSpacers.horizontalLarge,
                              Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(color: AppColors.blue700, shape: BoxShape.circle),
                                child: const Icon(Icons.check, color: AppColors.neutreBlanc, size: 26),
                              ),
                              AppSpacers.horizontalLarge,
                              Expanded(child: Text(S.of(context).no_fines, style: textTheme.noFinesText)),
                            ],
                          ),
                        );
                      } else if (state is FinesLoaded) {
                        return Column(
                          children: state.fines.map((fine) {
                            return SizedBox(
                              width: double.infinity,
                              child: Card(
                                color: AppColors.neutreBlanc,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppSpacers.verticalMedium,
                                      Text(widget.carNumber, style: textTheme.carNumber),
                                      Text("${fine.total} грн", style: textTheme.totalFines),
                                      const SizedBox(height: 8),
                                      Text(
                                        "${fine.date.day}.${fine.date.month}.${fine.date.year}",
                                        style: textTheme.fineDate,
                                      ),
                                      AppSpacers.verticalMedium,
                                      Container(height: 3, color: AppColors.neutreGrey100),
                                      AppSpacers.verticalMedium,
                                      Text(fine.violation, style: textTheme.violationTitle),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),

                  AppSpacers.verticalLargeXL,
                  SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue700,
                        shape: RoundedRectangleBorder(borderRadius: AppBorders.radius16),
                      ),
                      child: Text(S.of(context).pay, style: textTheme.buttonText),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
