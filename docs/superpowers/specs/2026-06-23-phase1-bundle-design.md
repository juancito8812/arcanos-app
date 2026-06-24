# Phase 1 Bundle: Daily Card + Destiny Matrix + PDF Export + Dark Polish

> **Spec for PsicoTarot v2.0**

## Overview

Add 4 features to the existing PsicoTarot app:
1. Daily Card of the Day with push notification
2. Destiny Matrix calculator (extended numerology)
3. PDF Export for Life Line / Tarot / Matrix
4. Full dark mode theme polish

**Architecture:** Progressive enhancement of existing code. Daily Card widget on HomeScreen, Destiny Matrix as new bottom-nav tab (replaces "Arreglos"), PDF as share button on result screens, theme audit across all screens.

**AI Integration:** NVIDIA Nemotron 3 Ultra via free API for daily card interpretation and tarot spread readings.

---

## Feature 1: Daily Card + Push Notifications

### Behavior
- If user has a saved profile: daily card = the current Life Line Arcano based on user's age:
  - 0-10 años → Arcano 1 (YO)
  - 10-20 años → Arcano 2 (ELLO)
  - 20-30 años → Arcano 3 (MENTE)
  - 30-40 años → Arcano 4 (REALIZACION)
  - 40+ años → Arcano 5 (SINTESIS)
- If no profile: random Major Arcana card (shuffled once per day)
- Card shown at top of HomeScreen as a compact card widget
- Tap to expand with full AI interpretation (from NVIDIA API)
- Notification at 8:00 AM local time, opens app to daily card
- Only one card per day (stored locally with date)
- If API key missing: show card without AI interpretation (static description only)

### Data Model
```dart
class DailyCard {
  final DateTime date;
  final Arcano arcano;
  final String? aiInterpretation;
  final bool hasProfile; // true if tied to Life Line
}
```

### Files
- `lib/models/daily_card.dart` (NEW)
- `lib/services/daily_card_service.dart` (NEW)
- `lib/services/notification_service.dart` (NEW)
- `lib/services/ai_service.dart` (NEW)
- `lib/screens/home/daily_card_widget.dart` (NEW)

### Database
- New table `daily_cards`: `id, date TEXT, arcano_numero INT, ai_interpretacion TEXT, tiene_perfil INT, fecha_creacion TEXT`

### Dependencies
- `flutter_local_notifications` (push)
- `flutter_native_timezone` (timezone detection)
- `http` (for NVIDIA API calls)

---

## Feature 2: Destiny Matrix Calculator

### Calculations
Extends current Pythagorean numerology:

| Number | Source | Method |
|--------|--------|--------|
| **Life Path** | Birth date | Sum day+month+year, reduce to 1-9 (existing) |
| **Personal Year** | Today | Day+month+current_year → reduce 1-22, map to Arcano |
| **Soul Urge** | Vowels in name | Pythagorean table → sum → reduce |
| **Personality** | Consonants in name | Pythagorean table → sum → reduce |
| **Destiny** | Full name | Pythagorean table → sum → reduce |
| **Karmic Debt** | Birth date | Detect 13, 14, 16, 19 during reduction |

### Visual Layout
Grid/matrix showing 6 numbers with their Arcano cards arranged in a visual mandala pattern. Each cell shows: number, arcano name, short interpretation, card thumbnail.

### Files
- `lib/models/destiny_matrix.dart` (NEW)
- `lib/services/destiny_matrix_calculator.dart` (NEW)
- `lib/screens/numerology/destiny_matrix_screen.dart` (NEW)
- `lib/widgets/matrix_cell.dart` (NEW)

### Navigation
- Add "Numerología" as 4th bottom-nav tab (after Ajustes)
- Keep "Arreglos" accessible inside Numerología tab as first section
- "Arreglos" stays in existing code, not moved from its file

---

## Feature 3: PDF Export

### Reports to generate
1. **Life Line Report**: Header (name, date), 5 Arcano cards with descriptions, interpretation
2. **Tarot Reading Report**: Spread name, date, each card with position + interpretation
3. **Destiny Matrix Report**: Full matrix grid, each number explained

### Layout
- Letter/ A4 page size
- PsicoTarot branding: purple/gold gradient header, app icon
- Card images embedded (Arcano card PNGs)
- Footer: "Generado por PsicoTarot - Arcanos Mayores v2.0"

