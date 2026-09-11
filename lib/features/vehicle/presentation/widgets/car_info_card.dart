// ignore_for_file: unnecessary_string_interpolations

import 'package:design_system/colors/app_colors.dart';
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
            Text('Рік випуску: ${data['make_year']?.toString() ?? '-'}', style: textTheme.black14bold),
            Text('Вартість номера: ${data['plate_cost']?.toString() ?? '-'} грн.', style: textTheme.green20W400),
            Text('Причина вартості: ${data['plate_cost_reason'] ?? '-'}', style: textTheme.black14bold),
            AppSpacers.verticalMedium,

          
            _buildParam(Icons.color_lens, 'Колір', data['color'], textTheme),
            _buildParam(Icons.directions_car, 'Тип', data['kind'], textTheme),
            _buildParam(Icons.local_gas_station, 'Паливо', data['fuel'], textTheme),
            _buildParam(Icons.engineering, 'Об’єм двигуна', data['capacity'], textTheme),
            _buildParam(
              Icons.fitness_center,
              'Маса/Макс. маса',
              '${data['own_weight'] ?? '-'} / ${data['total_weight'] ?? '-'}',
              textTheme,
            ),
            _buildParam(Icons.category, 'Категорія/Кузов', data['body'], textTheme),
            _buildParam(Icons.event_seat, 'Кількість місць', data['seating'], textTheme),
            AppSpacers.verticalMedium,

            
            _buildText('Держ. номер', data['plate']),
            _buildText('Рег. адреса (KOATUU)', data['reg_addr_koatuu']),
            _buildText('Адреса власника', data['address']),
            _buildText('Регіон', data['region']),
            _buildText('Дата першої реєстрації', data['first_reg_at']),
            _buildText('Власник', data['person']),
            _buildText('Департамент', data['departament']),
            _buildText('Адреса департаменту', data['departament_address']),
            _buildText('Операція', data['operation']),
            _buildText('Операційний код', data['oper_code']),
            _buildText('VIN', data['vin']),
            AppSpacers.verticalMedium,

         
            if (data.containsKey('last_record_date') || data.containsKey('last_plate'))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Останній запис', style: textTheme.black16bold),
                  _buildText('Дата запису', data['last_record_date']),
                  _buildText('Держ. номер', data['last_plate']),
                  _buildText('Запис', data['last_record']),
                  _buildText('Зроблено в департаменті', data['departament']),
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


