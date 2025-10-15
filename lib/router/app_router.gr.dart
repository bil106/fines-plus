// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AddCarScreen]
class AddCarRoute extends PageRouteInfo<AddCarRouteArgs> {
  AddCarRoute({
    Key? key,
    VoidCallback? onOpenCarInfo,
    VoidCallback? onFineCheck,
    VoidCallback? onMaintenance,
    VoidCallback? onAnalytics,
    List<PageRouteInfo>? children,
  }) : super(
         AddCarRoute.name,
         args: AddCarRouteArgs(
           key: key,
           onOpenCarInfo: onOpenCarInfo,
           onFineCheck: onFineCheck,
           onMaintenance: onMaintenance,
           onAnalytics: onAnalytics,
         ),
         initialChildren: children,
       );

  static const String name = 'AddCarRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddCarRouteArgs>(
        orElse: () => const AddCarRouteArgs(),
      );
      return AddCarScreen(
        key: args.key,
        onOpenCarInfo: args.onOpenCarInfo,
        onFineCheck: args.onFineCheck,
        onMaintenance: args.onMaintenance,
        onAnalytics: args.onAnalytics,
      );
    },
  );
}

class AddCarRouteArgs {
  const AddCarRouteArgs({
    this.key,
    this.onOpenCarInfo,
    this.onFineCheck,
    this.onMaintenance,
    this.onAnalytics,
  });

  final Key? key;

  final VoidCallback? onOpenCarInfo;

  final VoidCallback? onFineCheck;

  final VoidCallback? onMaintenance;

  final VoidCallback? onAnalytics;

  @override
  String toString() {
    return 'AddCarRouteArgs{key: $key, onOpenCarInfo: $onOpenCarInfo, onFineCheck: $onFineCheck, onMaintenance: $onMaintenance, onAnalytics: $onAnalytics}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddCarRouteArgs) return false;
    return key == other.key &&
        onOpenCarInfo == other.onOpenCarInfo &&
        onFineCheck == other.onFineCheck &&
        onMaintenance == other.onMaintenance &&
        onAnalytics == other.onAnalytics;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      onOpenCarInfo.hashCode ^
      onFineCheck.hashCode ^
      onMaintenance.hashCode ^
      onAnalytics.hashCode;
}

/// generated route for
/// [AnalyticsScreen]
class AnalyticsRoute extends PageRouteInfo<AnalyticsRouteArgs> {
  AnalyticsRoute({
    Key? key,
    VoidCallback? onBack,
    required String carNumber,
    List<PageRouteInfo>? children,
  }) : super(
         AnalyticsRoute.name,
         args: AnalyticsRouteArgs(
           key: key,
           onBack: onBack,
           carNumber: carNumber,
         ),
         initialChildren: children,
       );

  static const String name = 'AnalyticsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AnalyticsRouteArgs>();
      return AnalyticsScreen(
        key: args.key,
        onBack: args.onBack,
        carNumber: args.carNumber,
      );
    },
  );
}

class AnalyticsRouteArgs {
  const AnalyticsRouteArgs({this.key, this.onBack, required this.carNumber});

  final Key? key;

  final VoidCallback? onBack;

  final String carNumber;

  @override
  String toString() {
    return 'AnalyticsRouteArgs{key: $key, onBack: $onBack, carNumber: $carNumber}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AnalyticsRouteArgs) return false;
    return key == other.key &&
        onBack == other.onBack &&
        carNumber == other.carNumber;
  }

  @override
  int get hashCode => key.hashCode ^ onBack.hashCode ^ carNumber.hashCode;
}

/// generated route for
/// [CarInfoScreen]
class CarInfoRoute extends PageRouteInfo<CarInfoRouteArgs> {
  CarInfoRoute({
    Key? key,
    void Function(String, String, String)? onCheckFine,
    VoidCallback? onBack,
    required String initialCarNumber,
    List<PageRouteInfo>? children,
  }) : super(
         CarInfoRoute.name,
         args: CarInfoRouteArgs(
           key: key,
           onCheckFine: onCheckFine,
           onBack: onBack,
           initialCarNumber: initialCarNumber,
         ),
         initialChildren: children,
       );

