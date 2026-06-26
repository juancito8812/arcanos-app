# Revisión de Código — PsicoTarot App

**Fecha:** 26/06/2026
**Versión:** 2.2.1+6

---

## 1. TECNOLOGÍAS Y ENTORNO

- **Lenguaje principal:** Dart 3.7+
- **Framework:** Flutter 3.27+
- **Base de datos:** SQLite (sqflite), SharedPreferences, flutter_secure_storage
- **Servicios externos:** API de IA configurable por usuario (OpenAI, Anthropic, Google, Ollama, Groq, etc.), GitHub Releases (actualización in-app)
- **Estado:** Provider (ChangeNotifierProvider)

## 2. ESTRUCTURA DEL PROYECTO

- **Tipo de app:** Móvil Android
- **Organización de carpetas:**

```
lib/
├── main.dart                   # Entry point, providers
├── app.dart                    # MaterialApp con themeFor(palette, mode)
├── navigation.dart             # Bottom nav (Inicio, Matriz, Arcanos, Ajustes)
├── theme.dart                  # AppTheme con 5 paletas + generador themeFor()
├── data/
│   ├── arcanos_data.dart       # 22 Arcanos Mayores (datos completos)
│   ├── arcanos_menores_data.dart # 56 Arcanos Menores
│   ├── pythagorean_table.dart  # Tabla pitagórica + reducción teosófica
│   └── spreads_data.dart       # Definiciones de tiradas de tarot
├── models/
│   ├── arcano.dart             # Arcano (22 campos)
│   ├── arcano_menor.dart       # ArcanoMenor (7 campos)
│   ├── life_line.dart          # LifeLineResult + ArcanoPosicion
│   ├── destiny_matrix.dart     # DestinyMatrix + DestinyPosition
│   ├── daily_card.dart         # DailyCard
│   ├── tarot_spread.dart       # TarotSpread
│   └── family_member.dart      # FamilyMember
├── services/
│   ├── life_line_calculator.dart    # Cálculo 5 posiciones
│   ├── destiny_matrix_calculator.dart # 8 posiciones
│   ├── daily_card_service.dart      # Carta diaria
│   ├── ai_service.dart              # API de IA genérica
│   ├── database_service.dart        # SQLite (4 tablas)
│   ├── update_service.dart          # Actualización in-app
│   ├── theme_provider.dart          # Provider tema + paleta
│   ├── notification_service.dart    # Notificaciones diarias
│   └── pdf_export_service.dart      # Exportar a PDF
├── screens/
│   ├── home_screen.dart             # Grid 6 módulos + update check
│   ├── splash_screen.dart           # Splash
│   ├── settings/settings_screen.dart # Configuración completa
│   ├── life_line/                    # Input + Result + Detail
│   ├── tarot/                        # Menu + Reading
│   ├── library/                      # Mayores + Menores + Detail
│   ├── numerology/destiny_matrix_screen.dart
│   ├── constellations/constellation_screen.dart
│   ├── regressions/regression_screen.dart
│   └── arrangements/numeric_arrangements_screen.dart
├── widgets/
│   └── daily_card_banner.dart
└── utils/
    ├── route_transitions.dart
    └── animated_widgets.dart
```

## 3. DESCRIPCIÓN DE LA APP

### Funcionalidades principales

1. **Línea de Vida** — Calcula 5 arcanos (YO, ELLO, MENTE, REALIZACIÓN, SÍNTESIS) a partir de nombre + fecha. Tabla pitagórica estándar + reducción teosófica. Mapeo 22→0 (El Loco). Guarda perfiles en SQLite.

2. **Tiradas de Tarot** — Selección de tipo de tirada (3 cartas, cruz celta, etc.), muestra cartas con imágenes Marseille, interpretación por IA.

3. **Regresiones** — Ejercicios guiados de regresión con notas.

4. **Constelaciones Familiares** — Órdenes del sistema familiar con rueda de palabras y visualización.

