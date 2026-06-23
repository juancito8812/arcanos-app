---
name: auto-sync
description: Después de completar cambios en el proyecto arcanos-app, automatiza git commit, push y actualización de AI_HANDOFF.md para mantener el repo sincronizado.
version: "1.0.0"
metadata:
  author: juancito8812
  project: arcanos-app
---

# Auto-Sync

## Checklist

- [ ] `flutter analyze` pasa sin errores
- [ ] AI_HANDOFF.md actualizado con los cambios realizados
- [ ] En la rama correcta (master a menos que se especifique otra)
- [ ] Sin cambios experimentales sin commitear
- [ ] Mensaje de commit sigue el formato convencional

## Workflow

Ejecutar desde la raíz del proyecto (`arcanos-app`):

### 1. Verificar análisis

```bash
flutter analyze
```

### 2. Actualizar AI_HANDOFF.md

Agregar o actualizar la sección "Últimos cambios" con:
- Qué cambió (feature, bug fix, refactor)
- Archivos modificados
- Resultado de `flutter analyze`

### 3. Commit y push

```bash
git add -A
git commit -m "tipo: descripción concisa del cambio"
git push
```

## Template para AI_HANDOFF.md

```
## feature: [nombre]

| Archivo | Cambio |
|---------|--------|
| `ruta/al/archivo.dart` | qué se hizo |

`flutter analyze` — 0 issues ✅
```

## Cuándo NO hacer auto-sync

- Cambios exploratorios no listos para commit
- Cambios que rompen `flutter analyze` (corregir primero)
- Ramas experimentales que aún no se han pusheado

## Criterios de salida

- [ ] Código commiteado con mensaje descriptivo
- [ ] AI_HANDOFF.md refleja el estado actual
- [ ] `flutter analyze` — 0 issues
- [ ] Push confirmado exitosamente