  static const String name = 'CarInfoRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CarInfoRouteArgs>();
      return CarInfoScreen(
        key: args.key,
        onCheckFine: args.onCheckFine,
        onBack: args.onBack,
        initialCarNumber: args.initialCarNumber,
      );
    },
  );
}

class CarInfoRouteArgs {
  const CarInfoRouteArgs({
    this.key,
    this.onCheckFine,
    this.onBack,
    required this.initialCarNumber,
  });

  final Key? key;

  final void Function(String, String, String)? onCheckFine;

  final VoidCallback? onBack;

  final String initialCarNumber;

  @override
  String toString() {
    return 'CarInfoRouteArgs{key: $key, onCheckFine: $onCheckFine, onBack: $onBack, initialCarNumber: $initialCarNumber}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CarInfoRouteArgs) return false;
    return key == other.key &&
        onBack == other.onBack &&
        initialCarNumber == other.initialCarNumber;
  }

  @override
  int get hashCode =>
      key.hashCode ^ onBack.hashCode ^ initialCarNumber.hashCode;
}

/// generated route for
/// [CarWashMapScreen]
class CarWashMapRoute extends PageRouteInfo<CarWashMapRouteArgs> {
  CarWashMapRoute({
    Key? key,
    LatLng? focusPosition,
    String? focusName,
    List<PageRouteInfo>? children,
  }) : super(
         CarWashMapRoute.name,
         args: CarWashMapRouteArgs(
           key: key,
           focusPosition: focusPosition,
           focusName: focusName,
         ),
         initialChildren: children,
       );

  static const String name = 'CarWashMapRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CarWashMapRouteArgs>(
        orElse: () => const CarWashMapRouteArgs(),
      );
      return CarWashMapScreen(
        key: args.key,
        focusPosition: args.focusPosition,
        focusName: args.focusName,
      );
    },
  );
}

class CarWashMapRouteArgs {
  const CarWashMapRouteArgs({this.key, this.focusPosition, this.focusName});

  final Key? key;

  final LatLng? focusPosition;

  final String? focusName;

  @override
  String toString() {
    return 'CarWashMapRouteArgs{key: $key, focusPosition: $focusPosition, focusName: $focusName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CarWashMapRouteArgs) return false;
    return key == other.key &&
        focusPosition == other.focusPosition &&
        focusName == other.focusName;
  }

  @override
  int get hashCode =>
      key.hashCode ^ focusPosition.hashCode ^ focusName.hashCode;
}

/// generated route for
/// [CarWashScreen]
class CarWashRoute extends PageRouteInfo<CarWashRouteArgs> {
  CarWashRoute({Key? key, VoidCallback? onBack, List<PageRouteInfo>? children})
    : super(
        CarWashRoute.name,
        args: CarWashRouteArgs(key: key, onBack: onBack),
        initialChildren: children,
      );

  static const String name = 'CarWashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CarWashRouteArgs>(
        orElse: () => const CarWashRouteArgs(),
      );
      return CarWashScreen(key: args.key, onBack: args.onBack);
    },
  );
}

class CarWashRouteArgs {
  const CarWashRouteArgs({this.key, this.onBack});

  final Key? key;

  final VoidCallback? onBack;

  @override
  String toString() {
    return 'CarWashRouteArgs{key: $key, onBack: $onBack}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CarWashRouteArgs) return false;
    return key == other.key && onBack == other.onBack;
  }

  @override
  int get hashCode => key.hashCode ^ onBack.hashCode;
}

