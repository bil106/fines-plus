import 'package:flutter/material.dart';

class MaintenanceCard extends StatelessWidget {
  final String title;
  final double progress; // от 0 до 1
  final int priorKm;
  final int priorDays;
  final int periodicityKm;

  const MaintenanceCard({
    super.key,
    required this.title,
    required this.progress,
    required this.priorKm,
    required this.priorDays,
    required this.periodicityKm,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
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
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.shade50,
                  child: const Icon(Icons.oil_barrel, color: Colors.orange, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Resource:"),
                      const SizedBox(height: 4),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 20,
                            borderRadius: BorderRadius.circular(8),
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text("$priorKm km", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("$priorDays days", style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                Column(
                  children: [
                    Text("$periodicityKm km", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text("Periodicity", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),

            /// Configure action
            Center(
              child: TextButton(onPressed: () {}, child: const Text("Configure an action")),
            ),
          ],
        ),
      ),
    );
  }
}
