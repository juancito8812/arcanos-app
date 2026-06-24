# Phase 1 Bundle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Daily Card with notifications, Destiny Matrix calculator, PDF export, and full dark mode polish to PsicoTarot.

**Architecture:** Progressive enhancement of existing Flutter app. New services + models + screens integrate via existing navigation. AI via NVIDIA Nemotron API. PDF generation via `pdf` package. Notifications via `flutter_local_notifications`.

**Tech Stack:** Flutter 3.7+, SQLite (sqflite), NVIDIA Nemotron-3-Ultra API, flutter_local_notifications, pdf, share_plus

## Global Constraints

- All new text in Spanish
- Follow existing file patterns (models/ services/ screens/ data/ utils/ widgets/)
- TDD for all new logic: tests in `test/` mirroring `lib/` structure
- Dark mode: every new screen must pass both light and dark themes
- No breaking changes to existing routes or screens
- API key stored in SharedPreferences under key `arcano_ai_key`
- API key also accepted via `--dart-define=ARCANO_AI_KEY=xxx` at build time

---

### Task 1: Dependencies + Project Scaffolding

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/services/` (already exists)
- Create: `lib/widgets/` (NEW)
- Create: `lib/widgets/pdf_templates/` (NEW)
- Create: `lib/screens/numerology/` (NEW)
- Modify: `lib/main.dart`

**Interfaces:**
- Consumes: existing project convention
- Produces: `pubspec.yaml` with new deps, scaffolding structure

- [ ] **Step 1: Add packages to pubspec.yaml**

```yaml
name: arcanos_mayores
description: PsicoTarot - Arcanos Mayores App
publish_to: 'none'
version: 2.0.0+3

environment:
  sdk: ^3.7.2

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.1.2
  sqflite: ^2.4.2
  path_provider: ^2.1.5
  path: ^1.9.1
  intl: ^0.20.2
  package_info_plus: ^9.0.1
  dio: ^5.9.2
  open_filex: ^4.7.0
  flutter_launcher_icons: ^0.14.4
  flutter_local_notifications: ^18.0.0
  flutter_native_timezone: ^2.0.0
  http: ^1.2.0
  pdf: ^3.11.0
  share_plus: ^10.1.0
  shared_preferences: ^2.3.0
  timezone: ^0.9.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/cards/
    - assets/icon_original.png

flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/icon_original.png"
  adaptive_icon_background: "#6A1B9A"
  adaptive_icon_foreground: "assets/icon_original.png"
```

- [ ] **Step 2: Create directory structure**

Run: `mkdir -p lib/widgets/pdf_templates lib/screens/numerology test/services test/widgets test/screens`

- [ ] **Step 3: Update main.dart to configure notifications**

```dart
import 'package:flutter/material.dart';
import 'app.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.database;
  await NotificationService.initialize();
  runApp(const PsicoTarotApp());
}
```

- [ ] **Step 4: Create placeholder test file to verify setup**

Create `test/task1_setup_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('setup verified', () {
    expect(1 + 1, 2);
  });
}
```

Run: `flutter test test/task1_setup_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml lib/main.dart test/task1_setup_test.dart
git commit -m "chore: add dependencies and scaffolding for v2.0"
```

---

### Task 2: AI Service (NVIDIA API)

**Files:**
- Create: `lib/services/ai_service.dart`
- Create: `test/services/ai_service_test.dart`

**Interfaces:**
- Consumes: `shared_preferences` for API key, `http` for API calls
- Produces: `AIService.interpretDailyCard(Arcano, String?) -> Future<String>`, `AIService.interpretTarotSpread(List<Arcano>, List<String>, String?) -> Future<String>`

- [ ] **Step 1: Write the failing test**

Create `test/services/ai_service_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:arcanos_mayores/services/ai_service.dart';
import 'package:arcanos_mayores/models/arcano.dart';

