import 'package:core_localization/generated/l10n.dart';
import 'package:flutter/material.dart';

class MaintenanceCard extends StatelessWidget {
  final String title;
  final double progress;
  final IconData? icon; 
  final bool? isWarning;
  final String? priorExecution; 
  final String? periodicity; 
  final int? priorKm;
  final int? priorDays;
  final int? periodicityKm;
  final VoidCallback? onPressed; 

  const MaintenanceCard({
    super.key,
    required this.title,
    required this.progress,
    this.icon,
    this.isWarning,
    this.priorExecution,
    this.periodicity,
    this.priorKm,
    this.priorDays,
    this.periodicityKm,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        
            Row(
              children: [
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const Icon(Icons.settings, size: 20, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
           
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.blue.shade50,
                      child: Icon(
                        icon ?? Icons.oil_barrel,
                        color: icon != null ? Colors.amber : Colors.orange,
                        size: 30,
                      ),
                    ),
                    if (isWarning != null)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: isWarning! ? Colors.red : Colors.green,
                          child: Icon(isWarning! ? Icons.error : Icons.check, color: Colors.white, size: 14),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).resource),
                      const SizedBox(height: 4),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 20,
                            borderRadius: BorderRadius.circular(8),
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isWarning == true ? Colors.red : Colors.lightGreen,
                            ),
                          ),
                          Text(
                            "${(progress * 100).toStringAsFixed(0)}%",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Prior / Periodicity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (priorExecution != null)
                  Text("${S.of(context).to_be_performed}\n$priorExecution", style: const TextStyle(fontSize: 13))
                else if (priorKm != null && priorDays != null)
                  Column(
                    children: [
                      Text("$priorKm ${S.of(context).km}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("$priorDays ${S.of(context).days}", style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                if (periodicity != null)
                  Text("${S.of(context).periodicity}\n$periodicity", style: const TextStyle(fontSize: 13))
                else if (periodicityKm != null)
                  Column(
                    children: [
                      Text("$periodicityKm ${S.of(context).km}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(S.of(context).periodicity, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
              ],
            ),
            // Bottom button
            Center(
              child: TextButton(onPressed: onPressed, child: Text(S.of(context).configure_action)),
            ),
          ],
        ),
      ),
    );
  }
}
