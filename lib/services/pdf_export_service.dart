import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/personal_numbers_data.dart';
import '../models/daily_card.dart';
import '../models/destiny_matrix.dart';

class PdfExportService {
  /// Quita acentos y caracteres fuera de WinAnsi: la fuente por defecto del
  /// paquete pdf (Helvetica) no los renderiza (mismo criterio que los otros PDF).
  static String _textoPdf(String s) {
    const map = {
      '\u2014': '-', '\u2013': '-', '\u2212': '-', '\u2012': '-', '\u2015': '-',
      '\u2026': '...', '\u2022': '\u00b7', '\u25cf': '\u00b7',
      '\u201c': '"', '\u201d': '"', '\u201e': '"',
      '\u2018': "'", '\u2019': "'", '\u201a': "'",
      '\u00a0': ' ', '\u202f': ' ', '\u2009': ' ', '\u200b': '',
      '\u2192': '->', '\u2265': '>=', '\u2264': '<=', '\u00bd': '1/2',
    };
    final limpio = s.splitMapJoin('', onNonMatch: (c) => map[c] ?? c);
    // Helvetica solo cubre latin-1: acentos, enie y signos (¿ ¡ « ») pasan tal cual;
    // el resto (emoji, simbolos fuera de latin-1) se descarta.
    return String.fromCharCodes(limpio.runes.where((r) => r < 0x100));
  }

  static Future<PdfGenerado> buildDailyCardPdf(DailyCard card) {
    pw.Document construir(double s) {
      final doc = pw.Document();
      doc.addPage(pw.MultiPage(
        margin: const pw.EdgeInsets.fromLTRB(36, 30, 36, 30),
        build: (ctx) => [
          pw.Center(
            child: pw.Text('PsicoTarot · Carta del Día',
              style: pw.TextStyle(fontSize: 22 * s, fontWeight: pw.FontWeight.bold, color: _purpuraOscuro)),
          ),
          pw.SizedBox(height: 8 * s),
          pw.Center(
            child: pw.Text(_textoPdf('${card.arcanoNombreRomano} - ${card.arcanoNombre}'),
              style: pw.TextStyle(fontSize: 18 * s, color: _purpura)),
          ),
          pw.SizedBox(height: 6 * s),
          pw.Divider(color: _dorado),
          pw.SizedBox(height: 10 * s),
          pw.Text('Fecha: ${card.date.day}/${card.date.month}/${card.date.year}',
            style: pw.TextStyle(fontSize: 11.4 * s, color: PdfColors.grey700)),
          pw.SizedBox(height: 14 * s),
          if (card.aiInterpretation != null) ...[
            pw.Text('INTERPRETACIÓN',
              style: pw.TextStyle(fontSize: 12.4 * s, fontWeight: pw.FontWeight.bold, color: _purpuraOscuro, letterSpacing: 0.7)),
            pw.SizedBox(height: 6 * s),
            pw.Text(_textoPdf(card.aiInterpretation!),
              style: pw.TextStyle(fontSize: 11.4 * s, lineSpacing: 2.7 * s, color: PdfColors.grey900)),
          ],
        ],
      ));
      return doc;
    }
    return _fitToOnePage(construir);
  }

