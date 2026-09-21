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
    int initialTabIndex = 0,
    List<PageRouteInfo>? children,
  }) : super(
         AnalyticsRoute.name,
         args: AnalyticsRouteArgs(
           key: key,
           onBack: onBack,
           carNumber: carNumber,
           initialTabIndex: initialTabIndex,
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
        initialTabIndex: args.initialTabIndex,
      );
    },
  );
}

class AnalyticsRouteArgs {
  const AnalyticsRouteArgs({
    this.key,
    this.onBack,
    required this.carNumber,
    this.initialTabIndex = 0,
  });

  final Key? key;

  final VoidCallback? onBack;

  final String carNumber;

  final int initialTabIndex;

  @override
  String toString() {
    return 'AnalyticsRouteArgs{key: $key, onBack: $onBack, carNumber: $carNumber, initialTabIndex: $initialTabIndex}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AnalyticsRouteArgs) return false;
    return key == other.key &&
        onBack == other.onBack &&
        carNumber == other.carNumber &&
        initialTabIndex == other.initialTabIndex;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      onBack.hashCode ^
      carNumber.hashCode ^
      initialTabIndex.hashCode;
}

/// generated route for
/// [CarInfoScreen]
class CarInfoRoute extends PageRouteInfo<CarInfoRouteArgs> {
  CarInfoRoute({Key? key, VoidCallback? onBack, List<PageRouteInfo>? children})
    : super(
        CarInfoRoute.name,
        args: CarInfoRouteArgs(key: key, onBack: onBack),
        initialChildren: children,
      );

  static const String name = 'CarInfoRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CarInfoRouteArgs>(
        orElse: () => const CarInfoRouteArgs(),
      );
      return CarInfoScreen(key: args.key, onBack: args.onBack);
    },
  );
}

class CarInfoRouteArgs {
  const CarInfoRouteArgs({this.key, this.onBack});

  final Key? key;

  final VoidCallback? onBack;

  @override
  String toString() {
    return 'CarInfoRouteArgs{key: $key, onBack: $onBack}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CarInfoRouteArgs) return false;
    return key == other.key && onBack == other.onBack;
  }

  @override
  int get hashCode => key.hashCode ^ onBack.hashCode;
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
  CarWashRoute({
    Key? key,
    VoidCallback? onBack,
    bool embedded = false,
    List<PageRouteInfo>? children,
  }) : super(
         CarWashRoute.name,
         args: CarWashRouteArgs(key: key, onBack: onBack, embedded: embedded),
         initialChildren: children,
       );

  static const String name = 'CarWashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CarWashRouteArgs>(
        orElse: () => const CarWashRouteArgs(),
      );
      return CarWashScreen(
        key: args.key,
        onBack: args.onBack,
        embedded: args.embedded,
      );
    },
  );
}

class CarWashRouteArgs {
  const CarWashRouteArgs({this.key, this.onBack, this.embedded = false});

  final Key? key;

  final VoidCallback? onBack;

  final bool embedded;

  @override
  String toString() {
    return 'CarWashRouteArgs{key: $key, onBack: $onBack, embedded: $embedded}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CarWashRouteArgs) return false;
    return key == other.key &&
        onBack == other.onBack &&
        embedded == other.embedded;
  }

  @override
  int get hashCode => key.hashCode ^ onBack.hashCode ^ embedded.hashCode;
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
        const ListEquality<EventModel>().equals(history, other.history) &&
        carNumber == other.carNumber &&
        onBack == other.onBack;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const ListEquality<EventModel>().hash(history) ^
      carNumber.hashCode ^
      onBack.hashCode;
}

/// generated route for
/// [FinesScreen]
class FinesRoute extends PageRouteInfo<FinesRouteArgs> {
  FinesRoute({Key? key, VoidCallback? onBack, List<PageRouteInfo>? children})
    : super(
        FinesRoute.name,
        args: FinesRouteArgs(key: key, onBack: onBack),
        initialChildren: children,
      );

  static const String name = 'FinesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FinesRouteArgs>(
        orElse: () => const FinesRouteArgs(),
      );
      return FinesScreen(key: args.key, onBack: args.onBack);
    },
  );
}

class FinesRouteArgs {
  const FinesRouteArgs({this.key, this.onBack});

  final Key? key;

  final VoidCallback? onBack;

  @override
  String toString() {
    return 'FinesRouteArgs{key: $key, onBack: $onBack}';
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
  FuelUpRoute({
    Key? key,
    VoidCallback? onBack,
    bool embedded = false,
    List<PageRouteInfo>? children,
  }) : super(
         FuelUpRoute.name,
         args: FuelUpRouteArgs(key: key, onBack: onBack, embedded: embedded),
         initialChildren: children,
       );

  static const String name = 'FuelUpRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FuelUpRouteArgs>(
        orElse: () => const FuelUpRouteArgs(),
      );
      return FuelUpScreen(
        key: args.key,
        onBack: args.onBack,
        embedded: args.embedded,
      );
    },
  );
}

