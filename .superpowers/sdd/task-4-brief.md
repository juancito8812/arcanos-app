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

