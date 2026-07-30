import 'package:flutter/material.dart';

/// Brand seed: deep forest green (see DESIGN.md).
const Color kFxrowsSeed = Color(0xFF1B4D3E);

const String kFontSans = 'IBM Plex Sans';
const String kFontMono = 'IBM Plex Mono';

TextTheme _fxrowsTextTheme(TextTheme base) {
  final sans = base.apply(fontFamily: kFontSans);
  return sans.copyWith(
    headlineSmall: sans.headlineSmall?.copyWith(
      fontFamily: kFontMono,
      fontWeight: FontWeight.w500,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
    titleMedium: sans.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    bodySmall: sans.bodySmall?.copyWith(height: 1.35),
  );
}

ThemeData buildFxrowsTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: kFxrowsSeed,
    brightness: brightness,
  );
  final base = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    brightness: brightness,
    fontFamily: kFontSans,
  );
  final textTheme = _fxrowsTextTheme(base.textTheme);

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      isDense: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
    ),
    listTileTheme: ListTileThemeData(
      selectedColor: scheme.primary,
      selectedTileColor: scheme.primary.withValues(alpha: 0.08),
    ),
  );
}
