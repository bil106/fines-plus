import 'package:core_localization/generated/l10n.dart';
import 'package:core_utils/formatters/vehicle_formatters.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/vehicle/data/car_makes.dart';
import 'package:fines_plus/features/vehicle/data/datasources/car_photo_uploader.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/widgets/car_make_logo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shown once, right after a brand-new registration. Lets the user either
/// skip straight into the app (a default, plate-less car is created behind
/// the scenes) or optionally fill in their car number / tech passport now.
class GarageSetupScreen extends StatefulWidget {
  final VoidCallback onDone;
  const GarageSetupScreen({super.key, required this.onDone});

  @override
  State<GarageSetupScreen> createState() => _GarageSetupScreenState();
}

class _GarageSetupScreenState extends State<GarageSetupScreen> {
  bool _showForm = false;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  String? _selectedMake;
  String _photoUrl = '';
  late final TextEditingController _carNumberController;
  late final TextEditingController _techPassportController;

  @override
  void initState() {
    super.initState();
    _carNumberController = TextEditingController();
    _techPassportController = TextEditingController();
    _carNumberController.addListener(() => setState(() {}));
    // Get the car id ready ahead of time so a photo can be uploaded against
    // it as soon as the user opens the picker, without waiting mid-tap.
    context.read<CarCubit>().ensureCarId();
  }

  @override
  void dispose() {
    _carNumberController.dispose();
    _techPassportController.dispose();
    super.dispose();
  }

  bool get _carNumberIsValidOrEmpty =>
      _carNumberController.text.isEmpty || VehicleNumberFormatter.isValid(_carNumberController.text);

  Future<void> _skip() async {
    setState(() => _isSaving = true);
    await context.read<CarCubit>().ensureCarId();
    if (!mounted) return;
    widget.onDone();
  }

  Future<void> _pickPhoto() async {
    setState(() => _isUploadingPhoto = true);
    try {
      final carCubit = context.read<CarCubit>();
      final carId = await carCubit.ensureCarId();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (carId.isEmpty || uid == null) return;

      final url = await CarPhotoUploader().pickAndUpload(uid: uid, carId: carId);
      if (url != null) setState(() => _photoUrl = url);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${S.of(context).garage_action_error}: $e')));
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _saveAndContinue() async {
    if (!_carNumberIsValidOrEmpty) return;

    setState(() => _isSaving = true);
    final carCubit = context.read<CarCubit>();
    await carCubit.ensureCarId();

    if (_carNumberController.text.isNotEmpty) {
      await carCubit.changeCar(_carNumberController.text);
    }
    if (_techPassportController.text.isNotEmpty) {
      await carCubit.setTechPassport(_techPassportController.text);
    }
    if (_selectedMake != null) {
      await carCubit.setMake(_selectedMake!);
    }
    if (_photoUrl.isNotEmpty) {
      await carCubit.setPhotoUrl(_photoUrl);
    }

    if (!mounted) return;
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.energyBlue50,
      appBar: AppBar(backgroundColor: AppColors.energyBlue50, elevation: 0, automaticallyImplyLeading: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).garage_setup_title,
                style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              AppSpacers.verticalMedium,
              Text(S.of(context).garage_setup_subtitle, style: textTheme.bodyMedium),
              AppSpacers.verticalXXLarge,

              if (!_showForm) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _showForm = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue700,
                      shape: RoundedRectangleBorder(borderRadius: AppBorders.radius16),
                    ),
                    child: Text(S.of(context).add_cars, style: textTheme.buttonText),
                  ),
                ),
                AppSpacers.verticalMedium,
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : _skip,
                    child: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(S.of(context).skip_for_now),
                  ),
                ),
              ] else ...[
                Center(
                  child: GestureDetector(
                    onTap: _isUploadingPhoto ? null : _pickPhoto,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.grey50,
                      backgroundImage: _photoUrl.isNotEmpty ? NetworkImage(_photoUrl) : null,
                      child: _isUploadingPhoto
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : (_photoUrl.isEmpty
                                ? const Icon(Icons.add_a_photo_outlined, color: AppColors.neutreGrey)
                                : null),
                    ),
                  ),
                ),
                AppSpacers.verticalMedium,
                Text(S.of(context).garage_make_label, style: textTheme.black28W600),
                AppSpacers.verticalSmall,
                DropdownButtonFormField<String>(
                  initialValue: _selectedMake,
                  isExpanded: true,
                  hint: Text(S.of(context).garage_make_hint),
                  items: carMakes
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [CarMakeLogo(make: m, size: 20), AppSpacers.horizontalSmall, Text(m)],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedMake = v),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.grey50,
                    border: OutlineInputBorder(borderRadius: AppBorders.radius18, borderSide: BorderSide.none),
                  ),
                ),
                AppSpacers.verticalMedium,
                Text(S.of(context).car_number, style: textTheme.black28W600),
                AppSpacers.verticalSmall,
                TextField(
                  controller: _carNumberController,
                  inputFormatters: [VehicleNumberFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 8,
                  decoration: InputDecoration(
                    hintText: S.of(context).hint_auto_num,
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.grey50,
                    border: OutlineInputBorder(borderRadius: AppBorders.radius18, borderSide: BorderSide.none),
                  ),
                ),
                AppSpacers.verticalMedium,
                Text(S.of(context).reg_number, style: textTheme.black28W600),
                AppSpacers.verticalSmall,
                TextField(
                  controller: _techPassportController,
                  inputFormatters: [TechPassportFormatter()],
                  maxLength: 9,
                  decoration: InputDecoration(
                    hintText: S.of(context).hint_tech_data_num,
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.grey50,
                    border: OutlineInputBorder(borderRadius: AppBorders.radius18, borderSide: BorderSide.none),
                  ),
                ),
                AppSpacers.verticalSmall,
                Text(
                  S.of(context).car_number_fines_hint,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.neutreGrey),
                ),
                AppSpacers.verticalXXLarge,

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_isSaving || !_carNumberIsValidOrEmpty) ? null : _saveAndContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue700,
                      shape: RoundedRectangleBorder(borderRadius: AppBorders.radius16),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(S.of(context).save, style: textTheme.buttonText),
                  ),
                ),
                AppSpacers.verticalMedium,
                Center(
                  child: TextButton(onPressed: _isSaving ? null : _skip, child: Text(S.of(context).skip_for_now)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
