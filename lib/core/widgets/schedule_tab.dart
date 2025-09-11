import 'package:fines_plus/core/widgets/action_detail_sheet.dart';
import 'package:fines_plus/core/widgets/maintenance_card.dart';
import 'package:flutter/material.dart';

class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          
          MaintenanceCard(
            title: "Заміна оливи двигуна",
            progress: 0.8,
            priorKm: 5604,
            priorDays: 116,
            periodicityKm: 7000,
       onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, 
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (context) => SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16, 
                      left: 16,
                      right: 16,
                      top: 16,
                    ),
                    child: ActionDetailSheet(title: "Заміна оливи двигуна", priorExecution: "-", periodicity: "-"),
                  ),
                ),
              );
            },

          ),
          const SizedBox(height: 12),

        
       MaintenanceCard(
            title: "Шини зимові",
            icon: Icons.tire_repair,
            progress: 0.0,
            priorExecution: "-",
            periodicity: "-",
            isWarning: true,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (context) => SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                      left: 16,
                      right: 16,
                      top: 16,
                    ),
                    child: ActionDetailSheet(title: "Шини зимові", priorExecution: "-", periodicity: "-"),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          MaintenanceCard(
            title: "Заміна олії АКПП",
            icon: Icons.settings,
            progress: 0.1,
            priorExecution: "5335 км\n111 днів",
            periodicity: "50000 км",
            isWarning: true,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (context) => SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                      left: 16,
                      right: 16,
                      top: 16,
                    ),
                    child: ActionDetailSheet(
                      title: "Заміна олії АКПП",
                      priorExecution: "5335 км\n111 днів",
                      periodicity: "50000 км",
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          MaintenanceCard(
            title: "Діагностика підвіски",
            icon: Icons.medical_services,
            progress: 0.14,
            priorExecution: "26 днів",
            periodicity: "6 місяці",
            isWarning: true,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (context) => SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                      left: 16,
                      right: 16,
                      top: 16,
                    ),
                    child: ActionDetailSheet(
                      title: "Діагностика підвіски",
                      priorExecution: "26 днів",
                      periodicity: "6 місяці",
                    ),
                  ),
                ),
              );
            },
          ),

        ],
      ),
    );
  }
}
