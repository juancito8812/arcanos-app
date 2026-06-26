### Task 1: Refactor AppTheme a generador por paleta

**Files:**
- Modify: `lib/theme.dart`

**Interfaces:**
- Consumes: nada (raíz)
- Produces: `AppTheme.themeFor(String palette, ThemeMode mode) → ThemeData`
- Produce: enum/constantes para nombres de paleta

- [ ] **Step 1: Rewrite theme.dart con generador de paletas**

```dart
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

  static const Map<String, int> paletteSeeds = {
    'purple': 0xFF6A1B9A,
    'blue': 0xFF1565C0,
    'green': 0xFF2E7D32,
    'red': 0xFFC62828,
    'amber': 0xFFFF8F00,
  };

  static const Map<String, int> paletteBgLight = {
    'purple': 0xFFFDF5E6,
    'blue': 0xFFE3F2FD,
    'green': 0xFFE8F5E9,
    'red': 0xFFFFEBEE,
    'amber': 0xFFFFF8E1,
  };

  static const Map<String, int> paletteBgDark = {
    'purple': 0xFF1C0A2E,
    'blue': 0xFF0D1B2A,
    'green': 0xFF0A1F0E,
    'red': 0xFF2A0D0D,
    'amber': 0xFF2A1F0D,
  };

  static int _bgFor(String palette, Brightness brightness) {
    return brightness == Brightness.light
        ? (paletteBgLight[palette] ?? paletteBgLight['purple']!)
        : (paletteBgDark[palette] ?? paletteBgDark['purple']!);
  }

  static Color _seedFor(String palette) {
    return Color(paletteSeeds[palette] ?? paletteSeeds['purple']!);
  }

  static ThemeData themeFor(String palette, ThemeMode mode) {
    final isDark = mode == ThemeMode.dark;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final seed = _seedFor(palette);
    final bg = Color(_bgFor(palette, brightness));

    final cs = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      primary: isDark ? null : seed,
      surface: bg,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF4A148C) : seed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF2D1B4E) : Colors.white,
        indicatorColor: cs.primary.withAlpha(isDark ? 40 : 80),
        labelTextStyle: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) {
            return TextStyle(
              color: isDark ? cs.primary : const Color(0xFF6A1B9A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(color: Colors.grey, fontSize: 12);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  static ThemeData lightTheme = themeFor('purple', ThemeMode.light);
  static ThemeData darkTheme = themeFor('purple', ThemeMode.dark);
}
```

- [ ] **Step 2: Run flutter analyze para verificar**

Run: `flutter analyze`

- [ ] **Step 3: Commit**

```bash
git add lib/theme.dart
git commit -m "refactor: AppTheme como generador de paletas"
```

---


