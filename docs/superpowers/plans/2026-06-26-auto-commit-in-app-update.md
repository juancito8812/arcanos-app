# Auto-Commit + In-App Update — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development

**Goal:** Auto-commit after edits + in-app update flow with GitHub release

**Architecture:** UpdateService + Settings UI already exist; needs HomeScreen auto-check badge + 24h reminder suppression + version bump + release

**Tech Stack:** Flutter, dio, open_filex, package_info_plus, path_provider, SharedPreferences

## Global Constraints
- Sin comentarios en código
- Nombres descriptivos en español
- Version bump: 2.1.0+4 → 2.2.0+5
- Tag: v2.2.0
- APK name: app-release.apk

---

### Task 1: Auto-check update en HomeScreen

**Files:**
- Modify: `lib/screens/home_screen.dart` — convert to StatefulWidget, add `initState` check + update banner
- Modify: `lib/services/update_service.dart` — add `UpdateInfo` already has needed fields

**Interfaces:**
- Consumes: `UpdateService.checkForUpdate()` → `UpdateInfo?`
- Consumes: `UpdateService.downloadApk()`, `UpdateService.installApk()`
- Produces: UI in HomeScreen showing badge + auto-dialog with 24h suppression

**Steps:**

- [ ] **Step 1: Convert HomeScreen to StatefulWidget**

Current HomeScreen is `StatelessWidget`. Convert to `StatefulWidget` to hold update state. Add fields:
```dart
UpdateInfo? _updateInfo;
bool _checkingUpdate = true;
```

- [ ] **Step 2: Add auto-check in `initState`**

```dart
@override
void initState() {
  super.initState();
  _checkForUpdates();
}

Future<void> _checkForUpdates() async {
  final info = await UpdateService.checkForUpdate();
  if (!mounted) return;
  setState(() {
    _updateInfo = (info != null && info.isNewer) ? info : null;
    _checkingUpdate = false;
  });
  // Dialog if new update and not shown in 24h
  if (_updateInfo != null) {
    final prefs = await SharedPreferences.getInstance();
    final lastReminder = prefs.getInt('last_update_reminder') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastReminder > 24 * 60 * 60 * 1000) {
      await prefs.setInt('last_update_reminder', now);
      if (mounted) _showUpdateDialog(context);
    }
  }
}
```

- [ ] **Step 3: Add update banner below header**

After the header in build():
```dart
if (_updateInfo != null)
  _UpdateBanner(updateInfo: _updateInfo!),
```

Define `_UpdateBanner`:
```dart
class _UpdateBanner extends StatelessWidget {
  final UpdateInfo updateInfo;
  const _UpdateBanner({required this.updateInfo});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppTheme.goldAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showUpdateDialog(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              const Icon(Icons.system_update, color: AppTheme.goldAccent, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text('Nueva versión ${updateInfo.version} disponible',
                style: const TextStyle(fontWeight: FontWeight.w600))),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ]),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Add update dialog method**

```dart
void _showUpdateDialog(BuildContext context) {
  showDialog(context: context, builder: (ctx) => AlertDialog(
    title: Text('Nueva versión ${_updateInfo!.version}'),
    content: SingleChildScrollView(child: Text(_updateInfo!.changelog ?? 'Nuevos cambios disponibles')),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Más tarde')),
      ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(ctx);
          _downloadAndInstall();
        },
        icon: const Icon(Icons.download, size: 18),
        label: const Text('Descargar e instalar'),
      ),
    ],
  ));
}

Future<void> _downloadAndInstall() async {
  // ... show progress dialog, call UpdateService.downloadApk + installApk
}
```

- [ ] **Step 5: Add imports**

```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../services/update_service.dart';
```

- [ ] **Step 6: Run flutter analyze**
- [ ] **Step 7: Commit** `checkpoint: auto-check update en HomeScreen`

---

### Task 2: Bump version + Build APK

**Files:**
- Modify: `pubspec.yaml` — version: 2.2.0+5

- [ ] **Step 1: Edit pubspec.yaml version**
- [ ] **Step 2: Run flutter analyze**
- [ ] **Step 3: Commit** `feat: bump version 2.2.0+5`

```bash
git add -A
git commit -m "feat: bump version 2.2.0+5"
```

- [ ] **Step 4: Build release APK**

```bash
& "C:\Users\Juan Sanchez\flutter_sdk\flutter\bin\flutter.bat" build apk --release
```

---

### Task 3: Tag + GitHub Release

- [ ] **Step 1: Tag**

```bash
git tag v2.2.0
git push origin v2.2.0
git push origin master
```

- [ ] **Step 2: Create release**

```bash
gh release create v2.2.0 `
  --title "v2.2.0 - Actualización in-app" `
  --notes "Nueva funcionalidad: detección automática de actualizaciones desde la misma app. Descarga e instala nuevas versiones directamente." `
  "build/app/outputs/flutter-apk/app-release.apk"
```
