# Paletas de Color Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Agregar 5 paletas de color seleccionables (Púrpura, Azul, Verde, Rojo, Ámbar) combinables con modo claro/oscuro.

**Architecture:** `AppTheme` se convierte en generador `themeFor(palette, mode)`. `ThemeProvider` extiende con campo `palette`. Settings agrega selector visual de paletas.

**Tech Stack:** Flutter 3.27+, Dart 3.7+, SharedPreferences, Provider

## Global Constraints
- Sin comentarios en código
- Nombres descriptivos en español
- Seguir patrones existentes del código base
- Mantener acento dorado (`#FFD700`) fijo en todas las paletas

---

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

### Task 2: Extender ThemeProvider con paleta

**Files:**
- Modify: `lib/services/theme_provider.dart`

**Interfaces:**
- Consumes: `AppTheme` (nuevo método `themeFor`)
- Produces: `ThemeProvider.palette`, `ThemeProvider.setPalette(String)`, `ThemeProvider.palettes` (lista de nombres)

- [ ] **Step 1: Escribir ThemeProvider extendido**

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _modeKey = 'theme_mode';
  static const _paletteKey = 'selected_palette';

  static const List<String> palettes = ['purple', 'blue', 'green', 'red', 'amber'];

  ThemeMode _mode = ThemeMode.system;
  String _palette = 'purple';

  ThemeMode get mode => _mode;
  String get palette => _palette;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeValue = prefs.getString(_modeKey) ?? 'system';
    _mode = _themeModeFromString(modeValue);
    _palette = prefs.getString(_paletteKey) ?? 'purple';
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, _themeModeToString(mode));
    notifyListeners();
  }

  Future<void> setPalette(String palette) async {
    _palette = palette;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_paletteKey, palette);
    notifyListeners();
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'light';
      case ThemeMode.dark: return 'dark';
      case ThemeMode.system: return 'system';
    }
  }

  static ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }
}
```

- [ ] **Step 2: Run flutter analyze**

Run: `flutter analyze`

- [ ] **Step 3: Commit**

```bash
git add lib/services/theme_provider.dart
git commit -m "feat: ThemeProvider con soporte de paletas"
```

---

### Task 3: Selector de paleta en Settings

**Files:**
- Modify: `lib/screens/settings/settings_screen.dart`

**Interfaces:**
- Consumes: `ThemeProvider.palette`, `ThemeProvider.setPalette()`, `ThemeProvider.palettes`, `AppTheme.paletteSeeds`, `AppTheme.paletteBgLight`
- Produces: selector visual de 5 círculos de color

- [ ] **Step 1: Agregar selector de paleta debajo del selector de modo**

Agregar dentro del _buildThemeSelector, después del SegmentedButton:

```dart
Widget _buildThemeSelector() {
  final themeProvider = context.watch<ThemeProvider>();
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto), label: Text('Auto')),
        ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode), label: Text('Claro')),
        ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode), label: Text('Oscuro')),
      ],
      selected: {themeProvider.mode},
      onSelectionChanged: (mode) => themeProvider.setMode(mode.first),
    ),
    const SizedBox(height: 16),
    const Text('Paleta de color', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.purplePrimary)),
    const SizedBox(height: 8),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ThemeProvider.palettes.map((p) {
        final selected = themeProvider.palette == p;
        final seed = Color(AppTheme.paletteSeeds[p]!);
        return GestureDetector(
          onTap: () => themeProvider.setPalette(p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: seed,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppTheme.goldAccent : seed.withAlpha(100),
                width: selected ? 3 : 1,
              ),
              boxShadow: selected
                  ? [BoxShadow(color: seed.withAlpha(80), blurRadius: 8, spreadRadius: 1)]
                  : null,
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 22)
                : null,
          ),
        );
      }).toList(),
    ),
  ]);
}
```

- [ ] **Step 2: Flutter analyze**

Run: `flutter analyze`

- [ ] **Step 3: Commit**

```bash
git add lib/screens/settings/settings_screen.dart
git commit -m "feat: selector de paleta de color en Ajustes"
```

---

### Task 4: Conectar paleta en main.dart

**Files:**
- Modify: `lib/main.dart`

**Interfaces:**
- Consumes: `ThemeProvider.palette`, `ThemeProvider.mode`, `AppTheme.themeFor(String, ThemeMode)`

- [ ] **Step 1: Modificar MaterialApp para usar AppTheme.themeFor**

```dart
// Reemplazar:
//   theme: AppTheme.lightTheme,
//   darkTheme: AppTheme.darkTheme,
//   themeMode: themeProvider.mode,
// Con:
  theme: AppTheme.themeFor(themeProvider.palette, ThemeMode.light),
  darkTheme: AppTheme.themeFor(themeProvider.palette, ThemeMode.dark),
  themeMode: themeProvider.mode,
```

- [ ] **Step 2: Flutter analyze**

Run: `flutter analyze`

- [ ] **Step 3: Build APK y verificar**

Run: `flutter build apk --release`

- [ ] **Step 4: Commit**

```bash
git add lib/main.dart
git commit -m "feat: conectar paleta de color en MaterialApp"
```
