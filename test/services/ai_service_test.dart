import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arcanos_mayores/services/ai_service.dart';
import 'package:arcanos_mayores/models/arcano.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AIService', () {
    test('interpretDailyCard returns fallback when no API key', () async {
      SharedPreferences.setMockInitialValues({});
      AIService.setBuildTimeKey(null);
      final result = await AIService.interpretDailyCard(
        const Arcano(
          id: 0, numero: 0, nombre: 'El Loco', nombreRomano: '0',
          leyEspiritual: 'Ley del Uno',
          leccionVida: 'El Buscador',
          miedoAsociado: 'Miedo a la vida',
          arquetipo: 'El inocente',
          elemento: 'Aire',
          polaridad: 'Masculino',
          valorNuclear: 0,
        ),
        null,
      );
      expect(result, contains('API key'));
    });

    test('interpretTarotSpread returns fallback when no API key', () async {
      SharedPreferences.setMockInitialValues({});
      AIService.setBuildTimeKey(null);
      final result = await AIService.interpretTarotSpread([], []);
      expect(result, contains('API key'));
    });
  });
}
