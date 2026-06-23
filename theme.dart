import 'package:flutter/material.dart';

class AppTheme {
  static const Color purplePrimary = Color(0xFF6A1B9A);
  static const Color purpleDark = Color(0xFF4A148C);
  static const Color purpleLight = Color(0xFFCE93D8);
  static const Color goldAccent = Color(0xFFFFD700);
  static const Color goldLight = Color(0xFFFFF8E1);
  static const Color creamBackground = Color(0xFFFDF5E6);
  static const Color darkBackground = Color(0xFF1C0A2E);
  static const Color darkCard = Color(0xFF2D1B4E);
  static const Color textLight = Color(0xFFE1BEE7);
  static const Color textDark = Color(0xFF2C2C2C);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true, brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: purplePrimary, brightness: Brightness.light, primary: purplePrimary, secondary: goldAccent, surface: creamBackground),
    scaffoldBackgroundColor: creamBackground,
    appBarTheme: const AppBarTheme(backgroundColor: purplePrimary, foregroundColor: Colors.white, elevation: 0, centerTitle: true),
    cardTheme: CardTheme(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white, indicatorColor: purpleLight.withAlpha(80),
      labelTextStyle: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.selected)) return const TextStyle(color: purplePrimary, fontSize: 12, fontWeight: FontWeight.w600);
        return const TextStyle(color: Colors.grey, fontSize: 12);
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: purplePrimary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 4),
    ),
    inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: purplePrimary, width: 2)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true, brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(seedColor: purplePrimary, brightness: Brightness.dark, primary: purpleLight, secondary: goldAccent, surface: darkBackground),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(backgroundColor: purpleDark, foregroundColor: Colors.white, elevation: 0, centerTitle: true),
    cardTheme: CardTheme(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: darkCard, indicatorColor: purpleLight.withAlpha(40),
      labelTextStyle: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.selected)) return const TextStyle(color: purpleLight, fontSize: 12, fontWeight: FontWeight.w600);
        return const TextStyle(color: Colors.grey, fontSize: 12);
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: purplePrimary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 4),
    ),
    inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: purpleLight, width: 2)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
  );
}