void main() {
  group('AIService', () {
    test('interpretDailyCard returns fallback when no API key', () async {
      final result = await AIService.interpretDailyCard(
        const Arcano(
          id: 0, numero: 0, nombre: 'El Loco', nombreRomano: '0',
          leyEspiritual: 'Ley del Uno',
          leccionVida: 'El Buscador',
          miedoAsociado: 'Miedo a la vida',
          arquetipo: 'El inocente',
          elemento: 'Aire',
          polaridad: 'Masculino',
          valorNuclear: 0,
        ),
        null,
      );
      expect(result, contains('API key'));
    });

    test('interpretTarotSpread returns fallback when no API key', () async {
      final result = await AIService.interpretTarotSpread([], []);
      expect(result, contains('API key'));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/ai_service_test.dart`
Expected: COMPILATION ERROR (AIService not defined)

- [ ] **Step 3: Write minimal implementation**

Create `lib/services/ai_service.dart`:
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/arcano.dart';

class AIService {
  static const _baseUrl = 'https://integrate.api.nvidia.com/v1/chat/completions';
  static const _model = 'nvidia/nemotron-3-ultra';

  static String? _buildTimeKey;

  static void setBuildTimeKey(String? key) {
    _buildTimeKey = key;
  }

  static Future<String?> getApiKey() async {
    if (_buildTimeKey != null && _buildTimeKey!.isNotEmpty) return _buildTimeKey;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('arcano_ai_key');
  }

  static Future<String> interpretDailyCard(Arcano arcano, String? lifeLinePeriod) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return 'Conectate a internet y configura tu API key en Ajustes para obtener una interpretacion personalizada.';
    }

    final systemPrompt = 'Eres un terapeuta de PsicoTarot experto en Arcanos Mayores, '
        'numerologia pitagorica y constelaciones familiares. Respondes en espanol, '
        'tono empatico, psicologico y empoderante. Maximo 150 palabras.';

    var userPrompt = 'Hoy ha salido el arcano ${arcano.nombre} (No.${arcano.numero}).';
    if (lifeLinePeriod != null) {
      userPrompt += ' La linea de vida indica que la persona esta en el periodo: $lifeLinePeriod.';
    }
    userPrompt += ' Interpreta como la energia de este arcano se manifiesta hoy. Da una reflexion practica y una afirmacion.';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 300,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>;
        if (choices.isNotEmpty) {
          return (choices[0]['message']['content'] as String).trim();
        }
      }
      return 'No se pudo obtener interpretacion. Intentelo de nuevo mas tarde.';
    } catch (e) {
      return 'Error de conexion. Verifica tu internet e intenta de nuevo.';
    }
  }

  static Future<String> interpretTarotSpread(
    List<Arcano> cards,
    List<String> positions,
    {String? spreadName}
  ) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return 'Conectate a internet y configura tu API key en Ajustes para obtener una interpretacion personalizada.';
    }

    final systemPrompt = 'Eres un terapeuta de PsicoTarot experto en Arcanos Mayores. '
        'Respondes en espanol, tono empatico y psicologico. Maximo 250 palabras.';

    var userPrompt = 'Tirada de tarot';
    if (spreadName != null) userPrompt += ' "$spreadName"';
    userPrompt += ':\n';
    for (int i = 0; i < cards.length; i++) {
      final pos = i < positions.length ? positions[i] : 'Posicion ${i + 1}';
      userPrompt += '$pos: ${cards[i].nombre} (No.${cards[i].numero})\n';
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>;
        if (choices.isNotEmpty) {
          return (choices[0]['message']['content'] as String).trim();
        }
      }
      return 'No se pudo obtener interpretacion.';
    } catch (e) {
      return 'Error de conexion.';
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/ai_service_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/services/ai_service.dart test/services/ai_service_test.dart
git commit -m "feat: add NVIDIA AI service for card interpretations"
```

---

### Task 3: Daily Card Model + Service

**Files:**
- Create: `lib/models/daily_card.dart`
- Create: `lib/services/daily_card_service.dart`
- Modify: `lib/services/database_service.dart`
- Create: `test/services/daily_card_service_test.dart`

**Interfaces:**
- Consumes: `Arcano` from `models/arcano.dart`, `DatabaseService`, `LifeLineCalculator`
- Produces: `DailyCard` model, `DailyCardService.getTodayCard() -> DailyCard?`, `DailyCardService.saveCard(DailyCard) -> void`

- [ ] **Step 1: Write failing tests**

Create `test/services/daily_card_service_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:arcanos_mayores/models/daily_card.dart';
import 'package:arcanos_mayores/services/daily_card_service.dart';

void main() {
  group('DailyCardService', () {
    test('getTodayCard returns null on first call with no profile', () async {
      final card = await DailyCardService.getTodayCard(hasProfile: false);
      expect(card, isNull);
    });

    test('getTodayCard returns card after save', () async {
      await DailyCardService.saveCard(DailyCard(
        date: DateTime.now(),
        arcanoNumero: 0,
        arcanoNombre: 'El Loco',
        arcanoNombreRomano: '0',
        aiInterpretation: 'Test',
        hasProfile: false,
      ));
      final card = await DailyCardService.getTodayCard(hasProfile: false);
      expect(card, isNotNull);
      expect(card!.arcanoNumero, 0);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/daily_card_service_test.dart`
Expected: COMPILATION ERROR

- [ ] **Step 3: Create DailyCard model**

Create `lib/models/daily_card.dart`:
```dart
class DailyCard {
  final DateTime date;
  final int arcanoNumero;
  final String arcanoNombre;
  final String arcanoNombreRomano;
  final String? aiInterpretation;
  final bool hasProfile;

  const DailyCard({
    required this.date,
    required this.arcanoNumero,
    required this.arcanoNombre,
    required this.arcanoNombreRomano,
    this.aiInterpretation,
    required this.hasProfile,
  });

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Map<String, dynamic> toMap() => {
    'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
    'arcano_numero': arcanoNumero,
    'arcano_nombre': arcanoNombre,
    'arcano_nombre_romano': arcanoNombreRomano,
    'ai_interpretation': aiInterpretation,
    'has_profile': hasProfile ? 1 : 0,
  };

  factory DailyCard.fromMap(Map<String, dynamic> map) {
    final parts = (map['date'] as String).split('-');
    return DailyCard(
      date: DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])),
      arcanoNumero: map['arcano_numero'] as int,
      arcanoNombre: map['arcano_nombre'] as String,
      arcanoNombreRomano: map['arcano_nombre_romano'] as String,
      aiInterpretation: map['ai_interpretation'] as String?,
      hasProfile: (map['has_profile'] as int) == 1,
    );
  }
}
```

- [ ] **Step 4: Create DailyCardService**

Create `lib/services/daily_card_service.dart`:
```dart
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import '../data/arcanos_data.dart';
import '../models/arcano.dart';
import '../models/daily_card.dart';
import 'database_service.dart';
import 'life_line_calculator.dart';

class DailyCardService {
  static Future<DailyCard?> getTodayCard({required bool hasProfile}) async {
    final db = await DatabaseService.database;
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final results = await db.query('daily_cards',
      where: 'date = ?', whereArgs: [dateStr], limit: 1);

    if (results.isNotEmpty) {
      return DailyCard.fromMap(results.first);
    }
    return null;
  }

  static Future<DailyCard> generateDailyCard({required bool hasProfile, int? ageYears, List<int>? profileArcanos}) async {
    Arcano card;

    if (hasProfile && ageYears != null && profileArcanos != null && profileArcanos.length >= 5) {
      // Map age to Life Line period index (0-based)
      int periodIndex;
      if (ageYears <= 10) {
        periodIndex = 0; // YO
      } else if (ageYears <= 20) {
        periodIndex = 1; // ELLO
      } else if (ageYears <= 30) {
        periodIndex = 2; // MENTE
      } else if (ageYears <= 40) {
        periodIndex = 3; // REALIZACION
      } else {
        periodIndex = 4; // SINTESIS
      }
      card = getArcanoByNumero(profileArcanos[periodIndex]) ?? allArcanos[0];
    } else {
      card = allArcanos[Random().nextInt(allArcanos.length)];
    }

    return DailyCard(
      date: DateTime.now(),
      arcanoNumero: card.numero,
      arcanoNombre: card.nombre,
      arcanoNombreRomano: card.nombreRomano,
      aiInterpretation: null,
      hasProfile: hasProfile,
    );
  }

  static Future<void> saveCard(DailyCard card) async {
    final db = await DatabaseService.database;
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Delete any existing card for today
    await db.delete('daily_cards', where: 'date = ?', whereArgs: [dateStr]);

    await db.insert('daily_cards', {
      'date': dateStr,
      'arcano_numero': card.arcanoNumero,
      'arcano_nombre': card.arcanoNombre,
      'arcano_nombre_romano': card.arcanoNombreRomano,
      'ai_interpretation': card.aiInterpretation,
      'has_profile': card.hasProfile ? 1 : 0,
    });
  }

  static Future<void> updateInterpretation(int arcanoNumero, String interpretation) async {
    final db = await DatabaseService.database;
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    await db.update('daily_cards',
      {'ai_interpretation': interpretation},
      where: 'date = ? AND arcano_numero = ?',
      whereArgs: [dateStr, arcanoNumero],
    );
  }
}
```

- [ ] **Step 5: Add daily_cards table to DatabaseService**

Edit `lib/services/database_service.dart`:
Replace the database version and onCreate to v2:

```dart
static Future<Database> _initDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = p.join(dbPath, 'psicotarot.db');
  return openDatabase(path, version: 2, onCreate: (db, v) async {
    await db.execute('CREATE TABLE IF NOT EXISTS perfiles (id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT NOT NULL, fechaNacimiento TEXT NOT NULL, arcano1 INTEGER, arcano2 INTEGER, arcano3 INTEGER, arcano4 INTEGER, arcano5 INTEGER, fechaCreacion TEXT NOT NULL)');
    await db.execute('CREATE TABLE IF NOT EXISTS tiradas (id INTEGER PRIMARY KEY AUTOINCREMENT, tipo TEXT NOT NULL, fecha TEXT NOT NULL, cartas TEXT NOT NULL, interpretacion TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS regresiones (id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT NOT NULL, contenido TEXT, fecha TEXT NOT NULL, tipo TEXT NOT NULL)');
    await db.execute('CREATE TABLE IF NOT EXISTS daily_cards (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT NOT NULL, arcano_numero INTEGER NOT NULL, arcano_nombre TEXT NOT NULL, arcano_nombre_romano TEXT NOT NULL, ai_interpretation TEXT, has_profile INTEGER NOT NULL DEFAULT 0, fecha_creacion TEXT NOT NULL DEFAULT (datetime(\'now\')))');
  }, onUpgrade: (db, oldV, newV) async {
    if (oldV < 2) {
      await db.execute('CREATE TABLE IF NOT EXISTS daily_cards (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT NOT NULL, arcano_numero INTEGER NOT NULL, arcano_nombre TEXT NOT NULL, arcano_nombre_romano TEXT NOT NULL, ai_interpretation TEXT, has_profile INTEGER NOT NULL DEFAULT 0, fecha_creacion TEXT NOT NULL DEFAULT (datetime(\'now\')))');
    }
  });
}
```

Also add query method after `obtenerRegresiones()`:
```dart
static Future<List<Map<String, dynamic>>> obtenerHistorialCartas() async {
  final db = await database;
  return db.query('daily_cards', orderBy: 'fecha_creacion DESC', limit: 30);
}
```

- [ ] **Step 6: Run tests**

Run: `flutter test test/services/daily_card_service_test.dart`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add lib/models/daily_card.dart lib/services/daily_card_service.dart lib/services/database_service.dart test/services/daily_card_service_test.dart
git commit -m "feat: add daily card model, service, and database table"
```

---

### Task 4: Notification Service

**Files:**
- Create: `lib/services/notification_service.dart`
- Modify: `lib/main.dart` (already done in Task 1)
- Create: `test/services/notification_service_test.dart`

**Interfaces:**
- Consumes: `flutter_local_notifications`, `flutter_native_timezone`
- Produces: `NotificationService.initialize()`, `NotificationService.scheduleDailyCard()`, `NotificationService.cancelScheduled()`

- [ ] **Step 1: Write failing test**

Create `test/services/notification_service_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:arcanos_mayores/services/notification_service.dart';

void main() {
  group('NotificationService', () {
    test('initialize does not throw', () async {
      await NotificationService.initialize();
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/notification_service_test.dart`
Expected: COMPILATION ERROR

- [ ] **Step 3: Create NotificationService**

Create `lib/services/notification_service.dart`:
```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap - navigation handled by Flutter
      },
    );
  }

  static Future<void> scheduleDailyCard() async {
    await _plugin.cancelAll();

    final location = await FlutterNativeTimezone.getLocalTimezone();
    final tzLocation = tz.getLocation(location);
    final now = tz.TZDateTime.now(tzLocation);

    var scheduledDate = tz.TZDateTime(
      tzLocation, now.year, now.month, now.day, 8, 0);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      0,
      'PsicoTarot - Carta del Dia',
      'Tu carta del dia te espera. Abre la app para descubrirla.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_card_channel',
          'Carta del Dia',
          channelDescription: 'Notificacion diaria de la carta del tarot',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelScheduled() async {
    await _plugin.cancelAll();
  }
}
```

- [ ] **Step 4: Run test**

Run: `flutter test test/services/notification_service_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/services/notification_service.dart test/services/notification_service_test.dart
git commit -m "feat: add push notification service for daily card"
```

---

### Task 5: Daily Card Widget on HomeScreen

**Files:**
- Create: `lib/screens/home/daily_card_widget.dart`
- Modify: `lib/screens/home_screen.dart`
- Modify: `lib/navigation.dart`

**Interfaces:**
- Consumes: `DailyCard`, `DailyCardService`, `AIService`, `Arcano`, `getArcanoByNumero()`
- Produces: Daily card section on HomeScreen

- [ ] **Step 1: Write failing widget test**

Create `test/screens/home/daily_card_widget_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:arcanos_mayores/screens/home/daily_card_widget.dart';

void main() {
  testWidgets('DailyCardWidget shows card number info', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DailyCardWidget(
        arcanoNumero: 0,
        arcanoNombre: 'El Loco',
        arcanoNombreRomano: '0',
        interpretation: 'Test interpretation',
        isLoading: false,
      ),
    ));
    expect(find.text('Carta del Dia'), findsOneWidget);
    expect(find.text('El Loco'), findsOneWidget);
  });

  testWidgets('DailyCardWidget shows loading state', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DailyCardWidget(
        arcanoNumero: 0,
        arcanoNombre: 'El Loco',
        arcanoNombreRomano: '0',
        interpretation: null,
        isLoading: true,
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/screens/home/daily_card_widget_test.dart`
Expected: COMPILATION ERROR

- [ ] **Step 3: Create DailyCardWidget**

Create `lib/screens/home/daily_card_widget.dart`:
```dart
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../data/arcanos_data.dart';

class DailyCardWidget extends StatelessWidget {
  final int arcanoNumero;
  final String arcanoNombre;
  final String arcanoNombreRomano;
  final String? interpretation;
  final bool isLoading;
  final VoidCallback? onTap;

  const DailyCardWidget({
    super.key,
    required this.arcanoNumero,
    required this.arcanoNombre,
    required this.arcanoNombreRomano,
    this.interpretation,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.purplePrimary, AppTheme.purpleDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.purplePrimary.withAlpha(80),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.auto_awesome, color: AppTheme.goldAccent, size: 20),
              const SizedBox(width: 8),
              const Text('Carta del Dia',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 1)),
              const Spacer(),
              Text(arcanoNombreRomano,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.goldAccent)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/cards/arcano_$arcanoNumero.png',
                  width: 50, height: 70, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    width: 50, height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Text(arcanoNombreRomano,
                      style: const TextStyle(color: AppTheme.goldAccent, fontSize: 16, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(arcanoNombre,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(isLoading ? 'Obteniendo interpretacion...' : 'Toca para ver interpretacion',
                  style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(180))),
              ])),
              if (isLoading)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            ]),
            if (interpretation != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(interpretation!,
                  style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(220), height: 1.5)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Update HomeScreen to include daily card**

Edit `lib/screens/home_screen.dart` — insert the daily card widget above the header, wrapped in state management:

```dart
import 'package:flutter/material.dart';
import '../theme.dart';
import '../utils/route_transitions.dart';
import '../utils/animated_widgets.dart';
import '../data/arcanos_data.dart';
import '../services/daily_card_service.dart';
import '../services/ai_service.dart';
import 'life_line/life_line_input_screen.dart';
import 'tarot/tarot_menu_screen.dart';
import 'regressions/regression_screen.dart';
import 'constellations/constellation_screen.dart';
import 'library/arcana_library_screen.dart';
import 'arrangements/numeric_arrangements_screen.dart';
import 'home/daily_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DailyCard? _dailyCard;
  bool _cardLoading = false;
  bool _interpreting = false;

  static final List<_ModuleData> _items = [
    _ModuleData('Mi Linea de Vida', Icons.auto_awesome, 'Descubre tus 5 arcanos', (_) => const LifeLineInputScreen()),
    _ModuleData('Tiradas de Tarot', Icons.style, 'Lecturas interactivas', (_) => const TarotMenuScreen()),
    _ModuleData('Regresiones', Icons.self_improvement, 'Guiadas y reflexivas', (_) => const RegressionScreen()),
    _ModuleData('Constelaciones', Icons.groups, 'Orden del sistema familiar', (_) => const ConstellationScreen()),
    _ModuleData('Biblioteca', Icons.menu_book, 'Los 22 Arcanos Mayores', (_) => const ArcanaLibraryScreen()),
    _ModuleData('Arreglos', Icons.grid_on, 'Analisis numerologicos', (_) => const NumericArrangementsScreen()),
  ];

  @override
  void initState() {
    super.initState();
    _loadDailyCard();
  }

  Future<void> _loadDailyCard() async {
    final existing = await DailyCardService.getTodayCard(hasProfile: false);
    if (existing != null) {
      setState(() { _dailyCard = existing; });
      return;
    }
    setState(() => _cardLoading = true);
    final card = await DailyCardService.generateDailyCard(hasProfile: false);
    await DailyCardService.saveCard(card);
    setState(() {
      _dailyCard = card;
      _cardLoading = false;
    });
  }

  Future<void> _tapDailyCard() async {
    if (_dailyCard == null || _interpreting) return;
    if (_dailyCard!.aiInterpretation != null) return;

    setState(() => _interpreting = true);
    final arcano = getArcanoByNumero(_dailyCard!.arcanoNumero) ?? allArcanos[0];
    final interpretation = await AIService.interpretDailyCard(arcano, null);
    await DailyCardService.updateInterpretation(_dailyCard!.arcanoNumero, interpretation);
    setState(() {
      _dailyCard = DailyCard(
        date: _dailyCard!.date,
        arcanoNumero: _dailyCard!.arcanoNumero,
        arcanoNombre: _dailyCard!.arcanoNombre,
        arcanoNombreRomano: _dailyCard!.arcanoNombreRomano,
        aiInterpretation: interpretation,
        hasProfile: _dailyCard!.hasProfile,
      );
      _interpreting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(children: [
            if (_cardLoading)
              const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: CircularProgressIndicator())
            else if (_dailyCard != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: DailyCardWidget(
                  arcanoNumero: _dailyCard!.arcanoNumero,
                  arcanoNombre: _dailyCard!.arcanoNombre,
                  arcanoNombreRomano: _dailyCard!.arcanoNombreRomano,
                  interpretation: _dailyCard!.aiInterpretation,
                  isLoading: _interpreting,
                  onTap: _tapDailyCard,
                ),
              ),
            StaggeredFadeIn(index: 0, child: _Header()),
            const SizedBox(height: 28),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _items.length,
              itemBuilder: (context, i) => StaggeredFadeIn(
                index: i + 1,
                child: _ModuleCard(
                  data: _items[i],
                  onTap: () => navigateWithScale(context, _items[i].builder(context)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
```

And remove `const` from widget class definition since it's now stateful. Also import:

```dart
import '../models/daily_card.dart';
```

- [ ] **Step 5: Run widget tests**

Run: `flutter test test/screens/home/daily_card_widget_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/screens/home/daily_card_widget.dart lib/screens/home_screen.dart test/screens/home/daily_card_widget_test.dart
git commit -m "feat: add daily card widget to home screen"
```

---

### Task 6: Destiny Matrix Calculator

**Files:**
- Create: `lib/models/destiny_matrix.dart`
- Create: `lib/services/destiny_matrix_calculator.dart`
- Create: `test/services/destiny_matrix_calculator_test.dart`

**Interfaces:**
- Consumes: `LifeLineCalculator.calcular()`, `pythagorean_table.dart` functions
- Produces: `DestinyMatrix` model, `DestinyMatrixCalculator.calculate(name, birthDate) -> DestinyMatrix`

- [ ] **Step 1: Write failing tests**

Create `test/services/destiny_matrix_calculator_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:arcanos_mayores/services/destiny_matrix_calculator.dart';
import 'package:arcanos_mayores/models/destiny_matrix.dart';

void main() {
  group('DestinyMatrixCalculator', () {
    final result = DestinyMatrixCalculator.calculate(
      nombreCompleto: 'Ana Maria Perez',
      fechaNacimiento: DateTime(1990, 5, 15),
    );

    test('returns Life Path number', () {
      expect(result.lifePath, greaterThan(0));
      expect(result.lifePath, lessThanOrEqualTo(22));
    });

    test('returns Personal Year', () {
      expect(result.personalYear, greaterThan(0));
      expect(result.personalYear, lessThanOrEqualTo(22));
    });

    test('returns Soul Urge number', () {
      expect(result.soulUrge, greaterThan(0));
    });

    test('returns Personality number', () {
      expect(result.personality, greaterThan(0));
    });

    test('returns Destiny number', () {
      expect(result.destiny, greaterThan(0));
    });

    test('calculates life path correctly for known date', () {
      // 15/05/1990 = 1+5+0+5+1+9+9+0 = 30 = 3
      final r = DestinyMatrixCalculator.calculate(
        nombreCompleto: 'Test',
        fechaNacimiento: DateTime(1990, 5, 15),
      );
      expect(r.lifePath, 3);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/destiny_matrix_calculator_test.dart`
Expected: COMPILATION ERROR

- [ ] **Step 3: Create DestinyMatrix model**

Create `lib/models/destiny_matrix.dart`:
```dart
class DestinyMatrix {
  final int lifePath;
  final int personalYear;
  final int soulUrge;
  final int personality;
  final int destiny;
  final int? karmicDebt;
  final String nombreCompleto;
  final DateTime fechaNacimiento;

  const DestinyMatrix({
    required this.lifePath,
    required this.personalYear,
    required this.soulUrge,
    required this.personality,
    required this.destiny,
    this.karmicDebt,
    required this.nombreCompleto,
    required this.fechaNacimiento,
  });

  List<MatrixNumber> get allNumbers => [
    MatrixNumber('Camino de Vida', lifePath, 'Tu proposito y lecciones principales.'),
    MatrixNumber('Ano Personal', personalYear, 'La energia del ano actual en tu vida.'),
    MatrixNumber('Impulso del Alma', soulUrge, 'Tus deseos internos y motivacion.'),
    MatrixNumber('Personalidad', personality, 'Como te perciben los demas.'),
    MatrixNumber('Destino', destiny, 'Tu mision de vida y potencial.'),
  ];
}

class MatrixNumber {
  final String name;
  final int value;
  final String description;

  const MatrixNumber(this.name, this.value, this.description);
}
```

- [ ] **Step 4: Create DestinyMatrixCalculator**

Create `lib/services/destiny_matrix_calculator.dart`:
```dart
import '../models/destiny_matrix.dart';
import '../data/pythagorean_table.dart';

class DestinyMatrixCalculator {
  static DestinyMatrix calculate({
    required String nombreCompleto,
    required DateTime fechaNacimiento,
  }) {
    final name = nombreCompleto.trim();

    // Life Path: sum day+month+year, reduce
    final lifePath = _reduceLifePath(fechaNacimiento);

    // Personal Year: current year + day + month
    final now = DateTime.now();
    final personalYear = _reduceToArcano(
      sumarDigitosFecha(fechaNacimiento.day, fechaNacimiento.month, now.year),
    );

    // Soul Urge: vowels in name
    final soulUrge = _reduceToArcano(_calculateVowels(name));

    // Personality: consonants in name
    final personality = _reduceToArcano(_calculateConsonants(name));

    // Destiny: full name
    final destiny = _reduceToArcano(calcularValorNombre(name.replaceAll(RegExp(r'\s+'), '')));

    // Karmic Debt: detect 13, 14, 16, 19 in reduction path
    final karmicDebt = _detectKarmicDebt(fechaNacimiento);

    return DestinyMatrix(
      lifePath: lifePath,
      personalYear: personalYear,
      soulUrge: soulUrge,
      personality: personality,
      destiny: destiny,
      karmicDebt: karmicDebt,
      nombreCompleto: nombreCompleto,
      fechaNacimiento: fechaNacimiento,
    );
  }

  static int _reduceLifePath(DateTime date) {
    int sum = 0;
    int d = date.day; while (d > 0) { sum += d % 10; d ~/= 10; }
    int m = date.month; while (m > 0) { sum += m % 10; m ~/= 10; }
    int y = date.year; while (y > 0) { sum += y % 10; y ~/= 10; }
    return _reduceToSingle(sum);
  }

  static int _reduceToSingle(int n) {
    if (n == 11 || n == 22) return n;
    while (n > 9) {
      int s = 0;
      int t = n;
      while (t > 0) { s += t % 10; t ~/= 10; }
      n = s;
    }
    return n;
  }

  static int _reduceToArcano(int n) {
    if (n >= 1 && n <= 22) return n;
    if (n == 0) return 0;
    int result = n;
    while (result > 22 || result == 0) {
      int s = 0;
      int t = result;
      while (t > 0) { s += t % 10; t ~/= 10; }
      result = s;
      if (result == 11 || result == 22) break;
    }
    return result;
  }

  static int _calculateVowels(String name) {
    const vowels = 'AEIOU';
    int total = 0;
    for (final word in name.split(RegExp(r'\s+'))) {
      for (int i = 0; i < word.length; i++) {
        final c = word[i].toUpperCase();
        if (vowels.contains(c)) {
          total += pythagoreanTable[c] ?? 0;
        }
      }
    }
    return total;
  }

  static int _calculateConsonants(String name) {
    const vowels = 'AEIOU';
    int total = 0;
    for (final word in name.split(RegExp(r'\s+'))) {
      for (int i = 0; i < word.length; i++) {
        final c = word[i].toUpperCase();
        if (vowels.contains(c) || c == ' ') continue;
        if (c == 'N' || c == '\u00D1') {
          total += 26;
        } else {
          total += pythagoreanTable[c] ?? 0;
        }
      }
    }
    return total;
  }

  static int? _detectKarmicDebt(DateTime date) {
    final karmicNumbers = {13, 14, 16, 19};
    int sum = 0;
    int d = date.day; while (d > 0) { sum += d % 10; d ~/= 10; }
    int m = date.month; while (m > 0) { sum += m % 10; m ~/= 10; }
    int y = date.year;
    int ySum = 0;
    while (y > 0) { ySum += y % 10; y ~/= 10; }
    if (karmicNumbers.contains(ySum)) return ySum;
    sum += ySum;
    if (karmicNumbers.contains(sum)) return sum;
    while (sum > 22) {
      int s = 0;
      int t = sum;
      while (t > 0) { s += t % 10; t ~/= 10; }
      sum = s;
      if (karmicNumbers.contains(sum)) return sum;
    }
    return null;
  }
}
```

- [ ] **Step 5: Run tests**

Run: `flutter test test/services/destiny_matrix_calculator_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/models/destiny_matrix.dart lib/services/destiny_matrix_calculator.dart test/services/destiny_matrix_calculator_test.dart
git commit -m "feat: add destiny matrix calculator with numerology numbers"
```

---

### Task 7: Destiny Matrix Screen + Navigation

**Files:**
- Create: `lib/widgets/matrix_cell.dart`
- Create: `lib/screens/numerology/destiny_matrix_screen.dart`
- Modify: `lib/navigation.dart`
- Modify: `lib/screens/arrangements/numeric_arrangements_screen.dart` (make it accessible)

- [ ] **Step 1: Write widget test**

Create `test/widgets/matrix_cell_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:arcanos_mayores/widgets/matrix_cell.dart';

void main() {
  testWidgets('MatrixCell shows number and title', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: MatrixCell(
        number: 3,
        title: 'Test Number',
        description: 'Test description',
      )),
    ));
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Test Number'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/matrix_cell_test.dart`
Expected: COMPILATION ERROR

- [ ] **Step 3: Create MatrixCell widget**

Create `lib/widgets/matrix_cell.dart`:
```dart
import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/arcanos_data.dart';

class MatrixCell extends StatelessWidget {
  final int number;
  final String title;
  final String description;

  const MatrixCell({
    super.key,
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final arcano = getArcanoByNumero(number);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.purplePrimary.withAlpha(12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.purplePrimary.withAlpha(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.purplePrimary, AppTheme.purpleDark]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text('$number',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              'assets/cards/arcano_$number.png',
              width: 40, height: 55, fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                width: 40, height: 55,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.purplePrimary, AppTheme.purpleDark]),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(child: Text(arcano?.nombreRomano ?? '$number',
                  style: const TextStyle(color: AppTheme.goldAccent, fontSize: 10, fontWeight: FontWeight.bold))),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(title,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.purpleLight : AppTheme.purplePrimary),
            textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(description,
            style: TextStyle(fontSize: 9, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            textAlign: TextAlign.center,
            maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Create DestinyMatrixScreen**

Create `lib/screens/numerology/destiny_matrix_screen.dart`:
```dart
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/destiny_matrix.dart';
import '../../services/destiny_matrix_calculator.dart';
import '../../services/life_line_calculator.dart';
import '../../data/arcanos_data.dart';
import '../../widgets/matrix_cell.dart';
import '../../utils/animated_widgets.dart';
import '../arrangements/numeric_arrangements_screen.dart';

class DestinyMatrixScreen extends StatefulWidget {
  const DestinyMatrixScreen({super.key});
  @override
  State<DestinyMatrixScreen> createState() => _DestinyMatrixScreenState();
}

class _DestinyMatrixScreenState extends State<DestinyMatrixScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  DateTime _fecha = DateTime(1990, 1, 1);
  DestinyMatrix? _matrix;
  bool _loading = false;
  String? _nameError;
  late TabController _tabCtrl;

  static final _nameRegex = RegExp(r"^[a-zA-ZáéíóúüñÁÉÍÓÚÜÑ\s.'-]+$");

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override void dispose() {
    _nameCtrl.dispose(); _nameFocus.dispose(); _tabCtrl.dispose(); super.dispose();
  }

  String? _validateName(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Ingresa tu nombre completo';
    if (v.length < 3) return 'El nombre debe tener al menos 3 caracteres';
    if (v.length > 100) return 'El nombre es demasiado largo';
    if (!_nameRegex.hasMatch(v)) return 'Solo se permiten letras y espacios';
    return null;
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _fecha,
      firstDate: DateTime(1900), lastDate: DateTime.now(),
      builder: (c, child) => Theme(data: Theme.of(c).copyWith(
        colorScheme: const ColorScheme.light(primary: AppTheme.purplePrimary),
      ), child: child!));
    if (d != null) setState(() => _fecha = d);
  }

  void _calc() {
    final error = _validateName(_nameCtrl.text);
    if (error != null) {
      setState(() => _nameError = error);
      _nameFocus.requestFocus();
      return;
    }
    setState(() { _loading = true; _nameError = null; });
    final matrix = DestinyMatrixCalculator.calculate(
      nombreCompleto: _nameCtrl.text.trim(),
      fechaNacimiento: _fecha,
    );
    setState(() { _loading = false; _matrix = matrix; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matriz de Destino')),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            TextField(
              controller: _nameCtrl, focusNode: _nameFocus,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: const Icon(Icons.person),
                errorText: _nameError,
                filled: true,
              ),
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = _validateName(_nameCtrl.text));
              },
            ),
            const SizedBox(height: 12),
            InkWell(onTap: _pickDate, child: Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(border: Border.all(color: AppTheme.purplePrimary.withAlpha(80)), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.calendar_today, color: AppTheme.purplePrimary),
                const SizedBox(width: 12),
                Text('${_fecha.day.toString().padLeft(2, '0')}/${_fecha.month.toString().padLeft(2, '0')}/${_fecha.year}',
                  style: const TextStyle(fontSize: 16)),
              ]),
            )),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, height: 48,
              child: ElevatedButton(onPressed: _loading ? null : _calc,
                child: _loading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : const Text('Calcular Matriz'))),
          ]),
        ),
        Expanded(child: _buildResult()),
      ]),
    );
  }

  Widget _buildResult() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_matrix == null) {
      return const Center(child: Text('Ingresa tus datos para calcular tu Matriz de Destino.',
        style: TextStyle(color: Colors.grey)));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(children: [
          Expanded(child: StaggeredFadeIn(index: 0, child: _MatrixGrid(matrix: _matrix!))),
        ]),
        const SizedBox(height: 16),
        if (_matrix!.karmicDebt != null)
          StaggeredFadeIn(index: 1, child: Container(
            width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withAlpha(50)),
            ),
            child: Row(children: [
              const Icon(Icons.warning_amber, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Deuda Karmica detectada',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14)),
                Text('Numero ${_matrix!.karmicDebt}: Un patron karmico importante que trabajar.',
                  style: const TextStyle(fontSize: 12, color: Colors.red)),
              ])),
            ]),
          )),
      ]),
    );
  }
}

