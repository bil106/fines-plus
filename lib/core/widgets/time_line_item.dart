
import 'package:flutter/material.dart';

class TimelineItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String date;
  final String title;
  final String subtitle;
  final String amount;
  final String mileage;

  const TimelineItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.mileage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
              padding: const EdgeInsets.all(8),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            Container(width: 2, height: 80, color: Colors.grey.shade700),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(date, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  ),
                  if (subtitle.isNotEmpty) Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16),
                      const SizedBox(width: 4),
                      Text(amount),
                      const SizedBox(width: 16),
                      const Icon(Icons.directions_car, size: 16),
                      const SizedBox(width: 4),
                      Text(mileage),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

