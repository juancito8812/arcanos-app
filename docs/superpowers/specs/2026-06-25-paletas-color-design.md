# Paletas de Color — PsicoTarot

## Resumen
Agregar 5 paletas de color seleccionables (Púrpura, Azul, Verde, Rojo, Ámbar) que se combinan con el modo claro/oscuro existente.

## Paletas

| Paleta   | Semilla   | Fondo claro | Fondo oscuro |
|----------|-----------|-------------|--------------|
| Púrpura  | `#6A1B9A` | `#FDF5E6`   | `#1C0A2E`    |
| Azul     | `#1565C0` | `#E3F2FD`   | `#0D1B2A`    |
| Verde    | `#2E7D32` | `#E8F5E9`   | `#0A1F0E`    |
| Rojo     | `#C62828` | `#FFEBEE`   | `#2A0D0D`    |
| Ámbar    | `#FF8F00` | `#FFF8E1`   | `#2A1F0D`    |

El acento dorado (`#FFD700`) y el dorado claro (`#FFF8E1`) se mantienen fijos en todas las paletas.

## Arquitectura

### AppTheme (`lib/theme.dart`)
- Se convierte en generador: `AppTheme.themeFor(paleta, mode)` → `ThemeData`
- Usa `ColorScheme.fromSeed(seedColor, brightness)` para cada paleta
- Overrides manuales: scaffoldBackgroundColor, navigationBar, goldAccent

### ThemeProvider (`lib/services/theme_provider.dart`)
- Nuevo campo: `String _palette` (default: `'purple'`)
- Nuevos métodos: `setPalette()`, getter `palette`
- Persiste en SharedPreferences clave `selected_palette`

### SettingsScreen
- Card "Apariencia" se divide en dos secciones:
  1. Selector de modo (existente)
  2. Selector de paleta (nuevo): 5 círculos de color en fila horizontal
- Al tocar un círculo → `ThemeProvider.setPalette()` → rebuild inmediato

## Componentes UI

### Selector de paleta
```dart
Row de 5 CircleAvatar con color de la paleta
  - Borde dorado + icono check en el seleccionado
  - onTap: provider.setPalette(id)
```

### Datos
- `ThemeProvider` expone `palette` y `setPalette(String)` 
- SharedPreferences: `selected_palette` → `'purple'|'blue'|'green'|'red'|'amber'`

## Archivos a modificar
1. `lib/theme.dart` — refactor a generador por paleta
2. `lib/services/theme_provider.dart` — agregar paleta
3. `lib/screens/settings/settings_screen.dart` — agregar selector visual
4. `lib/main.dart` — pasar paleta al AppTheme (si aplica)

## No entra en scope
- Paletas personalizadas por RGB
- Temas descargables
- Temas estacionales automáticos
