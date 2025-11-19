import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/unit_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MileageValue extends StatelessWidget {
  final double value; 

  const MileageValue({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.watch<SettingsCubit>();
    final unitStream = UnitStream(settingsCubit);

    return StreamBuilder<double>(
      stream: unitStream.unitValueStream(value),
      initialData: unitStream.convert(value), 
      builder: (context, snapshot) {
        final converted = snapshot.data ?? value;
        final unit = settingsCubit.state.unit; 

        return Text(
          '${converted.toStringAsFixed(0)} $unit',
          style: const TextStyle(color: Colors.blueAccent, fontSize: 22, fontWeight: FontWeight.bold),
        );
      },
    );
  }
}
