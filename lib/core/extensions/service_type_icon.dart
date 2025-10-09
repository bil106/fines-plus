import 'package:fines_plus/features/expenses/data/models/service_record.dart';
import 'package:flutter/material.dart';


extension ServiceTypeX on ServiceType {
  IconData get icon {
    switch (this) {
      case ServiceType.plannedService:
        return Icons.event_note;
      case ServiceType.brakeChange:
        return Icons.car_repair;
      case ServiceType.oilChange:
        return Icons.oil_barrel;
      case ServiceType.other:
        return Icons.build;
    }
  }
}