/// generated route for
/// [ExportScreen]
class ExportRoute extends PageRouteInfo<ExportRouteArgs> {
  ExportRoute({
    Key? key,
    required List<EventModel> history,
    required String carNumber,
    VoidCallback? onBack,
    List<PageRouteInfo>? children,
  }) : super(
         ExportRoute.name,
         args: ExportRouteArgs(
           key: key,
           history: history,
           carNumber: carNumber,
           onBack: onBack,
         ),
         initialChildren: children,
       );

  static const String name = 'ExportRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ExportRouteArgs>();
      return ExportScreen(
        key: args.key,
        history: args.history,
        carNumber: args.carNumber,
        onBack: args.onBack,
      );
    },
  );
}

class ExportRouteArgs {
  const ExportRouteArgs({
    this.key,
    required this.history,
    required this.carNumber,
    this.onBack,
  });

  final Key? key;

  final List<EventModel> history;

  final String carNumber;

  final VoidCallback? onBack;

  @override
  String toString() {
    return 'ExportRouteArgs{key: $key, history: $history, carNumber: $carNumber, onBack: $onBack}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ExportRouteArgs) return false;
    return key == other.key &&
        const ListEquality().equals(history, other.history) &&
        carNumber == other.carNumber &&
        onBack == other.onBack;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const ListEquality().hash(history) ^
      carNumber.hashCode ^
      onBack.hashCode;
}

/// generated route for
/// [FineCheckScreen]
class FineCheckRoute extends PageRouteInfo<FineCheckRouteArgs> {
  FineCheckRoute({
    Key? key,
    required String carNumber,
    required String docSeries,
    required String docNumber,
    VoidCallback? onBack,
    List<PageRouteInfo>? children,
  }) : super(
         FineCheckRoute.name,
         args: FineCheckRouteArgs(
           key: key,
           carNumber: carNumber,
           docSeries: docSeries,
           docNumber: docNumber,
           onBack: onBack,
         ),
         initialChildren: children,
       );

  static const String name = 'FineCheckRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FineCheckRouteArgs>();
      return FineCheckScreen(
        key: args.key,
        carNumber: args.carNumber,
        docSeries: args.docSeries,
        docNumber: args.docNumber,
        onBack: args.onBack,
      );
    },
  );
}

class FineCheckRouteArgs {
  const FineCheckRouteArgs({
    this.key,
    required this.carNumber,
    required this.docSeries,
    required this.docNumber,
    this.onBack,
  });

  final Key? key;

  final String carNumber;

  final String docSeries;

  final String docNumber;

  final VoidCallback? onBack;

  @override
  String toString() {
    return 'FineCheckRouteArgs{key: $key, carNumber: $carNumber, docSeries: $docSeries, docNumber: $docNumber, onBack: $onBack}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FineCheckRouteArgs) return false;
    return key == other.key &&
        carNumber == other.carNumber &&
        docSeries == other.docSeries &&
        docNumber == other.docNumber &&
        onBack == other.onBack;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      carNumber.hashCode ^
      docSeries.hashCode ^
      docNumber.hashCode ^
      onBack.hashCode;
}

/// generated route for
/// [FinesScreen]
class FinesRoute extends PageRouteInfo<FinesRouteArgs> {
  FinesRoute({
    Key? key,
    VoidCallback? onBack,
    void Function(String, String, String)? onFineCheck,
    List<PageRouteInfo>? children,
  }) : super(
         FinesRoute.name,
         args: FinesRouteArgs(
           key: key,
           onBack: onBack,
           onFineCheck: onFineCheck,
         ),
         initialChildren: children,
       );

  static const String name = 'FinesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FinesRouteArgs>(
        orElse: () => const FinesRouteArgs(),
      );
      return FinesScreen(
        key: args.key,
        onBack: args.onBack,
        onFineCheck: args.onFineCheck,
      );
    },
  );
}

class FinesRouteArgs {
  const FinesRouteArgs({this.key, this.onBack, this.onFineCheck});

  final Key? key;

  final VoidCallback? onBack;

