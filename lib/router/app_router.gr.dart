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
    List<PageRouteInfo>? children,
  }) : super(
         AddCarRoute.name,
         args: AddCarRouteArgs(
           key: key,
           onOpenCarInfo: onOpenCarInfo,
           onFineCheck: onFineCheck,
           onMaintenance: onMaintenance,
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
  });

  final Key? key;

  final VoidCallback? onOpenCarInfo;

  final VoidCallback? onFineCheck;

  final VoidCallback? onMaintenance;

  @override
  String toString() {
    return 'AddCarRouteArgs{key: $key, onOpenCarInfo: $onOpenCarInfo, onFineCheck: $onFineCheck, onMaintenance: $onMaintenance}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddCarRouteArgs) return false;
    return key == other.key &&
        onOpenCarInfo == other.onOpenCarInfo &&
        onFineCheck == other.onFineCheck &&
        onMaintenance == other.onMaintenance;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      onOpenCarInfo.hashCode ^
      onFineCheck.hashCode ^
      onMaintenance.hashCode;
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
    List<PageRouteInfo>? children,
  }) : super(
         CarInfoRoute.name,
         args: CarInfoRouteArgs(
           key: key,
           onCheckFine: onCheckFine,
           onBack: onBack,
         ),
         initialChildren: children,
       );

  static const String name = 'CarInfoRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CarInfoRouteArgs>(
        orElse: () => const CarInfoRouteArgs(),
      );
      return CarInfoScreen(
        key: args.key,
        onCheckFine: args.onCheckFine,
        onBack: args.onBack,
      );
    },
  );
}

class CarInfoRouteArgs {
  const CarInfoRouteArgs({this.key, this.onCheckFine, this.onBack});

  final Key? key;

  final void Function(String, String, String)? onCheckFine;

  final VoidCallback? onBack;

  @override
  String toString() {
    return 'CarInfoRouteArgs{key: $key, onCheckFine: $onCheckFine, onBack: $onBack}';
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
    VoidCallback? onFineCheck,
    List<PageRouteInfo>? children,
  }) : super(
         FinesRoute.name,
         args: FinesRouteArgs(key: key, onFineCheck: onFineCheck),
         initialChildren: children,
       );

  static const String name = 'FinesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FinesRouteArgs>(
        orElse: () => const FinesRouteArgs(),
      );
      return FinesScreen(key: args.key, onFineCheck: args.onFineCheck);
    },
  );
}

class FinesRouteArgs {
  const FinesRouteArgs({this.key, this.onFineCheck});

  final Key? key;

  final VoidCallback? onFineCheck;

  @override
  String toString() {
    return 'FinesRouteArgs{key: $key, onFineCheck: $onFineCheck}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FinesRouteArgs) return false;
    return key == other.key && onFineCheck == other.onFineCheck;
  }

  @override
  int get hashCode => key.hashCode ^ onFineCheck.hashCode;
}

/// generated route for
/// [HistoryScreen]
class HistoryRoute extends PageRouteInfo<HistoryRouteArgs> {
  HistoryRoute({
    Key? key,
    required String carNumber,
    List<PageRouteInfo>? children,
  }) : super(
         HistoryRoute.name,
         args: HistoryRouteArgs(key: key, carNumber: carNumber),
         initialChildren: children,
       );

  static const String name = 'HistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HistoryRouteArgs>();
      return HistoryScreen(key: args.key, carNumber: args.carNumber);
    },
  );
}

class HistoryRouteArgs {
  const HistoryRouteArgs({this.key, required this.carNumber});

  final Key? key;

  final String carNumber;

  @override
  String toString() {
    return 'HistoryRouteArgs{key: $key, carNumber: $carNumber}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HistoryRouteArgs) return false;
    return key == other.key && carNumber == other.carNumber;
  }

  @override
  int get hashCode => key.hashCode ^ carNumber.hashCode;
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
    List<PageRouteInfo>? children,
  }) : super(
         MaintenanceRoute.name,
         args: MaintenanceRouteArgs(key: key, onBack: onBack),
         initialChildren: children,
       );

  static const String name = 'MaintenanceRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MaintenanceRouteArgs>(
        orElse: () => const MaintenanceRouteArgs(),
      );
      return MaintenanceScreen(key: args.key, onBack: args.onBack);
    },
  );
}

class MaintenanceRouteArgs {
  const MaintenanceRouteArgs({this.key, this.onBack});

  final Key? key;

  final VoidCallback? onBack;

  @override
  String toString() {
    return 'MaintenanceRouteArgs{key: $key, onBack: $onBack}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MaintenanceRouteArgs) return false;
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
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsScreen();
    },
  );
}

/// generated route for
/// [SupportScreen]
class SupportRoute extends PageRouteInfo<SupportRouteArgs> {
  SupportRoute({
    Key? key,
    required AppConfig config,
    List<PageRouteInfo>? children,
  }) : super(
         SupportRoute.name,
         args: SupportRouteArgs(key: key, config: config),
         initialChildren: children,
       );

  static const String name = 'SupportRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SupportRouteArgs>();
      return SupportScreen(key: args.key, config: args.config);
    },
  );
}

class SupportRouteArgs {
  const SupportRouteArgs({this.key, required this.config});

  final Key? key;

  final AppConfig config;

  @override
  String toString() {
    return 'SupportRouteArgs{key: $key, config: $config}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SupportRouteArgs) return false;
    return key == other.key && config == other.config;
  }

  @override
  int get hashCode => key.hashCode ^ config.hashCode;
}
