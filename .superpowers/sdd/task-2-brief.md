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