  static Future<PdfGenerado> buildDestinyMatrixPdf(DestinyMatrix matrix) {
    pw.Document construir(double s) {
      final doc = pw.Document();
      doc.addPage(pw.MultiPage(
        margin: const pw.EdgeInsets.fromLTRB(36, 30, 36, 30),
        build: (ctx) => [
          pw.Center(
            child: pw.Text('PsicoTarot · Matriz del Destino',
              style: pw.TextStyle(fontSize: 22 * s, fontWeight: pw.FontWeight.bold, color: _purpuraOscuro)),
          ),
          pw.SizedBox(height: 8 * s),
          pw.Center(
            child: pw.Text(
              'Nacimiento: ${matrix.birthDate.day}/${matrix.birthDate.month}/${matrix.birthDate.year}',
              style: pw.TextStyle(fontSize: 14 * s, color: PdfColors.grey700)),
          ),
          pw.SizedBox(height: 6 * s),
          pw.Divider(color: _dorado),
          pw.SizedBox(height: 12 * s),
          ...matrix.positions.map((pos) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(_textoPdf('${pos.key}: ${pos.nombreRomano} - ${pos.nombre}'),
                style: pw.TextStyle(fontSize: 13 * s, color: PdfColors.grey900)),
              pw.SizedBox(height: 6 * s),
            ],
          )),
        ],
      ));
      return doc;
    }
    return _fitToOnePage(construir);
  }

  /// Genera el PDF y, si el contenido desborda, lo reencoge hasta que quepa
  /// en una sola pagina (el diseno se mantiene, solo cambia la escala).
  static Future<PdfGenerado> _fitToOnePage(
    pw.Document Function(double escala) construir, {
    double minEscala = 0.5,
  }) async {
    var escala = 1.0;
    var doc = construir(escala);
    var bytes = await doc.save();
    while (doc.document.pdfPageList.pages.length > 1 && escala > minEscala) {
      escala -= 0.04;
      doc = construir(escala);
      bytes = await doc.save();
    }
    return PdfGenerado(bytes, doc.document.pdfPageList.pages.length, escala);
  }

  static Future<void> shareDailyCardPdf(DailyCard card) async {
    final pdf = await buildDailyCardPdf(card);
    await _shareBytes(pdf.bytes, 'carta_del_dia.pdf');
  }

  static Future<void> shareDestinyMatrixPdf(DestinyMatrix matrix) async {
    final pdf = await buildDestinyMatrixPdf(matrix);
    await _shareBytes(pdf.bytes, 'matriz_destino.pdf');
  }

  /// PDF entregable de Numerologia Personal: Número de Vida y Año Personal
  /// con su lectura completa (esencia, dones, sombras, karma, año, recomendaciones).
  static const _purpura = PdfColor.fromInt(0xFF6A1B9A);
  static const _purpuraOscuro = PdfColor.fromInt(0xFF4A148C);
  static const _dorado = PdfColor.fromInt(0xFFB8860B);
  static const _fondoCard = PdfColor.fromInt(0xFFF7F1FA);

  static Future<void> sharePersonalNumbersPdf({
    required String nombreCompleto,
    required DateTime fechaNacimiento,
    required DateTime fechaConsulta,
    required int numeroVida,
    required int anoPersonal,
  }) async {
    final pdf = await buildPersonalNumbersPdf(
      nombreCompleto: nombreCompleto,
      fechaNacimiento: fechaNacimiento,
      fechaConsulta: fechaConsulta,
      numeroVida: numeroVida,
      anoPersonal: anoPersonal,
    );
    await _shareBytes(pdf.bytes, 'numeros_personales.pdf');
  }

  /// Construye el PDF y garantiza que salga en una sola pagina.
  static Future<PdfGenerado> buildPersonalNumbersPdf({
    required String nombreCompleto,
    required DateTime fechaNacimiento,
    required DateTime fechaConsulta,
    required int numeroVida,
    required int anoPersonal,
  }) async {
    final infoVida = vidaInfo[numeroVida]!;
    final infoAno = anoInfo[anoPersonal]!;

    // Todo el documento se construye a una escala s para poder reencogerlo
    // hasta que entre en una sola pagina.
    pw.Document construir(double s) {
      final doc = pw.Document();

      pw.Widget seccion(String titulo, String texto) => pw.Container(
        width: double.infinity,
        margin: pw.EdgeInsets.only(bottom: 10 * s),
        padding: pw.EdgeInsets.fromLTRB(14 * s, 9 * s, 14 * s, 10 * s),
        decoration: pw.BoxDecoration(
          color: _fondoCard,
          borderRadius: pw.BorderRadius.circular(6 * s),
          border: pw.Border.all(color: PdfColors.purple100, width: 0.8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(children: [
              pw.Container(width: 3.5 * s, height: 12 * s, color: _dorado, margin: pw.EdgeInsets.only(right: 6 * s)),
              pw.Expanded(
                child: pw.Text(_textoPdf(titulo.toUpperCase()),
                  style: pw.TextStyle(fontSize: 12.4 * s, fontWeight: pw.FontWeight.bold, color: _purpuraOscuro, letterSpacing: 0.7)),
              ),
            ]),
            pw.SizedBox(height: 5 * s),
            pw.Text(_textoPdf(texto),
              style: pw.TextStyle(fontSize: 11.4 * s, lineSpacing: 2.7 * s, color: PdfColors.grey900)),
          ],
        ),
      );

      pw.Widget numeroHero(int numero, String etiqueta) => pw.Column(
        children: [
          pw.Container(
            width: 74 * s, height: 74 * s,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              gradient: pw.LinearGradient(colors: const [_purpura, _purpuraOscuro], begin: pw.Alignment.topLeft, end: pw.Alignment.bottomRight),
              border: pw.Border.all(color: _dorado, width: 2),
            ),
            child: pw.Text('$numero',
              style: pw.TextStyle(fontSize: 32 * s, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
          ),
          pw.SizedBox(height: 6 * s),
          pw.Text(_textoPdf(etiqueta),
            style: pw.TextStyle(fontSize: 10.4 * s, fontWeight: pw.FontWeight.bold, color: _dorado, letterSpacing: 0.8)),
        ],
      );

      pw.Widget tituloBloque(String t) => pw.Text(t,
        style: pw.TextStyle(fontSize: 14 * s, fontWeight: pw.FontWeight.bold, color: _purpura, letterSpacing: 1));

      doc.addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.fromLTRB(36, 28, 36, 26),
          footer: (ctx) => pw.Container(
            padding: pw.EdgeInsets.only(top: 6 * s),
            decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(_textoPdf(nombreCompleto),
                  style: pw.TextStyle(fontSize: 9.4 * s, color: PdfColors.grey600)),
                pw.Text('Numerología Personal',
                  style: pw.TextStyle(fontSize: 8 * s, color: PdfColors.grey600)),
              ],
            ),
          ),
          build: (ctx) => [
            pw.Container(
              width: double.infinity,
              padding: pw.EdgeInsets.symmetric(vertical: 22 * s, horizontal: 16 * s),
              decoration: pw.BoxDecoration(
                gradient: const pw.LinearGradient(colors: [_purpuraOscuro, _purpura]),
                borderRadius: pw.BorderRadius.circular(8 * s),
              ),
              child: pw.Column(
                children: [
                  pw.Text('NUMEROLOGÍA PERSONAL',
                    style: pw.TextStyle(fontSize: 23 * s, fontWeight: pw.FontWeight.bold, color: PdfColors.white, letterSpacing: 2)),
                  pw.SizedBox(height: 4 * s),
                  pw.Container(width: 60 * s, height: 2, color: _dorado),
                  pw.SizedBox(height: 7 * s),
                  pw.Text(_textoPdf(nombreCompleto.toUpperCase()),
                    style: pw.TextStyle(fontSize: 16.5 * s, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                  pw.SizedBox(height: 4 * s),
                  pw.Text(
                    'Nacimiento: ${fechaNacimiento.day}/${fechaNacimiento.month}/${fechaNacimiento.year}'
                    '   -   Consulta: ${fechaConsulta.day}/${fechaConsulta.month}/${fechaConsulta.year}',
                    style: pw.TextStyle(fontSize: 11.6 * s, color: PdfColors.purple100)),
                ],
              ),
            ),
            pw.SizedBox(height: 18 * s),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                numeroHero(numeroVida, 'NÚMERO DE VIDA'),
                pw.Container(width: 1, height: 88 * s, color: PdfColors.grey300),
                numeroHero(anoPersonal, 'AÑO PERSONAL ${fechaConsulta.year}'),
              ],
            ),
            pw.SizedBox(height: 18 * s),
            tituloBloque('TU NÚMERO DE VIDA'),
            pw.SizedBox(height: 6 * s),
            seccion('Esencia', infoVida.esencia),
            seccion('Dones y habilidades', infoVida.dones),
            seccion('Sombras y debilidades', infoVida.sombras),
            seccion('Lección kármica', infoVida.karma),
            seccion('Recomendación', infoVida.recomendacion),
            pw.SizedBox(height: 11 * s),
            tituloBloque('TU AÑO PERSONAL EN ${fechaConsulta.year}'),
            pw.SizedBox(height: 6 * s),
            seccion('Lo positivo del año', infoAno.positivo),
            seccion('Lo negativo del año', infoAno.negativo),
            seccion('Recomendación', infoAno.recomendacion),
          ],
        ),
      );
      return doc;
    }

    return _fitToOnePage(construir);
  }

  static Future<void> _shareBytes(Uint8List bytes, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: 'Numerologia Personal');
  }
}

/// Resultado de generar un PDF: bytes listos y metadatos de ajuste.
class PdfGenerado {
  final Uint8List bytes;
  final int paginas;
  final double escala;

  const PdfGenerado(this.bytes, this.paginas, this.escala);
}
