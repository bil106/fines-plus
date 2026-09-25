import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_utils/formatters/vehicle_formatters.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/widget/app_back_button.dart';
import 'package:design_system/widget/app_field_card.dart';
import 'package:intl/intl.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:fines_plus/features/expenses/data/models/expense.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:fines_plus/features/expenses/data/models/insurance_record.dart';
import 'package:fines_plus/features/expenses/data/repository/expense_repository.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_state.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/unit_stream.dart';
import 'package:fines_plus/features/vehicle/data/car_makes.dart';
import 'package:fines_plus/features/vehicle/data/car_models.dart';
import 'package:fines_plus/features/vehicle/data/datasources/car_photo_uploader.dart';
import 'package:fines_plus/features/vehicle/data/models/car_info_model.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/garage_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/garage_state.dart';
import 'package:fines_plus/features/vehicle/presentation/widgets/car_make_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Lists every car in the signed-in user's garage, lets them switch the
/// active one, add a new car, edit an existing car's plate/tech-passport,
/// or delete a car (and all of its data) entirely.
class GarageScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;
  final bool isContinuing;
  const GarageScreen({
    super.key,
    this.onBack,
    this.onContinue,
    this.isContinuing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.brandTheme.surfaceBg,
      appBar: AppBar(
        backgroundColor: context.brandTheme.surfaceBg,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: true,
        leadingWidth: 70,
        leading: AppBackButton(onPressed: onBack),
        title: BlocBuilder<GarageCubit, GarageState>(
          builder: (context, state) => Column(
            children: [
              Text(
                S.of(context).my_garage,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  color: AppColors.inkSoft,
                ),
              ),
              Text(
                S.of(context).garage_cars_count(state.visibleCars.length),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: onContinue == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: isContinuing ? null : onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isContinuing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          S.of(context).garage_continue,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.blue700,
        foregroundColor: AppColors.neutreBlanc,
        shape: const CircleBorder(),
        tooltip: S.of(context).add_cars,
        onPressed: () async {
          final result = await showCarFormSheet(context);
          if (result == null) return;
          if (!context.mounted) return;
          await runOrShowError(
            context,
            () => context.read<GarageCubit>().addCar(
              carNumber: result['carNumber'] ?? '',
              techPassport: result['techPassport'] ?? '',
              make: result['make'] ?? '',
              model: result['model'] ?? '',
              photoPath: result['photoPath'] ?? '',
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: BlocBuilder<GarageCubit, GarageState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final cars = state.visibleCars;
            if (cars.isEmpty) {
              return Center(child: Text(S.of(context).garage_empty_add_car));
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
              itemCount: cars.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final car = cars[index];
                final isActive = car.carId == state.activeCarId;

                return _CarCard(
                  key: ValueKey(car.carId),
                  car: car,
                  isActive: isActive,
                  onTap: isActive
                      ? null
                      : () => runOrShowError(
                          context,
                          () => context.read<GarageCubit>().switchTo(car),
                        ),
                  onEdit: () async {
                    final result = await showCarFormSheet(
                      context,
                      existing: car,
                    );
                    if (result == null) return;
                    if (!context.mounted) return;
                    await runOrShowError(
                      context,
                      () => context.read<GarageCubit>().updateCar(
                        car,
                        carNumber: result['carNumber'],
                        techPassport: result['techPassport'],
                        make: result['make'],
                        model: result['model'],
                        photoUrl: result['photoUrl'],
                      ),
                    );
                  },
                  onDelete: () => confirmAndDeleteCar(context, car),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

const _plateMaxWidth = 110.0;

class _CarCard extends StatelessWidget {
  final CarInfoModel car;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CarCard({
    super.key,
    required this.car,
    required this.isActive,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final brand = context.brandTheme;
    return Semantics(
      selected: isActive,
      child: Material(
        color: AppColors.neutreBlanc,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: brand.surfaceBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onEdit,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Thumbnail(
                      photoUrl: car.photoUrl,
                      make: car.make,
                      isActive: isActive,
                      size: 54,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        car.displayName.isNotEmpty
                            ? car.displayName
                            : S.of(context).auto,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppColors.inkSoft,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (car.carNumber.isNotEmpty)
                      // Capped and scaled down so a large system font can't
                      // push the plate + menu past the card's edge.
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _plateMaxWidth,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: brand.surfaceBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              car.carNumber,
                              style: brand.moneyTextStyle.copyWith(
                                fontSize: 13,
                                color: AppColors.inkSoft,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                CarMileageAndStatus(carId: car.carId, cardStyle: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mileage + a simple status line, derived from that car's own expense
/// records (not just the currently active car's - MaintenanceCubit only
/// tracks the active one). "ОК до `date`" reflects a real insurance
/// record's validTo; there's no stored service-interval anywhere in the app
/// yet to compute a real "ТО через N км" due-distance, so that case isn't
/// shown.
class CarMileageAndStatus extends StatefulWidget {
  final String carId;
  final bool cardStyle;
  const CarMileageAndStatus({
    super.key,
    required this.carId,
    this.cardStyle = false,
  });

  @override
  State<CarMileageAndStatus> createState() => CarMileageAndStatusState();
}

class CarMileageAndStatusState extends State<CarMileageAndStatus> {
  Future<List<Expense>>? _expensesFuture;

  bool get _isActiveCar => widget.carId == context.read<CarCubit>().state.carId;

  @override
  void initState() {
    super.initState();
    // For the active car, MaintenanceCubit already streams its records live
    // - reusing that instead of a one-shot fetch means this updates right
    // after e.g. saving a new insurance record from the dashboard's
    // Страхування sheet, instead of staying stuck on whatever was true when
    // this row first mounted. Other cars aren't tracked by MaintenanceCubit,
    // so they still get a plain one-shot fetch.
    if (!_isActiveCar) {
      _expensesFuture = ExpenseRepository(
        FirebaseFirestore.instance,
      ).getExpensesOnce(carNumber: widget.carId);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CarCubit>();
    if (_isActiveCar) {
      _expensesFuture = null;
      return BlocBuilder<MaintenanceCubit, MaintenanceState>(
        builder: (context, state) {
          final mileage = [
            ...state.fuelRecords.map((r) => r.mileage),
            ...state.serviceRecords.map((r) => r.mileage),
            ...state.carWashRecords.map((r) => r.mileage),
            ...state.tuningRecords.map((r) => r.mileage),
            ...state.otherRecords.map((r) => r.mileage),
          ].fold(0, (max, m) => m > max ? m : max);

          // "Current" policy = the one saved most recently (updatedAt), not
          // whichever happens to run furthest into the future, and not
          // validFrom - a renewal that only edits validTo keeps the same
          // validFrom as the record it's replacing.
          InsuranceRecord? currentPolicy;
          for (final r in state.insuranceRecords) {
            if (currentPolicy == null ||
                currentPolicy.updatedAt == null ||
                (r.updatedAt != null &&
                    r.updatedAt!.isAfter(currentPolicy.updatedAt!))) {
              currentPolicy = r;
            }
          }

          return _buildContent(
            context,
            mileage: mileage,
            latestInsuranceValidTo: currentPolicy?.validTo,
          );
        },
      );
    }

    _expensesFuture ??= ExpenseRepository(
      FirebaseFirestore.instance,
    ).getExpensesOnce(carNumber: widget.carId);
    return FutureBuilder<List<Expense>>(
      future: _expensesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final expenses = snapshot.data!;

        final mileage = expenses.fold<int>(
          0,
          (max, e) => (e.mileage ?? 0) > max ? e.mileage! : max,
        );

        // Same "most recently saved policy wins" rule as the active-car
        // branch above.
        Expense? currentPolicy;
        for (final e in expenses) {
          if (e.category == ExpenseCategory.insurance) {
            if (currentPolicy == null ||
                currentPolicy.updatedAt == null ||
                (e.updatedAt != null &&
                    e.updatedAt!.isAfter(currentPolicy.updatedAt!))) {
              currentPolicy = e;
            }
          }
        }

        return _buildContent(
          context,
          mileage: mileage,
          latestInsuranceValidTo: currentPolicy?.insuranceValidTo,
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required int mileage,
    required DateTime? latestInsuranceValidTo,
  }) {
    final textTheme = Theme.of(context).textTheme;

    final insuranceExpired =
        latestInsuranceValidTo != null &&
        latestInsuranceValidTo.isBefore(DateTime.now());

    final statusText = insuranceExpired
        ? S.of(context).garage_status_insurance_expired
        : latestInsuranceValidTo != null
        ? S
              .of(context)
              .garage_status_ok_until(_formatDate(latestInsuranceValidTo))
        : S.of(context).garage_status_ok;

    final settingsCubit = context.read<SettingsCubit>();
    final unit = settingsCubit.state.unit == 'mil' ? 'mil' : S.of(context).km;
    final displayMileage = UnitStream(
      settingsCubit,
    ).convert(mileage.toDouble()).round();

    if (!widget.cardStyle) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Wrap(
          spacing: 8,
          children: [
            if (mileage > 0)
              Text('$displayMileage $unit', style: textTheme.bodySmall),
            Text(
              statusText,
              style: textTheme.bodySmall?.copyWith(
                color: insuranceExpired
                    ? context.brandTheme.statusDanger
                    : context.brandTheme.statusSuccess,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final foreground = insuranceExpired
        ? context.brandTheme.statusDanger
        : context.brandTheme.statusSuccess;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${NumberFormat.decimalPattern('uk').format(displayMileage)} $unit',
            style: textTheme.bodySmall
                ?.merge(context.brandTheme.moneyTextStyle)
                .copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
          ),
          if (latestInsuranceValidTo != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: insuranceExpired
                    ? context.brandTheme.statusDangerBg
                    : context.brandTheme.statusSuccessBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '● $statusText',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}

/// The car's photo, or a make-logo fallback when none is set - shared by
/// GarageScreen's list and Settings' compact "Автомобілі" rows (see
/// settings_screen.dart), just at different [size]s.
class Thumbnail extends StatelessWidget {
  final String photoUrl;
  final String make;
  final bool isActive;
  final double size;
  const Thumbnail({
    super.key,
    required this.photoUrl,
    required this.make,
    required this.isActive,
    this.size = 90,
  });

  @override
  Widget build(BuildContext context) {
    if (photoUrl.isEmpty) {
      return CarMakeLogo(
        make: make,
        size: size * 0.4,
        fallbackColor: isActive ? AppColors.blue700 : AppColors.neutreGrey,
      );
    }

    return ClipRRect(
      borderRadius: AppBorders.radiusMedium,
      child: Image.network(
        photoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          Icons.directions_car,
          color: isActive ? AppColors.blue700 : AppColors.neutreGrey,
        ),
      ),
    );
  }
}

/// Confirms, then deletes a car (and all of its data) via GarageCubit -
/// shared by GarageScreen's delete button and Settings' "Автомобілі" rows,
/// so both go through the exact same Firestore-backed deleteCar flow.
Future<void> confirmAndDeleteCar(BuildContext context, CarInfoModel car) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(S.of(context).garage_delete_confirm_title),
      content: Text(S.of(context).garage_delete_confirm_body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(S.of(context).cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            S.of(context).delete,
            style: const TextStyle(color: AppColors.red),
          ),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  if (!context.mounted) return;
  await runOrShowError(
    context,
    () => context.read<GarageCubit>().deleteCar(car),
    errorMessage: S.of(context).garage_delete_error,
  );
}

/// Runs a garage action and surfaces any failure as a SnackBar instead of
/// letting it disappear as a silent, unhandled Future rejection (which is
/// invisible to the user outside of debug mode).
Future<void> runOrShowError(
  BuildContext context,
  Future<void> Function() action, {
  String? errorMessage,
}) async {
  try {
    await action();
  } catch (e) {
    debugPrint('Garage action failed: $e');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${errorMessage ?? S.of(context).garage_action_error}: $e',
        ),
      ),
    );
  }
}

/// Bottom sheet with make, optional car-number/tech-passport fields and a
/// photo picker. When editing, the photo is uploaded straight away
/// ('photoUrl'); for a new car there is no carId to upload against yet, so
/// the picked file is returned as 'photoPath' for the caller to upload once
/// the car has been created. Also returns 'make', 'model', 'carNumber',
/// 'techPassport' — or null if the user cancelled.
Future<Map<String, String>?> showCarFormSheet(
  BuildContext context, {
  CarInfoModel? existing,
}) {
  final carNumberController = TextEditingController(
    text: existing?.carNumber ?? '',
  );
  final techPassportController = TextEditingController(
    text: existing?.techPassport ?? '',
  );
  String? selectedMake = existing?.make.isNotEmpty == true
      ? existing!.make
      : null;
  String? selectedModel = existing?.model.isNotEmpty == true
      ? existing!.model
      : null;
  String photoUrl = existing?.photoUrl ?? '';
  bool isUploadingPhoto = false;
  String photoPath = '';

  return showModalBottomSheet<Map<String, String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.brandTheme.surfaceBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            final isValid =
                carNumberController.text.isEmpty ||
                VehicleNumberFormatter.isValid(carNumberController.text);

            return SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.brandTheme.surfaceBorder,
                      borderRadius: AppBorders.radiusSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            existing == null
                                ? S.of(context).add_cars
                                : S.of(context).edit,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                            size: 14,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.neutreBlanc,
                            side: BorderSide(
                              color: context.brandTheme.surfaceBorder,
                            ),
                            shape: const CircleBorder(),
                            minimumSize: const Size(30, 30),
                          ),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: isUploadingPhoto
                                  ? null
                                  : () async {
                                      setState(() => isUploadingPhoto = true);
                                      try {
                                        if (existing == null) {
                                          final picked =
                                              await CarPhotoUploader().pick();
                                          if (picked != null) {
                                            setState(
                                              () => photoPath = picked.path,
                                            );
                                          }
                                        } else {
                                          final url = await CarPhotoUploader()
                                              .pickAndUpload(
                                                uid: existing.ownerId,
                                                carId: existing.carId,
                                              );
                                          if (url != null) {
                                            setState(() => photoUrl = url);
                                          }
                                        }
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${S.of(context).garage_action_error}: $e',
                                            ),
                                          ),
                                        );
                                      } finally {
                                        setState(
                                          () => isUploadingPhoto = false,
                                        );
                                      }
                                    },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: context.brandTheme.surfaceBorder,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: AppColors.neutreBlanc,
                                  backgroundImage: photoPath.isNotEmpty
                                      ? FileImage(File(photoPath))
                                      : photoUrl.isNotEmpty
                                      ? NetworkImage(photoUrl)
                                      : null,
                                  child: isUploadingPhoto
                                      ? const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        )
                                      : (photoUrl.isEmpty && photoPath.isEmpty
                                            ? const Icon(
                                                Icons.add_a_photo_outlined,
                                                color: AppColors.textSecondary,
                                              )
                                            : null),
                                ),
                              ),
                            ),
                          ),
                          AppSpacers.verticalMedium,
                          AppFieldCard(
                            label: S.of(context).garage_make_label,
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedMake,
                              isExpanded: true,
                              hint: Text(
                                S.of(context).garage_make_hint,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              items: carMakes
                                  .map(
                                    (m) => DropdownMenuItem(
                                      value: m,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CarMakeLogo(make: m, size: 20),
                                          AppSpacers.horizontalSmall,
                                          Text(m),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() {
                                selectedMake = v;
                                // A model picked for the previous make
                                // doesn't belong to the new one.
                                if (!(carModels[v] ?? const []).contains(
                                  selectedModel,
                                )) {
                                  selectedModel = null;
                                }
                              }),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          AppSpacers.verticalMedium,
                          AppFieldCard(
                            label: S.of(context).garage_model_label,
                            child: DropdownButtonFormField<String>(
                              // Re-created per make: the field keeps its own
                              // value, which must be one of the new items.
                              key: ValueKey(selectedMake),
                              initialValue: selectedModel,
                              isExpanded: true,
                              hint: Text(
                                S.of(context).garage_model_hint,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              items:
                                  [
                                        // A model saved before the list
                                        // existed (typed by hand) stays
                                        // selectable instead of being lost.
                                        if (selectedModel != null &&
                                            !(carModels[selectedMake] ??
                                                    const [])
                                                .contains(selectedModel))
                                          selectedModel!,
                                        ...?carModels[selectedMake],
                                      ]
                                      .map(
                                        (m) => DropdownMenuItem(
                                          value: m,
                                          child: Text(m),
                                        ),
                                      )
                                      .toList(),
                              onChanged: selectedMake == null
                                  ? null
                                  : (v) => setState(() => selectedModel = v),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          AppSpacers.verticalMedium,
                          AppFieldCard(
                            label: S.of(context).car_number,
                            child: TextField(
                              controller: carNumberController,
                              onChanged: (_) => setState(() {}),
                              inputFormatters: [VehicleNumberFormatter()],
                              textCapitalization: TextCapitalization.characters,
                              maxLength: 8,
                              decoration: InputDecoration(
                                hintText: S.of(context).hint_auto_num,
                                hintStyle: const TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textSecondary,
                                ),
                                counterText: '',
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          // Tech passport is only used by the UA fines check.
                          if (context.watch<AppConfig>().finesCheckEnabled) ...[
                            AppSpacers.verticalMedium,
                            AppFieldCard(
                              label: S.of(context).reg_number,
                              child: TextField(
                                controller: techPassportController,
                                inputFormatters: [TechPassportFormatter()],
                                maxLength: 9,
                                decoration: InputDecoration(
                                  hintText: S.of(context).hint_tech_data_num,
                                  hintStyle: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textSecondary,
                                  ),
                                  counterText: '',
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                          ],
                          AppSpacers.verticalMedium,
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (isValid && !isUploadingPhoto)
                                  ? () => Navigator.pop(sheetContext, {
                                      'carNumber': carNumberController.text,
                                      'techPassport':
                                          techPassportController.text,
                                      'make': selectedMake ?? '',
                                      'model': selectedModel ?? '',
                                      'photoUrl': photoUrl,
                                      'photoPath': photoPath,
                                    })
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppBorders.radius16,
                                ),
                              ),
                              child: Text(S.of(context).save),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