  final void Function(String, String, String)? onFineCheck;

  @override
  String toString() {
    return 'FinesRouteArgs{key: $key, onBack: $onBack, onFineCheck: $onFineCheck}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FinesRouteArgs) return false;
    return key == other.key && onBack == other.onBack;
  }

  @override
  int get hashCode => key.hashCode ^ onBack.hashCode;
}

/// generated route for
/// [FuelMapScreen]
class FuelMapRoute extends PageRouteInfo<FuelMapRouteArgs> {
  FuelMapRoute({
    Key? key,
    LatLng? focusPosition,
    String? focusName,
    List<PageRouteInfo>? children,
  }) : super(
         FuelMapRoute.name,
         args: FuelMapRouteArgs(
           key: key,
           focusPosition: focusPosition,
           focusName: focusName,
         ),
         initialChildren: children,
       );

  static const String name = 'FuelMapRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FuelMapRouteArgs>(
        orElse: () => const FuelMapRouteArgs(),
      );
      return FuelMapScreen(
        key: args.key,
        focusPosition: args.focusPosition,
        focusName: args.focusName,
      );
    },
  );
}

class FuelMapRouteArgs {
  const FuelMapRouteArgs({this.key, this.focusPosition, this.focusName});

  final Key? key;

  final LatLng? focusPosition;

  final String? focusName;

  @override
  String toString() {
    return 'FuelMapRouteArgs{key: $key, focusPosition: $focusPosition, focusName: $focusName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FuelMapRouteArgs) return false;
    return key == other.key &&
        focusPosition == other.focusPosition &&
        focusName == other.focusName;
  }

  @override
  int get hashCode =>
      key.hashCode ^ focusPosition.hashCode ^ focusName.hashCode;
}

/// generated route for
/// [FuelUpScreen]
class FuelUpRoute extends PageRouteInfo<FuelUpRouteArgs> {
  FuelUpRoute({Key? key, VoidCallback? onBack, List<PageRouteInfo>? children})
    : super(
        FuelUpRoute.name,
        args: FuelUpRouteArgs(key: key, onBack: onBack),
        initialChildren: children,
      );

  static const String name = 'FuelUpRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FuelUpRouteArgs>(
        orElse: () => const FuelUpRouteArgs(),
      );
      return FuelUpScreen(key: args.key, onBack: args.onBack);
    },
  );
}

class FuelUpRouteArgs {
  const FuelUpRouteArgs({this.key, this.onBack});

  final Key? key;

  final VoidCallback? onBack;

  @override
  String toString() {
    return 'FuelUpRouteArgs{key: $key, onBack: $onBack}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FuelUpRouteArgs) return false;
    return key == other.key && onBack == other.onBack;
  }

  @override
  int get hashCode => key.hashCode ^ onBack.hashCode;
}

/// generated route for
/// [HistoryScreen]
class HistoryRoute extends PageRouteInfo<HistoryRouteArgs> {
  HistoryRoute({
    Key? key,
    required String carNumber,
    VoidCallback? onBack,
    List<PageRouteInfo>? children,
  }) : super(
         HistoryRoute.name,
         args: HistoryRouteArgs(key: key, carNumber: carNumber, onBack: onBack),
         initialChildren: children,
       );

  static const String name = 'HistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HistoryRouteArgs>();
      return HistoryScreen(
        key: args.key,
        carNumber: args.carNumber,
        onBack: args.onBack,
      );
    },
  );
}

class HistoryRouteArgs {
  const HistoryRouteArgs({this.key, required this.carNumber, this.onBack});

  final Key? key;

  final String carNumber;

  final VoidCallback? onBack;

  @override
  String toString() {
    return 'HistoryRouteArgs{key: $key, carNumber: $carNumber, onBack: $onBack}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HistoryRouteArgs) return false;
    return key == other.key &&
        carNumber == other.carNumber &&
        onBack == other.onBack;
  }

