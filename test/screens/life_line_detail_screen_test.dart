import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arcanos_mayores/models/life_line.dart';
import 'package:arcanos_mayores/screens/life_line/life_line_detail_screen.dart';

Widget _buildApp(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  testWidgets('LifeLineDetailScreen renders arcano name', (tester) async {
    final pos = ArcanoPosicion(
      posicion: 1,
      nombre: 'YO - Personalidad',
      arcano: ArcanoInfo(numero: 1, nombre: 'El Mago', nombreRomano: 'I'),
      edadPeriodo: '0 a 10 anos',
      significado: 'Representa tu personalidad consciente.',
    );
    await tester.pumpWidget(_buildApp(LifeLineDetailScreen(pos: pos)));
    expect(find.text('El Mago'), findsOneWidget);
  });
}
