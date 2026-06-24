# Life Line — Pantalla de Detalle por Posición

## Resumen

Agregar una pantalla de detalle a la que se navega al tocar cualquiera de las 5 posiciones (Yo, Ello, Mente, Realización, Síntesis) en la pantalla de resultado de Línea de Vida.

## Cambios Requeridos

### 1. Nueva pantalla: `lib/screens/life_line/life_line_detail_screen.dart`

- Recibe: `ArcanoPosicion` (posición tocada) y `Arcano` completo (para acceder a todos los campos)
- Muestra:
  - Imagen del arcano (centrada, aprox 200x290 o similar proporcionado)
  - Nombre completo del arcano (ej. "I — El Mago")
  - Contexto: nombre de la posición + rango de edad
  - Explicación extensa dividida en secciones:
    - **Ley Espiritual**: texto de `leyEspiritual`
    - **Lección de Vida**: texto de `leccionVida`
    - **Arquetipo**: `arquetipo` + `elemento` + `polaridad`
    - **Desafío**: `miedoAsociado`
    - **Significado en esta posición**: texto de `significado` del `ArcanoPosicion`

### 2. Modificar: `lib/screens/life_line/life_line_result_screen.dart`

- La tarjeta `_PosCard` existente se mantiene igual pero se hace `InkWell` / `GestureDetector` para navegar al detalle
- No se pierde contenido actual — solo se agrega `onTap` con `navigateWithScale`

## Flujo

LifeLineResultScreen → tap en posición → LifeLineDetailScreen (con transición scale)

## Archivos Afectados

| Archivo | Acción |
|---------|--------|
| `lib/screens/life_line/life_line_detail_screen.dart` | CREAR |
| `lib/screens/life_line/life_line_result_screen.dart` | MODIFICAR (agregar onTap + navegación) |

## No Incluye

- No se modifica el cálculo de la línea de vida
- No se modifica la data de arcanos
- No se agregan nuevas dependencias
- No se tocan otras pantallas
