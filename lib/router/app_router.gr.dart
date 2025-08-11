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
class AddCarRoute extends PageRouteInfo<void> {
  const AddCarRoute({List<PageRouteInfo>? children})
    : super(AddCarRoute.name, initialChildren: children);

  static const String name = 'AddCarRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AddCarScreen();
    },
  );
}

/// generated route for
/// [CarInfoScreen]
class CarInfoRoute extends PageRouteInfo<void> {
  const CarInfoRoute({List<PageRouteInfo>? children})
    : super(CarInfoRoute.name, initialChildren: children);

  static const String name = 'CarInfoRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CarInfoScreen();
    },
  );
}

/// generated route for
/// [FinesScreen]
class FinesRoute extends PageRouteInfo<void> {
  const FinesRoute({List<PageRouteInfo>? children})
    : super(FinesRoute.name, initialChildren: children);

  static const String name = 'FinesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FinesScreen();
    },
  );
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