5. **Arreglos Numéricos** — Análisis numerológicos con historial de últimos 10 cálculos.

6. **Matriz del Destino** — 8 posiciones con imágenes de arcanos.

7. **Carta del Día** — Aleatoria o basada en perfil. Interpretación por IA.

8. **Biblioteca de Arcanos** — 22 Mayores + 56 Menores con búsqueda y detalle.

9. **Actualización in-app** — Detecta nueva versión en GitHub, descarga APK con progreso, abre instalador.

## 4. MODELOS DE DATOS

### Arcano (arcano.dart) — 17 campos
id, numero, nombre, nombreRomano, leyEspiritual, leccionVida, miedoAsociado, descripcionGeneral, arquetipo, elemento, polaridad, valorNuclear, desafio, significadoPosicion, perspectivaTransgeneracional, colorAsociado, nivel, afirmacionSanadora

### ArcanoMenor (arcano_menor.dart) — 7 campos
id, nombre, palo, rango, numero, elemento, significado
Incluye getter `imagenNumero` con corrección Sota↔Caballo

### LifeLine (life_line.dart)
ArcanoPosicion (posicion, nombre, arcano, edadPeriodo, significado)
LifeLineResult (5 posiciones + nombre + fecha)

### DestinyMatrix (destiny_matrix.dart)
8 posiciones: day, month, year, essence, talent, challenge1, challenge2, purpose

## 5. SERVICIOS CLAVE

### life_line_calculator.dart
```
A1 = reducciónTeosófica(sumaPitagórica(nombreCompleto))
A2 = sumarDigitosFecha(día, mes, año)
A3 = reducirADigitoÚnico(A2, respetando 11/22)
A4 = reducciónTeosófica(A1 + A3)
A5 = reducciónTeosófica(A1 + A2 + A3 + A4)
```

### pythagorean_table.dart
- Tabla pitagórica estándar: A=1, B=2, ..., I=9, J=1, ... Z=8, Ñ=5
- reduccionTeosofica(): reduce a 1-22, respeta 11/22, mapea 22→0
- sumarDigitosFecha(): suma dígitos + reducción

### ai_service.dart
- getApiKey(): flutter_secure_storage con fallback SharedPreferences
- getBaseUrl(), getModel(): SharedPreferences
- interpretDailyCard(), interpretTarotSpread(): POST a API OpenAI-compatible

### update_service.dart
- checkForUpdate(): GET GitHub releases latest, compara versión
- downloadApk(): dio con callback de progreso
- installApk(): OpenFilex para lanzar instalador Android

## 6. ESTADO ACTUAL

### ✅ Implementado
- Línea de Vida completa (5 posiciones, pitagórica estándar)
- Tiradas de Tarot con spreads + interpretación IA
- Constelaciones Familiares (14 posiciones + rueda)
- Regresiones guiadas
- Arreglos Numéricos con historial DB
- Carta del día con/sin perfil + IA
- Biblioteca 78 arcanos con búsqueda
- Actualización in-app desde GitHub
- 5 paletas de color configurables
- API de IA genérica
- Temas claro/oscuro
- Notificaciones diarias
- Seguridad: flutter_secure_storage, network_security_config, ProGuard, keystore, allowBackup=false

### 🔧 Pendientes
- Tests unitarios
- CI/CD pipeline
- Soporte iOS
- Traducción multi-idioma
- Refactorización de constellation_screen.dart (~1200 líneas)

## 7. CONFIGURACIÓN

- compileSdk: flutter.compileSdkVersion
- minSdk: 21
- Permisos: INTERNET, REQUEST_INSTALL_PACKAGES
- Firma: upload-keystore.jks (gitignored)
- Ofuscación: R8 con proguard-rules.pro
- Assets: 78 cartas Marseille en assets/cards/

## 8. REPOSITORIO

https://github.com/juancito8812/arcanos-app
Rama: master
Tags: v2.2.1 (último)
