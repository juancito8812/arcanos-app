#!/usr/bin/env python3
"""
Image-to-AI Converter
Convierte imágenes locales a formatos que los modelos de IA pueden procesar.

Modos:
  - base64: codifica la imagen en Base64 (para GPT-4V, Claude, Gemini)
  - tensor: convierte la imagen a array NumPy (para PyTorch/TensorFlow)
  - text:   extrae texto mediante OCR (Tesseract)

Uso:
  python converter.py <ruta_imagen> --mode <base64|tensor|text>
  python converter.py ./captura.png --mode base64
  python converter.py ./captura.png --mode tensor --as-tensor
  python converter.py ./captura.png --mode text --lang spa
"""

import argparse
import base64
import os
import sys
from io import BytesIO
from pathlib import Path

try:
    from PIL import Image
except ImportError as e:
    print(f"Error: Falta Pillow: {e}", file=sys.stderr)
    print("Ejecuta: pip install -r requirements.txt", file=sys.stderr)
    sys.exit(1)

# OpenCV y NumPy se importan bajo demanda dentro de cada función

# ── Utilidad: validar ruta y formato ──────────────────────────────

SUPPORTED_EXTENSIONS = {'.png', '.jpg', '.jpeg', '.bmp', '.webp'}


def _validate_image(path: str) -> str:
    """Valida que la ruta exista y el formato sea soportado. Retorna la ruta absoluta."""
    p = Path(path)
    if not p.exists():
        raise FileNotFoundError(f"Archivo no encontrado: {path}")
    if p.suffix.lower() not in SUPPORTED_EXTENSIONS:
        raise ValueError(
            f"Formato no soportado: '{p.suffix}'. Usa: {', '.join(sorted(SUPPORTED_EXTENSIONS))}"
        )
    return str(p.resolve())


# ── Modo 1: Base64 ───────────────────────────────────────────────

def image_to_base64(path: str) -> str:
    """
    Codifica una imagen a string Base64 con prefijo data URI.

    Args:
        path: Ruta a la imagen local.

    Returns:
        String en formato: data:image/{formato};base64,{codigo}

    Ejemplo:
        >>> b64 = image_to_base64('./captura.png')
        >>> print(b64[:50])
        data:image/png;base64,iVBORw0KGgo...
    """
    path = _validate_image(path)
    img = Image.open(path)
    img.verify()  # Valida integridad del archivo
    img = Image.open(path)  # Reabrir porque verify() cierra
    fmt = img.format.lower() if img.format else 'png'
    buffer = BytesIO()
    img.save(buffer, format=img.format or 'PNG')
    b64_str = base64.b64encode(buffer.getvalue()).decode('utf-8')
    return f"data:image/{fmt};base64,{b64_str}"


# ── Modo 2: Tensor (NumPy / PyTorch) ─────────────────────────────

def image_to_tensor(path: str, as_tensor: bool = False):
    """
    Convierte una imagen a un array NumPy o tensor normalizado.

    Args:
        path: Ruta a la imagen local.
        as_tensor: Si es True, retorna un array con forma (C, H, W)
                   con valores float32 normalizados a [0, 1].
                   Si es False, retorna array (H, W, C) con valores uint8.

    Returns:
        numpy.ndarray con la representación de la imagen.

    Ejemplo:
        >>> arr = image_to_tensor('./img.png', as_tensor=False)   # (H, W, 3) uint8
        >>> ten = image_to_tensor('./img.png', as_tensor=True)     # (3, H, W) float32
    """
    import cv2
    import numpy as np

    path = _validate_image(path)
    img = cv2.imread(path)
    if img is None:
        raise ValueError(f"No se pudo leer la imagen con OpenCV: {path}")

    # Manejar imagen en escala de grises (2D) convirtiendo a 3 canales
    if len(img.shape) == 2:
        img_rgb = cv2.cvtColor(img, cv2.COLOR_GRAY2RGB)
    else:
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    if not as_tensor:
        return img_rgb  # (H, W, C) uint8

    # Normalizar y reordenar a (C, H, W) para PyTorch
    img_float = img_rgb.astype(np.float32) / 255.0
    return np.transpose(img_float, (2, 0, 1))  # (C, H, W)


# ── Modo 3: Texto (OCR) ──────────────────────────────────────────

def image_to_text(path: str, lang: str = 'spa') -> str:
    """
    Extrae texto de una imagen usando Tesseract OCR.

    Args:
        path: Ruta a la imagen local.
        lang: Código de idioma para OCR (ej: 'spa' para español,
              'eng' para inglés, 'spa+eng' para ambos).

    Returns:
        String con el texto extraído.

    Requiere:
        Tesseract OCR instalado en el sistema.
        https://github.com/tesseract-ocr/tesseract

    Ejemplo:
        >>> texto = image_to_text('./documento.png', lang='spa')
        >>> print(texto)
    """
    try:
        import pytesseract
    except ImportError:
        print("Error: pytesseract no está instalado.", file=sys.stderr)
        print("Ejecuta: pip install pytesseract", file=sys.stderr)
        sys.exit(1)

    path = _validate_image(path)
    img = Image.open(path)
    try:
        text = pytesseract.image_to_string(img, lang=lang)
    except Exception as e:
        raise RuntimeError(
            f"Error al ejecutar Tesseract OCR. "
            f"¿Está instalado Tesseract en el sistema? Detalle: {e}"
        )
    return text.strip()


# ── CLI ───────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="Convierte una imagen a formato legible por IA."
    )
    parser.add_argument(
        'path',
        type=str,
        help='Ruta a la imagen local (ej: ./captura.png)'
    )
    parser.add_argument(
        '--mode',
        type=str,
        required=True,
        choices=['base64', 'tensor', 'text'],
        help='Modo de salida: base64, tensor (NumPy/PyTorch), o text (OCR)'
    )
    parser.add_argument(
        '--as-tensor',
        action='store_true',
        help='[Modo tensor] Si se activa, retorna tensor (C,H,W) normalizado para PyTorch'
    )
    parser.add_argument(
        '--lang',
        type=str,
        default='spa',
        help='[Modo text] Idioma para OCR (ej: spa, eng, spa+eng). Default: spa'
    )
    args = parser.parse_args()

    try:
        if args.mode == 'base64':
            result = image_to_base64(args.path)
            print(result)

        elif args.mode == 'tensor':
            arr = image_to_tensor(args.path, as_tensor=args.as_tensor)
            print(f"Shape: {arr.shape}, dtype: {arr.dtype}")
            print(f"Array:\n{arr}")

        elif args.mode == 'text':
            text = image_to_text(args.path, lang=args.lang)
            if not text:
                print("(No se encontró texto en la imagen)")
            else:
                print(text)

    except FileNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    except RuntimeError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error inesperado: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
