import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'app_config.dart';

/// Looks up a per-brand override for a single ARB string.
///
/// [key] must match the key used in `intl_*.arb` (e.g. `garage_setup_subtitle`).
/// [fallback] is normally the generated string itself, e.g. `S.of(context).garage_setup_subtitle`.
///
/// Use this only for the specific strings a brand actually needs to reword -
/// most UI text should keep calling `S.of(context).xxx` directly and does not
/// need to go through here. When a config's `copyOverrides` map (see
/// core/config/app_config.dart) has no entry for [key], or no `copyOverrides`
/// at all, this simply returns [fallback], so existing brands are unaffected.
///
/// See docs/white-label-playbook.md for the full pattern and the list of
/// keys currently wired up this way.
String brandCopy(BuildContext context, String key, String fallback) {
  final overrides = context.watch<AppConfig>().copyOverrides;
  final override = overrides?[key];
  return (override != null && override.isNotEmpty) ? override : fallback;
}