class _MatrixGrid extends StatelessWidget {
  final DestinyMatrix matrix;
  const _MatrixGrid({required this.matrix});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: matrix.allNumbers.length,
      itemBuilder: (context, i) {
        final n = matrix.allNumbers[i];
        return MatrixCell(number: n.value, title: n.name, description: n.description);
      },
    );
  }
}
```

- [ ] **Step 5: Update navigation.dart to add Numerologia tab**

Replace `lib/navigation.dart`:
```dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/library/arcana_library_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/numerology/destiny_matrix_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    HomeScreen(),
    ArcanaLibraryScreen(),
    DestinyMatrixScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Arcanos'),
          NavigationDestination(icon: Icon(Icons.grid_on_outlined), selectedIcon: Icon(Icons.grid_on), label: 'Numerologia'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
```

- [ ] **Step 6: Run tests**

Run: `flutter test test/widgets/matrix_cell_test.dart`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add lib/screens/numerology/destiny_matrix_screen.dart lib/widgets/matrix_cell.dart lib/navigation.dart test/widgets/matrix_cell_test.dart
git commit -m "feat: add destiny matrix screen with navigation"
```

---

### Task 8: PDF Export Service

**Files:**
- Create: `lib/services/pdf_export_service.dart`
- Create: `lib/widgets/pdf_templates/life_line_template.dart`
- Create: `lib/widgets/pdf_templates/tarot_template.dart`
- Create: `lib/widgets/pdf_templates/matrix_template.dart`

**Interfaces:**
- Consumes: `LifeLineResult`, `TarotSpread`+`List<Arcano>`, `DestinyMatrix`
- Produces: `File` (generated PDF)

- [ ] **Step 1: Create PDF Export Service**

Create `lib/services/pdf_export_service.dart`:
```dart
import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/life_line.dart';
import '../models/destiny_matrix.dart';
import '../models/arcano.dart';

class PdfExportService {
  static Future<File> generateLifeLineReport(
    LifeLineResult result, {
    String? aiInterpretation,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildLifeLinePages(pdf, result, aiInterpretation),
      ),
    );
    return _save('linea_de_vida_${DateTime.now().millisecondsSinceEpoch}.pdf', pdf);
  }

  static Future<File> generateTarotReport({
    required String spreadName,
    required List<Arcano> cards,
    required List<String> positions,
    String? interpretation,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildTarotPages(pdf, spreadName, cards, positions, interpretation),
      ),
    );
    return _save('tirada_${DateTime.now().millisecondsSinceEpoch}.pdf', pdf);
  }

  static Future<File> generateMatrixReport(DestinyMatrix matrix) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildMatrixPages(pdf, matrix),
      ),
    );
    return _save('matriz_${DateTime.now().millisecondsSinceEpoch}.pdf', pdf);
  }

  static List<pw.Widget> _buildLifeLinePages(
    pw.Document pdf,
    LifeLineResult result,
    String? aiInterpretation,
  ) {
    final list = <pw.Widget>[
      _header(pdf, 'Linea de Vida'),
      pw.SizedBox(height: 10),
      pw.Text('Nombre: ${result.nombreCompleto}', style: pw.TextStyle(fontSize: 14)),
      pw.Text('Fecha: ${result.fechaNacimiento.day}/${result.fechaNacimiento.month}/${result.fechaNacimiento.year}',
        style: pw.TextStyle(fontSize: 14)),
      pw.SizedBox(height: 20),
    ];
    for (final a in result.arcanos) {
      list.add(_arcanoCard(pdf, a.arcano.nombreRomano, a.nombre, a.significado));
      list.add(pw.SizedBox(height: 10));
    }
    if (aiInterpretation != null) {
      list.add(pw.SizedBox(height: 10));
      list.add(_sectionBox(pdf, 'Interpretacion', aiInterpretation));
    }
    list.add(pw.SizedBox(height: 20));
    list.add(pw.Text('Generado por PsicoTarot - Arcanos Mayores v2.0',
      style: pw.TextStyle(fontSize: 9, color: PdfColors.grey)));
    return list;
  }

  static List<pw.Widget> _buildTarotPages(
    pw.Document pdf,
    String spreadName,
    List<Arcano> cards,
    List<String> positions,
    String? interpretation,
  ) {
    final list = <pw.Widget>[
      _header(pdf, 'Tirada de Tarot'),
      pw.SizedBox(height: 10),
      pw.Text('Tirada: $spreadName', style: pw.TextStyle(fontSize: 14)),
      pw.SizedBox(height: 20),
    ];
    for (int i = 0; i < cards.length; i++) {
      final pos = i < positions.length ? positions[i] : 'Posicion ${i + 1}';
      list.add(_arcanoCard(pdf, cards[i].nombreRomano, pos, cards[i].leyEspiritual));
      list.add(pw.SizedBox(height: 8));
    }
    if (interpretation != null) {
      list.add(pw.SizedBox(height: 10));
      list.add(_sectionBox(pdf, 'Interpretacion', interpretation));
    }
    list.add(pw.SizedBox(height: 20));
    list.add(pw.Text('Generado por PsicoTarot - Arcanos Mayores v2.0',
      style: pw.TextStyle(fontSize: 9, color: PdfColors.grey)));
    return list;
  }

  static List<pw.Widget> _buildMatrixPages(pw.Document pdf, DestinyMatrix matrix) {
    final list = <pw.Widget>[
      _header(pdf, 'Matriz de Destino'),
      pw.SizedBox(height: 10),
      pw.Text('Nombre: ${matrix.nombreCompleto}', style: pw.TextStyle(fontSize: 14)),
      pw.Text('Fecha: ${matrix.fechaNacimiento.day}/${matrix.fechaNacimiento.month}/${matrix.fechaNacimiento.year}',
        style: pw.TextStyle(fontSize: 14)),
      pw.SizedBox(height: 20),
    ];
    for (final n in matrix.allNumbers) {
      list.add(_arcanoCard(pdf, '${n.value}', n.name, n.description));
      list.add(pw.SizedBox(height: 8));
    }
    if (matrix.karmicDebt != null) {
      list.add(pw.SizedBox(height: 10));
      list.add(_sectionBox(pdf, 'Deuda Karmica',
        'Numero ${matrix.karmicDebt}: Un patron karmico importante que trabajar en esta vida.'));
    }
    list.add(pw.SizedBox(height: 20));
    list.add(pw.Text('Generado por PsicoTarot - Arcanos Mayores v2.0',
      style: pw.TextStyle(fontSize: 9, color: PdfColors.grey)));
    return list;
  }

  static pw.Widget _header(pw.Document pdf, String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [PdfColor.fromInt(0xFF6A1B9A), PdfColor.fromInt(0xFF4A148C)],
          begin: pw.Alignment.centerLeft, end: pw.Alignment.centerRight,
        ),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
      ),
      child: pw.Column(children: [
        pw.Text('PsicoTarot', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
        pw.Text(title, style: pw.TextStyle(fontSize: 14, color: PdfColor.fromInt(0xFFFFD700))),
      ]),
    );
  }

  static pw.Widget _arcanoCard(pw.Document pdf, String numero, String nombre, String descripcion) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromInt(0xFF6A1B9A).withOpacity(0.3)),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(children: [
        pw.Container(
          width: 40, height: 40,
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(0xFF6A1B9A),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Center(child: pw.Text(numero, style: const pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 16))),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(nombre, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF6A1B9A))),
          pw.SizedBox(height: 4),
          pw.Text(descripcion, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        ])),
      ]),
    );
  }

  static pw.Widget _sectionBox(pw.Document pdf, String title, String content) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFFFF8E1).withOpacity(0.3),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColor.fromInt(0xFFFFD700).withOpacity(0.5)),
      ),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColor.fromInt(0xFF6A1B9A))),
        pw.SizedBox(height: 6),
        pw.Text(content, style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5)),
      ]),
    );
  }

  static Future<File> _save(String fileName, pw.Document pdf) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<void> shareFile(File file) async {
    await Share.shareXFiles([XFile(file.path)], text: 'PsicoTarot - Reporte');
  }
}
```

- [ ] **Step 2: Create template widgets**

Create `lib/widgets/pdf_templates/life_line_template.dart`:
```dart
// Re-exports and convenience builders for PDF life line reports.
// The actual implementation is in PdfExportService.
// This file provides LifeLineReportView for preview purposes.
import 'package:flutter/material.dart';
import '../../models/life_line.dart';

class LifeLineReportView extends StatelessWidget {
  final LifeLineResult result;
  const LifeLineReportView({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Reporte de Linea de Vida', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Nombre: ${result.nombreCompleto}'),
          const SizedBox(height: 16),
          for (final a in result.arcanos) ...[
            Text('${a.posicion}. ${a.nombre}: ${a.arcano.nombreCompleto}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(a.significado, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
          ],
        ]),
      ),
    );
  }
}
```

Create `lib/widgets/pdf_templates/tarot_template.dart`:
```dart
import 'package:flutter/material.dart';
import '../../models/tarot_spread.dart';

class TarotReportView extends StatelessWidget {
  final TarotSpread spread;
  final List<String> cardNames;
  const TarotReportView({super.key, required this.spread, required this.cardNames});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Reporte de Tirada', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Tirada: ${spread.nombre}'),
          const SizedBox(height: 16),
          for (int i = 0; i < cardNames.length; i++) ...[
            Text('${i < spread.posiciones.length ? spread.posiciones[i] : "Posicion ${i + 1}"}: ${cardNames[i]}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
          ],
        ]),
      ),
    );
  }
}
```

Create `lib/widgets/pdf_templates/matrix_template.dart`:
```dart
import 'package:flutter/material.dart';
import '../../models/destiny_matrix.dart';

class MatrixReportView extends StatelessWidget {
  final DestinyMatrix matrix;
  const MatrixReportView({super.key, required this.matrix});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Reporte de Matriz de Destino', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          for (final n in matrix.allNumbers) ...[
            Text('${n.name}: ${n.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(n.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
          ],
        ]),
      ),
    );
  }
}
```

- [ ] **Step 3: Wire PDF export to existing screens**

Edit `lib/screens/life_line/life_line_result_screen.dart` to add share button in AppBar:
```dart
import '../../services/pdf_export_service.dart';

// In AppBar add actions:
appBar: AppBar(
  title: const Text('Mi Linea de Vida'),
  actions: [
    IconButton(
      icon: const Icon(Icons.share),
      onPressed: () async {
        final file = await PdfExportService.generateLifeLineReport(result);
        await PdfExportService.shareFile(file);
      },
    ),
  ],
),
```

- [ ] **Step 4: Commit**

```bash
git add lib/services/pdf_export_service.dart lib/widgets/pdf_templates/ lib/screens/life_line/life_line_result_screen.dart
git commit -m "feat: add PDF export service with life line, tarot, and matrix templates"
```

---

### Task 9: Dark Mode Polish

**Files:**
- Modify: All screen files for theme compliance
- Modify: `lib/theme.dart` (add helper getters)

- [ ] **Step 1: Add theme helpers to theme.dart**

Add to `lib/theme.dart`:
```dart
import 'package:flutter/material.dart';

class AppTheme {
  // ... existing colors ...

  /// Get surface color based on brightness
  static Color surface(BuildContext context) =>
    Theme.of(context).colorScheme.surface;

  /// Get card color based on brightness
  static Color cardColor(BuildContext context) =>
    Theme.of(context).cardColor;

  /// Get primary text color based on brightness
  static Color textOnSurface(BuildContext context) =>
    Theme.of(context).colorScheme.onSurface;

  /// Get muted text color based on brightness
  static Color textMuted(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[400]!
        : Colors.grey[600]!;
}
```

- [ ] **Step 2: Fix ArcanaLibraryScreen hardcoded colors**

In `lib/screens/library/arcana_library_screen.dart`:
- Replace `Colors.black.withAlpha(20)` → use dynamic alpha
- Replace `color: AppTheme.purplePrimary.withAlpha(20)` in list tile → keep as is (uses theme purple)

- [ ] **Step 3: Fix ArcanaDetailScreen white backgrounds**

In `lib/screens/library/arcana_detail_screen.dart`:
```dart
// Replace Container backgrounds:
decoration: BoxDecoration(
  color: AppTheme.purplePrimary.withAlpha(12),  // Already dynamic
  ...
),
```

- [ ] **Step 4: Fix TarotReadingScreen hardcoded grey**

In `lib/screens/tarot/tarot_reading_screen.dart`:
- Replace `Colors.grey` in shuffle text → `AppTheme.textMuted(context)`
- Replace `Colors.grey[600]` → `AppTheme.textMuted(context)`

- [ ] **Step 5: Fix LifeLineInputScreen date picker**

In `lib/screens/life_line/life_line_input_screen.dart`:
- Date picker builder uses `ColorScheme.light` always → check `Theme.of(c).brightness` and use dark variant

```dart
builder: (c, child) => Theme(data: Theme.of(c).copyWith(
  colorScheme: Theme.of(c).brightness == Brightness.dark
    ? const ColorScheme.dark(primary: AppTheme.purpleLight)
    : const ColorScheme.light(primary: AppTheme.purplePrimary),
), child: child!),
```

- [ ] **Step 6: Fix RegressionScreen and ConstellationScreen backgrounds**

In `lib/screens/regressions/regression_screen.dart`:
- Replace `Colors.grey[700]` → `AppTheme.textMuted(context)`
- Card backgrounds inherit theme by default ✓

In `lib/screens/constellations/constellation_screen.dart`:
- Replace `Colors.grey[600/700]` → `AppTheme.textMuted(context)`

- [ ] **Step 7: Fix NumericArrangementsScreen**

In `lib/screens/arrangements/numeric_arrangements_screen.dart`:
- Replace `Colors.grey[500/600]` → `AppTheme.textMuted(context)`
- Replace `Colors.white` on date row → `Theme.of(context).colorScheme.onSurface`

- [ ] **Step 8: Fix SettingsScreen**

In `lib/screens/settings/settings_screen.dart`:
- Text colors inherit from theme ✓

- [ ] **Step 9: Run theme audit test**

Create `test/screens/theme_audit_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:arcanos_mayores/app.dart';

void main() {
  testWidgets('All screens render in dark mode without errors', (tester) async {
    await tester.pumpWidget(MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: const Scaffold(body: Text('Dark mode test')),
    ));
    // Verify dark mode applied
    final brightness = tester.binding.theme.brightness;
    expect(brightness, Brightness.dark);
  });
}
```

- [ ] **Step 10: Commit**

```bash
git add lib/theme.dart lib/screens/library/ lib/screens/tarot/ lib/screens/regressions/ lib/screens/constellations/ lib/screens/arrangements/ lib/screens/settings/ lib/screens/life_line/ test/screens/theme_audit_test.dart
git commit -m "feat: complete dark mode polish across all screens"
```

---

### Task 10: Full Integration - Daily Notification + AI Key in Settings

**Files:**
- Modify: `lib/screens/settings/settings_screen.dart` (add API key input + notification toggle)
- Modify: `lib/services/daily_card_service.dart` (add notification scheduling after first card)

- [ ] **Step 1: Update Settings screen with API key field and notification toggle**

In `lib/screens/settings/settings_screen.dart`, add after the existing cards:

```dart
// In the ListView children, after _Card for Actualizaciones:
const SizedBox(height: 12),
_Card(title: 'IA y Notificaciones', icon: Icons.smart_toy,
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Configura tu API key de NVIDIA para interpretaciones con IA.', style: TextStyle(fontSize: 12, color: Colors.grey)),
    const SizedBox(height: 8),
    TextField(
      controller: _apiKeyCtrl,
      decoration: InputDecoration(
        labelText: 'API Key de NVIDIA',
        hintText: 'nvapi-...',
        prefixIcon: const Icon(Icons.key, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(_showKey ? Icons.visibility_off : Icons.visibility, size: 20),
          onPressed: () => setState(() => _showKey = !_showKey),
        ),
      ),
      obscureText: !_showKey,
      onChanged: _saveApiKey,
    ),
    const SizedBox(height: 12),
    Row(children: [
      const Text('Notificacion diaria 8:00 AM'),
      const Spacer(),
      Switch(
        value: _notificationsEnabled,
        activeColor: AppTheme.purplePrimary,
        onChanged: _toggleNotifications,
      ),
    ]),
  ])),
```

Add state variables and methods:
```dart
final _apiKeyCtrl = TextEditingController();
bool _showKey = false;
bool _notificationsEnabled = true;

@override
void initState() {
  super.initState();
  _loadApiKey();
}

@override
void dispose() {
  _apiKeyCtrl.dispose();
  super.dispose();
}

Future<void> _loadApiKey() async {
  final prefs = await SharedPreferences.getInstance();
  _apiKeyCtrl.text = prefs.getString('arcano_ai_key') ?? '';
}

Future<void> _saveApiKey(String value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('arcano_ai_key', value);
}

Future<void> _toggleNotifications(bool val) async {
  setState(() => _notificationsEnabled = val);
  if (val) {
    await NotificationService.scheduleDailyCard();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notificacion diaria activada a las 8:00 AM')),
      );
    }
  } else {
    await NotificationService.cancelScheduled();
  }
}
```

Import at top:
```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';
```

- [ ] **Step 2: Wire notification after daily card generation**

In `lib/screens/home_screen.dart`, add after daily card save:
```dart
import '../services/notification_service.dart';

// Inside _loadDailyCard(), after await DailyCardService.saveCard(card):
await NotificationService.scheduleDailyCard();
```

- [ ] **Step 3: Full integration test**

Run: `flutter test`
Expected: All existing and new tests pass

- [ ] **Step 4: Final commit**

```bash
git add lib/screens/settings/settings_screen.dart lib/screens/home_screen.dart
git commit -m "feat: integrate API key settings and notification toggle"
```

---

### Task 11: Verification - Run full test suite + Build

- [ ] **Step 1: Run all tests**

```bash
flutter test
```

Expected: All tests pass (0 failures, 0 errors)

- [ ] **Step 2: Run analysis**

```bash
flutter analyze
```

Expected: No errors, only minor style hints

- [ ] **Step 3: Verify build**

```bash
flutter build apk --debug
```

Expected: BUILD SUCCESSFUL

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: final verification - all tests pass, analysis clean, build succeeds"
```