### Files
- `lib/services/pdf_export_service.dart` (NEW)
- `lib/widgets/pdf_templates/life_line_template.dart` (NEW)
- `lib/widgets/pdf_templates/tarot_template.dart` (NEW)
- `lib/widgets/pdf_templates/matrix_template.dart` (NEW)

### Dependencies
- `pdf` (generation)
- `share_plus` (sharing)
- `path_provider` (temp storage, already in pubspec)

---

## Feature 4: Dark Mode Polish

### Audit checklist (all screens)
- `HomeScreen`: header, module cards, text colors
- `ArcanaLibraryScreen`: card backgrounds, search bar
- `ArcanaDetailScreen`: info section backgrounds, chips
- `TarotReadingScreen`: shuffle state, card backgrounds, text
- `LifeLineInputScreen`: date picker theme, input fields
- `LifeLineResultScreen`: result cards, text colors
- `RegressionScreen`: type selector cards, step cards
- `ConstellationScreen`: tab chips, wheel cards, info sections
- `SettingsScreen`: section cards, text
- `NumericArrangementsScreen`: result cards, backgrounds

### Fix approach
- Replace `Colors.white` with `Theme.of(context).colorScheme.surface`
- Replace `Colors.grey[500/600/700]` with `Theme.of(context).colorScheme.onSurfaceVariant` or `AppTheme.textLight / textDark`
- All cards: use `Theme.of(context).cardColor` instead of hardcoded white
- All `Container(color: AppTheme.purplePrimary.withAlpha(12))` → check with Alpha on dark background (use `AppTheme.darkCard` instead)

---

## AI Service (NVIDIA API)

### Endpoint
```
POST https://integrate.api.nvidia.com/v1/chat/completions
Authorization: Bearer $API_KEY
Content-Type: application/json

{
  "model": "nvidia/nemotron-3-ultra",
  "messages": [
    {"role": "system", "content": "Eres un terapeuta de PsicoTarot experto en Arcanos Mayores, numerología pitagórica y constelaciones familiares. Respondes en español, tono empático, psicológico y empoderante. Máximo 150 palabras."},
    {"role": "user", "content": "..."}
  ],
  "temperature": 0.7,
  "max_tokens": 300
}
```

### Prompts
```
1. DAILY_CARD: "Hoy te ha tocado el arcano [NOMBRE] (No.[NUMERO]). 
   Tu línea de vida indica que estás en el período [PERIODO]. 
   Interpreta cómo la energía de este arcano se manifiesta 
   en esta etapa de tu vida. Da una reflexión práctica y 
   una afirmación."

2. TAROT_SPREAD: "Tirada de [NOMBRE_TIRADA]. Posiciones:
   [POS1]: [CARTA1]
   [POS2]: [CARTA2]
   ...
   Interpreta la tirada de forma coherente, conectando las 
   cartas entre sí. Da un mensaje integrador."
```

### API Key Configuration
- Read from `--dart-define=ARCANO_AI_KEY=xxx` at build time
- Fallback to empty string if not defined (AI features disabled gracefully)
- User can enter their own NVIDIA API key in Settings screen (stored in SharedPreferences)
- Runtime key overrides build-time key (for user-provided keys)
- If neither key is available, AI interpretation shows fallback text: "Conectate a internet y configura tu API key en Ajustes para obtener una interpretacion personalizada."

---

## Navigation Updates

### Bottom Nav (navigation.dart)
```
Before: [Inicio] [Arcanos] [Ajustes]
After:  [Inicio] [Arcanos] [Numerología] [Ajustes]
```
- Move "Arreglos Numericos" inside Numerología tab
- "Mi Línea de Vida" stays in HomeScreen

---

## Dependencies (pubspec.yaml additions)

```yaml
dependencies:
  flutter_local_notifications: ^18.0.0
  flutter_native_timezone: ^2.0.0
  http: ^1.2.0
  pdf: ^3.11.0
  share_plus: ^10.1.0
```

---

## Success Criteria

1. Daily card appears on HomeScreen and changes daily
2. Push notification fires at scheduled time
3. Destiny Matrix shows 6 numbers with card meanings
4. PDF exports generate valid files and share action works
5. All screens display correctly in dark mode
6. AI interpretation loads from NVIDIA API with loading state
7. No existing functionality broken

---

## Non-Goals (v2 scope)

- Custom notifications time (v2)
- Multiple AI models (v2)
- Cloud sync (v2)
- Monetization (v2)
- Apple Watch/iOS widgets (v2)
- Multiple tarot decks (v2)