  @override
  int get hashCode => key.hashCode ^ carNumber.hashCode ^ onBack.hashCode;
}

/// generated route for
/// [HomeScreenWrapper]
class HomeRouteWrapper extends PageRouteInfo<void> {
  const HomeRouteWrapper({List<PageRouteInfo>? children})
    : super(HomeRouteWrapper.name, initialChildren: children);

  static const String name = 'HomeRouteWrapper';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreenWrapper();
    },
  );
}

/// generated route for
/// [MaintenanceScreen]
class MaintenanceRoute extends PageRouteInfo<MaintenanceRouteArgs> {
  MaintenanceRoute({
    Key? key,
    VoidCallback? onBack,
    VoidCallback? onCalendar,
    VoidCallback? onSettings,
    VoidCallback? onFuelUp,
    VoidCallback? onService,
    VoidCallback? onTuning,
    List<PageRouteInfo>? children,
  }) : super(
         MaintenanceRoute.name,
         args: MaintenanceRouteArgs(
           key: key,
           onBack: onBack,
           onCalendar: onCalendar,
           onSettings: onSettings,
           onFuelUp: onFuelUp,
           onService: onService,
           onTuning: onTuning,
         ),
         initialChildren: children,
       );

  static const String name = 'MaintenanceRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MaintenanceRouteArgs>(
        orElse: () => const MaintenanceRouteArgs(),
      );
      return MaintenanceScreen(
        key: args.key,
        onBack: args.onBack,
        onCalendar: args.onCalendar,
        onSettings: args.onSettings,
        onFuelUp: args.onFuelUp,
        onService: args.onService,
        onTuning: args.onTuning,
      );
    },
  );
}

class MaintenanceRouteArgs {
  const MaintenanceRouteArgs({
    this.key,
    this.onBack,
    this.onCalendar,
    this.onSettings,
    this.onFuelUp,
    this.onService,
    this.onTuning,
  });

  final Key? key;

  final VoidCallback? onBack;

  final VoidCallback? onCalendar;

  final VoidCallback? onSettings;

  final VoidCallback? onFuelUp;

  final VoidCallback? onService;

  final VoidCallback? onTuning;

  @override
  String toString() {
    return 'MaintenanceRouteArgs{key: $key, onBack: $onBack, onCalendar: $onCalendar, onSettings: $onSettings, onFuelUp: $onFuelUp, onService: $onService, onTuning: $onTuning}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MaintenanceRouteArgs) return false;
    return key == other.key &&
        onBack == other.onBack &&
        onCalendar == other.onCalendar &&
        onSettings == other.onSettings &&
        onFuelUp == other.onFuelUp &&
        onService == other.onService &&
        onTuning == other.onTuning;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      onBack.hashCode ^
      onCalendar.hashCode ^
      onSettings.hashCode ^
      onFuelUp.hashCode ^
      onService.hashCode ^
      onTuning.hashCode;
}

/// generated route for
/// [RegistrationScreen]
class RegistrationRoute extends PageRouteInfo<RegistrationRouteArgs> {
  RegistrationRoute({
    Key? key,
    VoidCallback? onBack,
    List<PageRouteInfo>? children,
  }) : super(
         RegistrationRoute.name,
         args: RegistrationRouteArgs(key: key, onBack: onBack),
         initialChildren: children,
       );

  static const String name = 'RegistrationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RegistrationRouteArgs>(
        orElse: () => const RegistrationRouteArgs(),
      );
      return RegistrationScreen(key: args.key, onBack: args.onBack);
    },
  );
}

class RegistrationRouteArgs {
  const RegistrationRouteArgs({this.key, this.onBack});

  final Key? key;

  final VoidCallback? onBack;

  @override
  String toString() {
    return 'RegistrationRouteArgs{key: $key, onBack: $onBack}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RegistrationRouteArgs) return false;
    return key == other.key && onBack == other.onBack;
  }

