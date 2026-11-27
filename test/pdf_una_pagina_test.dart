import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:arcanos_mayores/models/daily_card.dart';
import 'package:arcanos_mayores/models/destiny_matrix.dart';
import 'package:arcanos_mayores/services/pdf_export_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PDF de numeros personales: siempre 1 pagina', () async {
    final casos = [
      (nombre: 'JOSÉ MUÑOZ PEÑA AÑO', vida: 1, ano: 7),
      (nombre: 'MARÍA DE LOS ÁNGELES NÚÑEZ', vida: 9, ano: 3),
      (nombre: 'ANA', vida: 7, ano: 9),
    ];
    for (final c in casos) {
      final pdf = await PdfExportService.buildPersonalNumbersPdf(
        nombreCompleto: c.nombre,
        fechaNacimiento: DateTime(1985, 9, 23),
        fechaConsulta: DateTime(2026, 11, 25),
        numeroVida: c.vida,
        anoPersonal: c.ano,
      );
      expect(pdf.paginas, 1, reason: '${c.nombre} (vida ${c.vida}, ano ${c.ano}) => ${pdf.paginas} paginas');
      expect(pdf.bytes.length, greaterThan(2000));
      await File('/tmp/pdf_muestra_numeros.pdf').writeAsBytes(pdf.bytes);
    }
  });

  test('PDF de matriz del destino: 1 pagina aun con texto largo', () async {
    final largo = 'Camino de vida con pruebas y aprendizajes. ' * 12;
    final matrix = DestinyMatrix(
      birthDate: DateTime(1985, 9, 23),
      positions: List.generate(
        22,
        (i) => DestinyPosition(numero: i, key: 'P$i', nombreRomano: 'Arcano $i', nombre: largo),
        growable: false,
      ),
    );
    final pdf = await PdfExportService.buildDestinyMatrixPdf(matrix);
    expect(pdf.paginas, 1, reason: 'matriz => ${pdf.paginas} paginas (escala ${pdf.escala})');
    await File('/tmp/pdf_muestra_matriz.pdf').writeAsBytes(pdf.bytes);
  });

  test('PDF de carta del dia: 1 pagina aun con texto largo', () async {
    final card = DailyCard(
      date: DateTime(2026, 11, 25),
      arcanoNumero: 13,
      arcanoNombre: 'La Muerte — ¿transformación?',
      arcanoNombreRomano: 'XIII',
      aiInterpretation: 'Hoy toca transformar y soltar lo que ya no sirve: año de «soltar», señaló el ñandú. ' * 30,
      hasProfile: true,
    );
    final pdf = await PdfExportService.buildDailyCardPdf(card);
    expect(pdf.paginas, 1, reason: 'carta del dia => ${pdf.paginas} paginas (escala ${pdf.escala})');
    await File('/tmp/pdf_muestra_carta.pdf').writeAsBytes(pdf.bytes);
  });
}
