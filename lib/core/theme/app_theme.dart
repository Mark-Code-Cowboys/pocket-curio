import 'package:flutter/material.dart';

/// Placeholder palette seeded from curio violet (#7A4E7E) per the build
/// prompt; the hand-tuned display-shelf palette lands in the polish phase.
///
/// cc_core gap: this file is the same shape as Table Encore's and Course
/// Ledger's AppTheme — the base-theme-from-tokens belongs in cc_core
/// `theme/` (tracked in docs/cc-core-gaps.md).
abstract final class AppTheme {
  static const _curioViolet = Color(0xFF7A4E7E);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: _curioViolet).copyWith(
      primary: _curioViolet,
      onPrimary: Colors.white,
    );
    return _base(scheme);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _curioViolet,
      brightness: Brightness.dark,
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
    );
  }
}
