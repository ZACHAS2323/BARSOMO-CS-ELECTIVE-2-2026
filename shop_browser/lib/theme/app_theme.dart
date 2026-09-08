import 'package:flutter/material.dart';

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xffe85d3f),
    brightness: brightness,
  );

  return ThemeData(
    colorScheme: scheme,
    brightness: brightness,
    useMaterial3: true,
    scaffoldBackgroundColor: brightness == Brightness.light ? const Color(0xfffffbf6) : null,
    appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
    cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
  );
}
