import 'package:core_localization/generated/l10n.dart';
import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final double progress;
  final String priorExecution;
  final String periodicity;
  final bool isWarning;

  const ActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.progress,
    required this.priorExecution,
    required this.periodicity,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 3,
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
                      child: Icon(icon, color: Colors.amber, size: 30),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: isWarning ? Colors.red : Colors.green,
                        child: Icon(isWarning ? Icons.error : Icons.check, color: Colors.white, size: 14),
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
                            minHeight: 18,
                            borderRadius: BorderRadius.circular(8),
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(isWarning ? Colors.red : Colors.lightGreen),
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

            /// Prior / Periodicity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${S.of(context).to_be_performed} \n$priorExecution", style: const TextStyle(fontSize: 13)),
                Container(width: 1, height: 32, color: Colors.grey.shade300),
                Text("${S.of(context).periodicity}\n$periodicity", style: const TextStyle(fontSize: 13)),
              ],
            ),

            /// Bottom action
            Center(
              child: TextButton(onPressed: () {}, child: Text(S.of(context).configure_action)),
            ),
          ],
        ),
      ),
    );
  }
}