  @override
  int get hashCode => key.hashCode ^ onBack.hashCode;
}

/// generated route for
/// [RemindersScreen]
class RemindersRoute extends PageRouteInfo<RemindersRouteArgs> {
  RemindersRoute({
    Key? key,
    required String carNumber,
    VoidCallback? onBack,
    List<PageRouteInfo>? children,
  }) : super(
         RemindersRoute.name,
         args: RemindersRouteArgs(
           key: key,
           carNumber: carNumber,
           onBack: onBack,
         ),
         initialChildren: children,
       );

  static const String name = 'RemindersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RemindersRouteArgs>();
      return RemindersScreen(
        key: args.key,
        carNumber: args.carNumber,
        onBack: args.onBack,
      );
    },
  );
}

class RemindersRouteArgs {
  const RemindersRouteArgs({this.key, required this.carNumber, this.onBack});

  final Key? key;

  final String carNumber;

  final VoidCallback? onBack;

  @override
  String toString() {
    return 'RemindersRouteArgs{key: $key, carNumber: $carNumber, onBack: $onBack}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RemindersRouteArgs) return false;
    return key == other.key &&
        carNumber == other.carNumber &&
        onBack == other.onBack;
  }

  @override
  int get hashCode => key.hashCode ^ carNumber.hashCode ^ onBack.hashCode;
}

/// generated route for
/// [ScheduleScreen]
class ScheduleRoute extends PageRouteInfo<ScheduleRouteArgs> {
  ScheduleRoute({
    Key? key,
    required ScheduleRepository repository,
    required ReminderRepository reminderRepository,
    required PushHelper pushHelper,
    required String carNumber,
    List<PageRouteInfo>? children,
  }) : super(
         ScheduleRoute.name,
         args: ScheduleRouteArgs(
           key: key,
           repository: repository,
           reminderRepository: reminderRepository,
           pushHelper: pushHelper,
           carNumber: carNumber,
         ),
         initialChildren: children,
       );

  static const String name = 'ScheduleRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ScheduleRouteArgs>();
      return ScheduleScreen(
        key: args.key,
        repository: args.repository,
        reminderRepository: args.reminderRepository,
        pushHelper: args.pushHelper,
        carNumber: args.carNumber,
      );
    },
  );
}

class ScheduleRouteArgs {
  const ScheduleRouteArgs({
    this.key,
    required this.repository,
    required this.reminderRepository,
    required this.pushHelper,
    required this.carNumber,
  });

  final Key? key;

  final ScheduleRepository repository;

  final ReminderRepository reminderRepository;

  final PushHelper pushHelper;

  final String carNumber;

  @override
  String toString() {
    return 'ScheduleRouteArgs{key: $key, repository: $repository, reminderRepository: $reminderRepository, pushHelper: $pushHelper, carNumber: $carNumber}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScheduleRouteArgs) return false;
    return key == other.key &&
        repository == other.repository &&
        reminderRepository == other.reminderRepository &&
        pushHelper == other.pushHelper &&
        carNumber == other.carNumber;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      repository.hashCode ^
      reminderRepository.hashCode ^
      pushHelper.hashCode ^
      carNumber.hashCode;
}

/// generated route for
/// [ServiceScreen]
class ServiceRoute extends PageRouteInfo<ServiceRouteArgs> {
  ServiceRoute({Key? key, VoidCallback? onBack, List<PageRouteInfo>? children})
    : super(
        ServiceRoute.name,
        args: ServiceRouteArgs(key: key, onBack: onBack),
        initialChildren: children,
      );

  static const String name = 'ServiceRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ServiceRouteArgs>(
        orElse: () => const ServiceRouteArgs(),
      );
      return ServiceScreen(key: args.key, onBack: args.onBack);
    },
  );
}

class ServiceRouteArgs {
  const ServiceRouteArgs({this.key, this.onBack});

  final Key? key;

  final VoidCallback? onBack;

