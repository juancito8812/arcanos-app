# Life Line Detail Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a detail screen for each Life Line position showing the arcano card image, name, and extended explanation.

**Architecture:** Single new screen navigated to from the existing `life_line_result_screen.dart`. The existing `_PosCard` widget gets an `onTap` handler. No new models or services needed — all data already exists in `Arcano` and `ArcanoPosicion`.

**Tech Stack:** Flutter, existing theme, existing navigation utilities.

## Global Constraints

- Spanish text throughout
- No new dependencies
- Images from `assets/cards/arcano_{numero}.png`
- Use `navigateWithScale` for transition (existing pattern)

---

### Task 1: Create LifeLineDetailScreen

**Files:**
- Create: `lib/screens/life_line/life_line_detail_screen.dart`
- Test: `test/screens/life_line_detail_screen_test.dart`

**Interfaces:**
- Consumes: `ArcanoPosicion` (from `lib/models/life_line.dart`), `Arcano` (from `lib/models/arcano.dart`), `getArcanoByNumero` (from `lib/data/arcanos_data.dart`)
- Produces: `LifeLineDetailScreen` widget (takes `ArcanoPosicion pos`)

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arcanos_mayores/models/life_line.dart';
import 'package:arcanos_mayores/screens/life_line/life_line_detail_screen.dart';

Widget _buildApp(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  testWidgets('LifeLineDetailScreen renders arcano name', (tester) async {
    final pos = ArcanoPosicion(
      posicion: 1,
      nombre: 'YO - Personalidad',
      arcano: ArcanoInfo(numero: 1, nombre: 'El Mago', nombreRomano: 'I'),
      edadPeriodo: '0 a 10 anos',
      significado: 'Representa tu personalidad consciente.',
    );
    await tester.pumpWidget(_buildApp(LifeLineDetailScreen(pos: pos)));
    expect(find.text('El Mago'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `$p test test/screens/life_line_detail_screen_test.dart`
Expected: FAIL with "LifeLineDetailScreen not found"

- [ ] **Step 3: Write minimal implementation**

```dart
import 'package:flutter/material.dart';
import 'package:arcanos_mayores/theme.dart';
import 'package:arcanos_mayores/models/life_line.dart';
import 'package:arcanos_mayores/data/arcanos_data.dart';

class LifeLineDetailScreen extends StatelessWidget {
  final ArcanoPosicion pos;
  const LifeLineDetailScreen({super.key, required this.pos});

  @override
  Widget build(BuildContext context) {
    final arcano = getArcanoByNumero(pos.arcano.numero);
    return Scaffold(
      appBar: AppBar(title: Text(pos.arcano.nombre)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Card image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/cards/arcano_${pos.arcano.numero}.png',
              width: 200, height: 290, fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                width: 200, height: 290,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.purplePrimary, AppTheme.purpleDark]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Text(pos.arcano.nombreRomano,
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.goldAccent))),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Name
          Text('${pos.arcano.nombreRomano} — ${pos.arcano.nombre}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary),
            textAlign: TextAlign.center),
          const SizedBox(height: 8),
          // Position context
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.goldAccent.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${pos.nombre} (${pos.edadPeriodo})',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.goldAccent)),
          ),
          const SizedBox(height: 24),
          // Explanation sections
          if (arcano != null) ...[
            _Section(title: 'Ley Espiritual', body: arcano.leyEspiritual),
            _Section(title: 'Leccion de Vida', body: arcano.leccionVida),
            _Section(title: 'Arquetipo', body: '${arcano.arquetipo} | ${arcano.elemento} | ${arcano.polaridad}'),
            _Section(title: 'Desafio', body: arcano.miedoAsociado),
          ],
          _Section(title: 'Significado en esta posicion', body: pos.significado),
        ]),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title.toUpperCase(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.goldAccent, letterSpacing: 1)),
        const SizedBox(height: 6),
        Text(body, style: TextStyle(fontSize: 15, height: 1.5, color: Theme.of(context).colorScheme.onSurface)),
      ]),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `$p test test/screens/life_line_detail_screen_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/screens/life_line/life_line_detail_screen.dart test/screens/life_line_detail_screen_test.dart
git commit -m "feat: add life line position detail screen"
```

---

### Task 2: Add navigation from LifeLineResultScreen

**Files:**
- Modify: `lib/screens/life_line/life_line_result_screen.dart`
- Add import for `life_line_detail_screen.dart` and `route_transitions.dart`

- [ ] **Step 1: Add onTap to _PosCard**

En `_PosCard`, agregar `onTap` callback y envolver el contenido en `GestureDetector` o `InkWell`. Agregar import de `route_transitions.dart` y del `LifeLineDetailScreen`.

Cambiar `_PosCard` de `StatelessWidget` a que reciba un `onTap` callback, o directamente que `build` envuelva en `GestureDetector`.

```dart
// Al inicio del archivo agregar imports:
import '../utils/route_transitions.dart';
import 'life_line_detail_screen.dart';

// En _PosCard.build, wrap the existing Card content:
child: Card(
  ...
  child: InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: () => navigateWithScale(
      context,
      LifeLineDetailScreen(pos: pos),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [ /* existing content */ ]),
    ),
  ),
),
```

- [ ] **Step 2: Run analyzer to verify compilation**

Run: `$p analyze lib/screens/life_line/`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/screens/life_line/life_line_result_screen.dart
git commit -m "feat: add navigation from life line result to position detail"
```