class FuelUpRouteArgs {
  const FuelUpRouteArgs({this.key, this.onBack, this.embedded = false});

  final Key? key;

  final VoidCallback? onBack;

  final bool embedded;

  @override
  String toString() {
    return 'FuelUpRouteArgs{key: $key, onBack: $onBack, embedded: $embedded}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FuelUpRouteArgs) return false;
    return key == other.key &&
        onBack == other.onBack &&
        embedded == other.embedded;
  }

  @override
  int get hashCode => key.hashCode ^ onBack.hashCode ^ embedded.hashCode;
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

/// generated route for
/// [HomeScreenWrapper]
class HomeRouteWrapper extends PageRouteInfo<HomeRouteWrapperArgs> {
  HomeRouteWrapper({
    Key? key,
    HomePage initialPage = HomePage.home,
    List<PageRouteInfo>? children,
  }) : super(
         HomeRouteWrapper.name,
         args: HomeRouteWrapperArgs(key: key, initialPage: initialPage),
         initialChildren: children,
       );

  static const String name = 'HomeRouteWrapper';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HomeRouteWrapperArgs>(
        orElse: () => const HomeRouteWrapperArgs(),
      );
      return HomeScreenWrapper(key: args.key, initialPage: args.initialPage);
    },
  );
}

class HomeRouteWrapperArgs {
  const HomeRouteWrapperArgs({this.key, this.initialPage = HomePage.home});

  final Key? key;

  final HomePage initialPage;

  @override
  String toString() {
    return 'HomeRouteWrapperArgs{key: $key, initialPage: $initialPage}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HomeRouteWrapperArgs) return false;
    return key == other.key && initialPage == other.initialPage;
  }

  @override
  int get hashCode => key.hashCode ^ initialPage.hashCode;
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
/// [OnboardingScreen]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OnboardingScreen();
    },
  );
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
    required String ownerId,
    VoidCallback? onBack,
    List<PageRouteInfo>? children,
  }) : super(
         RemindersRoute.name,
         args: RemindersRouteArgs(key: key, ownerId: ownerId, onBack: onBack),
         initialChildren: children,
       );

  static const String name = 'RemindersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RemindersRouteArgs>();
      return RemindersScreen(
        key: args.key,
        ownerId: args.ownerId,
        onBack: args.onBack,
      );
    },
  );
}

class RemindersRouteArgs {
  const RemindersRouteArgs({this.key, required this.ownerId, this.onBack});

  final Key? key;

  final String ownerId;

  final VoidCallback? onBack;

  @override
  String toString() {
    return 'RemindersRouteArgs{key: $key, ownerId: $ownerId, onBack: $onBack}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RemindersRouteArgs) return false;
    return key == other.key &&
        ownerId == other.ownerId &&
        onBack == other.onBack;
  }

  @override
  int get hashCode => key.hashCode ^ ownerId.hashCode ^ onBack.hashCode;
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
    required String ownerId,
    String? initialActionKey,
    List<PageRouteInfo>? children,
  }) : super(
         ScheduleRoute.name,
         args: ScheduleRouteArgs(
           key: key,
           repository: repository,
           reminderRepository: reminderRepository,
           pushHelper: pushHelper,
           carNumber: carNumber,
           ownerId: ownerId,
           initialActionKey: initialActionKey,
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
        ownerId: args.ownerId,
        initialActionKey: args.initialActionKey,
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
    required this.ownerId,
    this.initialActionKey,
  });

  final Key? key;

  final ScheduleRepository repository;

  final ReminderRepository reminderRepository;

  final PushHelper pushHelper;

  final String carNumber;

  final String ownerId;

  final String? initialActionKey;

  @override
  String toString() {
    return 'ScheduleRouteArgs{key: $key, repository: $repository, reminderRepository: $reminderRepository, pushHelper: $pushHelper, carNumber: $carNumber, ownerId: $ownerId, initialActionKey: $initialActionKey}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScheduleRouteArgs) return false;
    return key == other.key &&
        repository == other.repository &&
        reminderRepository == other.reminderRepository &&
        pushHelper == other.pushHelper &&
        carNumber == other.carNumber &&
        ownerId == other.ownerId &&
        initialActionKey == other.initialActionKey;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      repository.hashCode ^
      reminderRepository.hashCode ^
      pushHelper.hashCode ^
      carNumber.hashCode ^
      ownerId.hashCode ^
      initialActionKey.hashCode;
}

/// generated route for
/// [ServiceScreen]
class ServiceRoute extends PageRouteInfo<ServiceRouteArgs> {
  ServiceRoute({
    Key? key,
    VoidCallback? onBack,
    bool embedded = false,
    ValueChanged<double>? onTotalChanged,
    String? category,
    List<PageRouteInfo>? children,
  }) : super(
         ServiceRoute.name,
         args: ServiceRouteArgs(
           key: key,
           onBack: onBack,
           embedded: embedded,
           onTotalChanged: onTotalChanged,
           category: category,
         ),
         initialChildren: children,
       );

