import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  test('helvetica con acentos', () async {
    final doc = pw.Document();
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (c) => pw.Column(children: [
        pw.Text('ÑANDÚ AÑO ÁÉÍÓÚÜ ñ áéíóú — “comillas” ¿pregunta? ¡exclama! 50 % · 3,5'),
        pw.Text('AÑO', style: pw.TextStyle(fontSize: 12)),
      ]),
    ));
    await File('/tmp/pdfprobe/helv.pdf').writeAsBytes(await doc.save());
  });
}
