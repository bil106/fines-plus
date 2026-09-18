import 'package:fines_plus/features/vehicle/data/repository/car_info_repository.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/garage_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/screens/garage_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The shared garage, with a final onboarding action to enter Home.
class GarageSetupScreen extends StatefulWidget {
  final VoidCallback onDone;
  const GarageSetupScreen({super.key, required this.onDone});

  @override
  State<GarageSetupScreen> createState() => _GarageSetupScreenState();
}

class _GarageSetupScreenState extends State<GarageSetupScreen> {
  bool _isSaving = false;

  Future<void> _continue() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    await runOrShowError(context, () async {
      await context.read<CarCubit>().ensureCarId();
      if (!mounted) return;
      widget.onDone();
    });
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => GarageCubit(
      repository: context.read<CarInfoRepository>(),
      carCubit: context.read<CarCubit>(),
    ),
    child: GarageScreen(
      onBack: _continue,
      onContinue: _continue,
      isContinuing: _isSaving,
    ),
  );
}