  static const String name = 'ServiceRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ServiceRouteArgs>(
        orElse: () => const ServiceRouteArgs(),
      );
      return ServiceScreen(
        key: args.key,
        onBack: args.onBack,
        embedded: args.embedded,
        onTotalChanged: args.onTotalChanged,
        category: args.category,
      );
    },
  );
}

class ServiceRouteArgs {
  const ServiceRouteArgs({
    this.key,
    this.onBack,
    this.embedded = false,
    this.onTotalChanged,
    this.category,
  });

  final Key? key;

  final VoidCallback? onBack;

  final bool embedded;

  final ValueChanged<double>? onTotalChanged;

  final String? category;

  @override
  String toString() {
    return 'ServiceRouteArgs{key: $key, onBack: $onBack, embedded: $embedded, onTotalChanged: $onTotalChanged, category: $category}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ServiceRouteArgs) return false;
    return key == other.key &&
        onBack == other.onBack &&
        embedded == other.embedded &&
        onTotalChanged == other.onTotalChanged &&
        category == other.category;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      onBack.hashCode ^
      embedded.hashCode ^
      onTotalChanged.hashCode ^
      category.hashCode;
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<SettingsRouteArgs> {
  SettingsRoute({Key? key, VoidCallback? onBack, List<PageRouteInfo>? children})
    : super(
        SettingsRoute.name,
        args: SettingsRouteArgs(key: key, onBack: onBack),
        initialChildren: children,
      );

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SettingsRouteArgs>(
        orElse: () => const SettingsRouteArgs(),
      );
      return SettingsScreen(key: args.key, onBack: args.onBack);
    },
  );
}

class SettingsRouteArgs {
  const SettingsRouteArgs({this.key, this.onBack});

  final Key? key;

  final VoidCallback? onBack;

  @override
  String toString() {
    return 'SettingsRouteArgs{key: $key, onBack: $onBack}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SettingsRouteArgs) return false;
    return key == other.key && onBack == other.onBack;
  }

  @override
  int get hashCode => key.hashCode ^ onBack.hashCode;
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}

/// generated route for
/// [SubscriptionScreen]
class SubscriptionRoute extends PageRouteInfo<SubscriptionRouteArgs> {
  SubscriptionRoute({
    Key? key,
    bool debugMode = true,
    VoidCallback? onBack,
    VoidCallback? onPurchaseSuccess,
    List<PageRouteInfo>? children,
  }) : super(
         SubscriptionRoute.name,
         args: SubscriptionRouteArgs(
           key: key,
           debugMode: debugMode,
           onBack: onBack,
           onPurchaseSuccess: onPurchaseSuccess,
         ),
         initialChildren: children,
       );

  static const String name = 'SubscriptionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SubscriptionRouteArgs>(
        orElse: () => const SubscriptionRouteArgs(),
      );
      return SubscriptionScreen(
        key: args.key,
        debugMode: args.debugMode,
        onBack: args.onBack,
        onPurchaseSuccess: args.onPurchaseSuccess,
      );
    },
  );
}

class SubscriptionRouteArgs {
  const SubscriptionRouteArgs({
    this.key,
    this.debugMode = true,
    this.onBack,
    this.onPurchaseSuccess,
  });

  final Key? key;

  final bool debugMode;

  final VoidCallback? onBack;

  final VoidCallback? onPurchaseSuccess;

  @override
  String toString() {
    return 'SubscriptionRouteArgs{key: $key, debugMode: $debugMode, onBack: $onBack, onPurchaseSuccess: $onPurchaseSuccess}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SubscriptionRouteArgs) return false;
    return key == other.key &&
        debugMode == other.debugMode &&
        onBack == other.onBack &&
        onPurchaseSuccess == other.onPurchaseSuccess;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      debugMode.hashCode ^
      onBack.hashCode ^
      onPurchaseSuccess.hashCode;
}

/// generated route for
/// [TuningScreen]
class TuningRoute extends PageRouteInfo<TuningRouteArgs> {
  TuningRoute({
    Key? key,
    VoidCallback? onBack,
    bool embedded = false,
    List<PageRouteInfo>? children,
  }) : super(
         TuningRoute.name,
         args: TuningRouteArgs(key: key, onBack: onBack, embedded: embedded),
         initialChildren: children,
       );

  static const String name = 'TuningRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TuningRouteArgs>(
        orElse: () => const TuningRouteArgs(),
      );
      return TuningScreen(
        key: args.key,
        onBack: args.onBack,
        embedded: args.embedded,
      );
    },
  );
}

class TuningRouteArgs {
  const TuningRouteArgs({this.key, this.onBack, this.embedded = false});

  final Key? key;

  final VoidCallback? onBack;

  final bool embedded;

  @override
  String toString() {
    return 'TuningRouteArgs{key: $key, onBack: $onBack, embedded: $embedded}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TuningRouteArgs) return false;
    return key == other.key &&
        onBack == other.onBack &&
        embedded == other.embedded;
  }

  @override
  int get hashCode => key.hashCode ^ onBack.hashCode ^ embedded.hashCode;
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
