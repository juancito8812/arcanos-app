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


