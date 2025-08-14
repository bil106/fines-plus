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
    List<PageRouteInfo>? children,
  }) : super(
         AddCarRoute.name,
         args: AddCarRouteArgs(key: key, onOpenCarInfo: onOpenCarInfo),
         initialChildren: children,
       );

  static const String name = 'AddCarRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddCarRouteArgs>(
        orElse: () => const AddCarRouteArgs(),
      );
      return AddCarScreen(key: args.key, onOpenCarInfo: args.onOpenCarInfo);
    },
  );
}

class AddCarRouteArgs {
  const AddCarRouteArgs({this.key, this.onOpenCarInfo});

  final Key? key;

  final VoidCallback? onOpenCarInfo;

  @override
  String toString() {
    return 'AddCarRouteArgs{key: $key, onOpenCarInfo: $onOpenCarInfo}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddCarRouteArgs) return false;
    return key == other.key && onOpenCarInfo == other.onOpenCarInfo;
  }

  @override
  int get hashCode => key.hashCode ^ onOpenCarInfo.hashCode;
}

/// generated route for
/// [CarInfoScreen]
class CarInfoRoute extends PageRouteInfo<CarInfoRouteArgs> {
  CarInfoRoute({
    Key? key,
    ValueChanged<String>? onCheckFine,
    List<PageRouteInfo>? children,
  }) : super(
         CarInfoRoute.name,
         args: CarInfoRouteArgs(key: key, onCheckFine: onCheckFine),
         initialChildren: children,
       );

  static const String name = 'CarInfoRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CarInfoRouteArgs>(
        orElse: () => const CarInfoRouteArgs(),
      );
      return CarInfoScreen(key: args.key, onCheckFine: args.onCheckFine);
    },
  );
}

class CarInfoRouteArgs {
  const CarInfoRouteArgs({this.key, this.onCheckFine});

  final Key? key;

  final ValueChanged<String>? onCheckFine;

  @override
  String toString() {
    return 'CarInfoRouteArgs{key: $key, onCheckFine: $onCheckFine}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CarInfoRouteArgs) return false;
    return key == other.key && onCheckFine == other.onCheckFine;
  }

  @override
  int get hashCode => key.hashCode ^ onCheckFine.hashCode;
}

/// generated route for
/// [FineCheckScreen]
class FineCheckRoute extends PageRouteInfo<FineCheckRouteArgs> {
  FineCheckRoute({
    Key? key,
    VoidCallback? onFineCheck,
    required String carNumber,
    List<PageRouteInfo>? children,
  }) : super(
         FineCheckRoute.name,
         args: FineCheckRouteArgs(
           key: key,
           onFineCheck: onFineCheck,
           carNumber: carNumber,
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
        onFineCheck: args.onFineCheck,
        carNumber: args.carNumber,
      );
    },
  );
}

class FineCheckRouteArgs {
  const FineCheckRouteArgs({
    this.key,
    this.onFineCheck,
    required this.carNumber,
  });

  final Key? key;

  final VoidCallback? onFineCheck;

  final String carNumber;

  @override
  String toString() {
    return 'FineCheckRouteArgs{key: $key, onFineCheck: $onFineCheck, carNumber: $carNumber}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FineCheckRouteArgs) return false;
    return key == other.key &&
        onFineCheck == other.onFineCheck &&
        carNumber == other.carNumber;
  }

  @override
  int get hashCode => key.hashCode ^ onFineCheck.hashCode ^ carNumber.hashCode;
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
/// [RemindersScreen]
class RemindersRoute extends PageRouteInfo<void> {
  const RemindersRoute({List<PageRouteInfo>? children})
    : super(RemindersRoute.name, initialChildren: children);

  static const String name = 'RemindersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RemindersScreen();
    },
  );
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
