import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/daily_card.dart';
import '../models/destiny_matrix.dart';

class PdfExportService {
  static Future<Uint8List> _buildDailyCardPdf(DailyCard card) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (ctx) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Center(
            child: pw.Text('PsicoTarot — Carta del Dia',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text('${card.arcanoNombreRomano} — ${card.arcanoNombre}',
              style: pw.TextStyle(fontSize: 18, color: PdfColors.purple)),
          ),
          pw.Divider(),
          pw.SizedBox(height: 12),
          pw.Text('Fecha: ${card.date.day}/${card.date.month}/${card.date.year}'),
          pw.SizedBox(height: 16),
          if (card.aiInterpretation != null) ...[
            pw.Text('Interpretacion:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            pw.SizedBox(height: 8),
            pw.Text(card.aiInterpretation!),
          ],
        ]),
      ),
    );

    return doc.save();
  }

  static Future<Uint8List> _buildDestinyMatrixPdf(DestinyMatrix matrix) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (ctx) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Center(
            child: pw.Text('PsicoTarot — Matriz del Destino',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              'Nacimiento: ${matrix.birthDate.day}/${matrix.birthDate.month}/${matrix.birthDate.year}',
              style: const pw.TextStyle(fontSize: 14)),
          ),
          pw.Divider(),
          pw.SizedBox(height: 16),
          ...matrix.positions.map((pos) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('${pos.key}: ${pos.nombreRomano} — ${pos.nombre}',
                style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 8),
            ],
          )),
        ]),
      ),
    );

    return doc.save();
  }

  static Future<void> shareDailyCardPdf(DailyCard card) async {
    final bytes = await _buildDailyCardPdf(card);
    await _shareBytes(bytes, 'carta_del_dia.pdf');
  }

  static Future<void> shareDestinyMatrixPdf(DestinyMatrix matrix) async {
    final bytes = await _buildDestinyMatrixPdf(matrix);
    await _shareBytes(bytes, 'matriz_destino.pdf');
  }

  static Future<void> _shareBytes(Uint8List bytes, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: 'PsicoTarot');
  }
}
