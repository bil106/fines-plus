import 'dart:async';

/// Bridges a tapped local notification's payload from
/// `AppInitializer` (which sets up the plugin before the widget tree
/// exists) to `MyApp`, which owns the router — mirrors the existing
/// app-links/dynamic-links pattern in `app.dart`.
class NotificationTapBus {
  NotificationTapBus._();

  /// Set when the app is cold-started by tapping a notification, before
  /// anything is listening to [stream] yet. `MyApp.initState` checks and
  /// clears this once, in addition to listening to [stream].
  static String? pendingPayload;

  static final StreamController<String> _controller = StreamController<String>.broadcast();

  static Stream<String> get stream => _controller.stream;

  static void emit(String payload) => _controller.add(payload);
}
