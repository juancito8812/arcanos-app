---
name: image-to-ai
description: Convierte imágenes locales a formatos que los modelos de IA pueden procesar: Base64 (multimodal), Tensor (NumPy/PyTorch) o texto extraído por OCR.
version: "1.0.0"
author: juancito8812
---

# Image-to-AI

Skill para convertir una imagen local en tres formatos distintos según las necesidades del modelo de IA que uses.

## Requisitos

- Python 3.8+
- Tesseract OCR instalado en el sistema
- Dependencias Python (ver `requirements.txt`)

## Instalación de dependencias

```bash
pip install -r skills/image-to-ai/requirements.txt
```

### Tesseract OCR

- **Windows:** Descargar e instalar desde https://github.com/UB-Mannheim/tesseract/wiki
- **macOS:** `brew install tesseract`
- **Linux:** `sudo apt install tesseract-ocr tesseract-ocr-spa`

## Modos de salida

### 1. `base64` — Para modelos multimodales (GPT-4V, Claude, Gemini)

Codifica la imagen en una cadena Base64 lista para enviar en APIs de modelos de visión.

```python
from skills.image_to_ai.scripts.converter import image_to_base64

b64 = image_to_base64("./captura.png")
print(b64)  # data:image/png;base64,iVBORw0KGgo...
```

**Uso desde el agente:** Pídele al agente que ejecute `python -c "from skills.image_to_ai.scripts.converter import image_to_base64; print(image_to_base64('./ruta/a/imagen.png'))"`

### 2. `tensor` — Para modelos de machine learning (PyTorch, TensorFlow)

Convierte la imagen a un array NumPy con forma `(alto, ancho, canales)`. Normaliza los valores a [0, 1] para PyTorch.

```python
from skills.image_to_ai.scripts.converter import image_to_tensor

# NumPy array: (H, W, C), valores 0-255
np_array = image_to_tensor("./captura.png", as_tensor=False)

# Tensor normalizado: (C, H, W), valores 0.0-1.0 (listo para PyTorch)
torch_tensor = image_to_tensor("./captura.png", as_tensor=True)
```

### 3. `text` — OCR (Tesseract)

Extrae todo el texto visible en la imagen usando OCR.

```python
from skills.image_to_ai.scripts.converter import image_to_text

texto = image_to_text("./captura.png", lang="spa")  # "spa" para español
print(texto)
```

## Uso desde CLI

```bash
# Base64
python -m skills.image_to_ai.scripts.converter ./captura.png --mode base64

# Tensor NumPy
python -m skills.image_to_ai.scripts.converter ./captura.png --mode tensor

# Tensor PyTorch
python -m skills.image_to_ai.scripts.converter ./captura.png --mode tensor --as-tensor

# OCR en español
python -m skills.image_to_ai.scripts.converter ./captura.png --mode text --lang spa
```

## Integración con Codebuff/Freebuff

Cuando un agente de IA necesite procesar una imagen, debe:

1. Verificar que las dependencias estén instaladas (`pip install -r skills/image-to-ai/requirements.txt`)
2. Ejecutar el script con la ruta de la imagen y el modo deseado
3. Usar el resultado directamente en su prompt o análisis

### Ejemplo de prompt para el agente

> "Usa la skill image-to-ai para convertir ./captura.png a base64 y dime qué ves en la imagen."

El agente ejecutará:
```bash
python skills/image-to-ai/scripts/converter.py ./captura.png --mode base64
```

## Manejo de errores

| Error | Causa | Solución |
|-------|-------|----------|
| `FileNotFoundError` | La ruta de la imagen no existe | Verifica la ruta absoluta/relativa |
| `UnsupportedFormat` | El formato de imagen no es soportado | Usa PNG, JPG, JPEG, BMP o WEBP |
| `TesseractNotFoundError` | Tesseract no está instalado | Instala Tesseract OCR en el sistema |
| `ValueError` | Modo de salida no válido | Usa: base64, tensor, o text |

## Estructura de archivos

```
skills/image-to-ai/
├── SKILL.md              # Esta documentación
├── requirements.txt      # Dependencias Python
└── scripts/
    └── converter.py      # Lógica de conversión
```
