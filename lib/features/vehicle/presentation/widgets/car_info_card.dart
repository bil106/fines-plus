// ignore_for_file: unnecessary_string_interpolations

import 'package:design_system/colors/app_colors.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';


class CarInfoCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final TextTheme textTheme;

  const CarInfoCard({super.key, required this.data, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Card(
      color: AppColors.neutreBlanc,
      shape: RoundedRectangleBorder(borderRadius: AppBorders.radius22),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
         
            Text('${data['brand'] ?? '-'} ${data['model'] ?? '-'}', style: textTheme.black16bold),
            _buildText(l10n.car_make_year, data['make_year']),
            Text('${l10n.plate_cost}: ${data['plate_cost']?.toString() ?? '-'} UAH', style: textTheme.green20W400),
            _buildText(l10n.plate_cost_reason, data['plate_cost_reason']),
            AppSpacers.verticalMedium,

          
            _buildParam(Icons.color_lens, l10n.vehicle_color, data['color'], textTheme),
            _buildParam(Icons.directions_car, l10n.vehicle_type, data['kind'], textTheme),
            _buildParam(Icons.local_gas_station, l10n.vehicle_fuel, data['fuel'], textTheme),
            _buildParam(Icons.engineering, l10n.engine_capacity, data['capacity'], textTheme),
            _buildParam(
              Icons.fitness_center,
              l10n.vehicle_weight,
              '${data['own_weight'] ?? '-'} / ${data['total_weight'] ?? '-'}',
              textTheme,
            ),
            _buildParam(Icons.category, l10n.body_category, data['body'], textTheme),
            _buildParam(Icons.event_seat, l10n.seats_count, data['seating'], textTheme),
            AppSpacers.verticalMedium,

            
            _buildText(l10n.registration_plate, data['plate']),
            _buildText(l10n.registration_address, data['reg_addr_koatuu']),
            _buildText(l10n.owner_address, data['address']),
            _buildText(l10n.vehicle_region, data['region']),
            _buildText(l10n.first_registration_date, data['first_reg_at']),
            _buildText(l10n.vehicle_owner, data['person']),
            _buildText(l10n.registration_department, data['departament']),
            _buildText(l10n.department_address, data['departament_address']),
            _buildText(l10n.registration_operation, data['operation']),
            _buildText(l10n.operation_code, data['oper_code']),
            _buildText('VIN', data['vin']),
            AppSpacers.verticalMedium,

         
            if (data.containsKey('last_record_date') || data.containsKey('last_plate'))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.last_record, style: textTheme.black16bold),
                  _buildText(l10n.record_date, data['last_record_date']),
                  _buildText(l10n.registration_plate, data['last_plate']),
                  _buildText(l10n.record, data['last_record']),
                  _buildText(l10n.completed_at_department, data['departament']),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildParam(IconData icon, String label, dynamic value, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppColors.grey700),
          AppSpacers.horizontalSmall,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.black14bold),
              Text(value?.toString() ?? '-', style: textTheme.black14bold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildText(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text('$label: ${value?.toString() ?? '-'}', style: textTheme.black14bold),
    );
  }
}


