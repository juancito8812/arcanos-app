# Skills — PsicoTarot Arcanos Mayores

Skills reutilizables para Codebuff/Freebuff que extienden las capacidades del agente de IA en este proyecto.

## 📦 Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/juancito8812/arcanos-app.git
cd arcanos-app
```

### 2. Skills sin dependencias externas

Las siguientes skills solo requieren que el agente lea el archivo `SKILL.md`:

| Skill | Descripción |
|-------|-------------|
| [auto-sync](./auto-sync/) | Auto-commit y push después de cambios + actualización de AI_HANDOFF.md |
| [changelog-generator](./changelog-generator/) | Genera changelogs descriptivos a partir del historial de commits |
| [error-handling-patterns](./error-handling-patterns/) | Patrones de manejo de errores en múltiples lenguajes |
| [frontend-design](./frontend-design/) | Guía de diseño visual distintivo para interfaces |
| [interface-design](./interface-design/) | Diseño de interfaces con jerarquía, tokens y componentes |
| [postgresql-table-design](./postgresql-table-design/) | Diseño de esquemas PostgreSQL con buenas prácticas |
| [vercel-react-best-practices](./vercel-react-best-practices/) | Optimización de rendimiento en React/Next.js |

No requieren instalación adicional. El agente las carga automáticamente con `@nombre-de-la-skill`.

### 3. Skills con dependencias Python

#### image-to-ai

Convierte imágenes locales a formatos que los modelos de IA pueden procesar (Base64, Tensor, OCR).

```bash
# Instalar dependencias Python
pip install -r skills/image-to-ai/requirements.txt

# Instalar Tesseract OCR (necesario solo para modo text)
# Windows: https://github.com/UB-Mannheim/tesseract/wiki
# macOS: brew install tesseract
# Linux: sudo apt install tesseract-ocr tesseract-ocr-spa
```

**Uso:**

```bash
python skills/image-to-ai/scripts/converter.py ./captura.png --mode base64
python skills/image-to-ai/scripts/converter.py ./captura.png --mode tensor --as-tensor
python skills/image-to-ai/scripts/converter.py ./captura.png --mode text --lang spa
```

## 🚀 Cómo usar una skill

### Desde Codebuff/Freebuff

Durante una conversación con el agente, invoca la skill por nombre:

```
@auto-sync
@image-to-ai
@error-handling-patterns
```

El agente leerá el archivo `SKILL.md` correspondiente y seguirá sus instrucciones.

### Desde el CLI

Algunas skills incluyen scripts ejecutables directamente:

```bash
# image-to-ai
python skills/image-to-ai/scripts/converter.py --help
```

## 📁 Estructura

```
skills/
├── README.md                       # Este archivo
├── auto-sync/                      # Auto-commit + push
│   └── SKILL.md
├── changelog-generator/            # Changelogs automáticos
│   └── SKILL.md
├── error-handling-patterns/        # Patrones de errores
│   └── SKILL.md
├── frontend-design/                # Diseño visual
│   └── SKILL.md
├── image-to-ai/                    # Conversión de imágenes a IA
│   ├── SKILL.md
│   ├── requirements.txt
│   └── scripts/
│       └── converter.py
├── interface-design/               # Diseño de interfaces
│   └── SKILL.md
├── postgresql-table-design/        # Esquemas PostgreSQL
│   └── SKILL.md
└── vercel-react-best-practices/    # Optimización React/Next.js
    └── SKILL.md
```

## ✨ Crear una nueva skill

1. Crea una carpeta en `skills/` con el nombre de la skill
2. Agrega un archivo `SKILL.md` siguiendo el formato de las existentes
3. Si requiere código, agrega una carpeta `scripts/` con los archivos necesarios
4. Agrega `requirements.txt` si tiene dependencias externas
5. Actualiza este `README.md` con la nueva skill
