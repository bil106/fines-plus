import 'package:core_data/src/models/service_record.dart';

final List<ServiceRecord> mockServiceHistory = [
  ServiceRecord(
    type: ServiceType.plannedService,
    date: "2024-04-13",
    mileage: 1600,
    cost: 15000,
    notes: "Планове ТО",
  ),
  ServiceRecord(
    type: ServiceType.brakeChange,
    date: "2024-01-30",
    mileage: 1000,
    cost: 1200,
    notes: "Заміна гальмівних колодок",
  ),
  ServiceRecord(
    type: ServiceType.oilChange,
    date: "2024-02-20",
    mileage: 1200,
    cost: 800,
    notes: "Заміна масла",
  ),
];