  @override
  String toString() {
    return 'ServiceRouteArgs{key: $key, onBack: $onBack}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ServiceRouteArgs) return false;
    return key == other.key && onBack == other.onBack;
  }

  @override
  int get hashCode => key.hashCode ^ onBack.hashCode;
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<SettingsRouteArgs> {
  SettingsRoute({
    Key? key,
    VoidCallback? onBack,
    required RemoteConfigService remoteConfigService,
    required ScheduleCubit scheduleCubit,
    required PurchaseCubit purchaseCubit,
    List<PageRouteInfo>? children,
  }) : super(
         SettingsRoute.name,
         args: SettingsRouteArgs(
           key: key,
           onBack: onBack,
           remoteConfigService: remoteConfigService,
           scheduleCubit: scheduleCubit,
           purchaseCubit: purchaseCubit,
         ),
         initialChildren: children,
       );

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SettingsRouteArgs>();
      return SettingsScreen(
        key: args.key,
        onBack: args.onBack,
        remoteConfigService: args.remoteConfigService,
        scheduleCubit: args.scheduleCubit,
        purchaseCubit: args.purchaseCubit,
      );
    },
  );
}

class SettingsRouteArgs {
  const SettingsRouteArgs({
    this.key,
    this.onBack,
    required this.remoteConfigService,
    required this.scheduleCubit,
    required this.purchaseCubit,
  });

  final Key? key;

  final VoidCallback? onBack;

  final RemoteConfigService remoteConfigService;

  final ScheduleCubit scheduleCubit;

  final PurchaseCubit purchaseCubit;

  @override
  String toString() {
    return 'SettingsRouteArgs{key: $key, onBack: $onBack, remoteConfigService: $remoteConfigService, scheduleCubit: $scheduleCubit, purchaseCubit: $purchaseCubit}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SettingsRouteArgs) return false;
    return key == other.key &&
        onBack == other.onBack &&
        remoteConfigService == other.remoteConfigService &&
        scheduleCubit == other.scheduleCubit &&
        purchaseCubit == other.purchaseCubit;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      onBack.hashCode ^
      remoteConfigService.hashCode ^
      scheduleCubit.hashCode ^
      purchaseCubit.hashCode;
}

/// generated route for
/// [SubscriptionScreen]
class SubscriptionRoute extends PageRouteInfo<void> {
  const SubscriptionRoute({List<PageRouteInfo>? children})
    : super(SubscriptionRoute.name, initialChildren: children);

  static const String name = 'SubscriptionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SubscriptionScreen();
    },
  );
}

/// generated route for
/// [TuningScreen]
class TuningRoute extends PageRouteInfo<TuningRouteArgs> {
  TuningRoute({Key? key, VoidCallback? onBack, List<PageRouteInfo>? children})
    : super(
        TuningRoute.name,
        args: TuningRouteArgs(key: key, onBack: onBack),
        initialChildren: children,
      );

  static const String name = 'TuningRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TuningRouteArgs>(
        orElse: () => const TuningRouteArgs(),
      );
      return TuningScreen(key: args.key, onBack: args.onBack);
    },
  );
}

class TuningRouteArgs {
  const TuningRouteArgs({this.key, this.onBack});

  final Key? key;

  final VoidCallback? onBack;

  @override
  String toString() {
    return 'TuningRouteArgs{key: $key, onBack: $onBack}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TuningRouteArgs) return false;
    return key == other.key && onBack == other.onBack;
  }

  @override
  int get hashCode => key.hashCode ^ onBack.hashCode;
}

/// generated route for
/// [UpdateRequiredScreen]
class UpdateRequiredRoute extends PageRouteInfo<void> {
  const UpdateRequiredRoute({List<PageRouteInfo>? children})
    : super(UpdateRequiredRoute.name, initialChildren: children);

  static const String name = 'UpdateRequiredRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UpdateRequiredScreen();
    },
  );
}
