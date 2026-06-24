import 'dart:math';
import '../data/arcanos_data.dart';
import '../models/arcano.dart';
import '../models/daily_card.dart';
import 'database_service.dart';

class DailyCardService {
  static Future<DailyCard?> getTodayCard() async {
    final db = await DatabaseService.database;
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final results = await db.query('daily_cards',
      where: 'date = ?', whereArgs: [dateStr], limit: 1);

    if (results.isNotEmpty) {
      return DailyCard.fromMap(results.first);
    }
    return null;
  }

  static Future<DailyCard> generateDailyCard({required bool hasProfile, int? ageYears, List<int>? profileArcanos}) async {
    Arcano card;

    if (hasProfile && ageYears != null && profileArcanos != null && profileArcanos.length >= 5) {
      int periodIndex;
      if (ageYears <= 10) {
        periodIndex = 0;
      } else if (ageYears <= 20) {
        periodIndex = 1;
      } else if (ageYears <= 30) {
        periodIndex = 2;
      } else if (ageYears <= 40) {
        periodIndex = 3;
      } else {
        periodIndex = 4;
      }
      card = getArcanoByNumero(profileArcanos[periodIndex]) ?? allArcanos[0];
    } else {
      card = allArcanos[Random().nextInt(allArcanos.length)];
    }

    return DailyCard(
      date: DateTime.now(),
      arcanoNumero: card.numero,
      arcanoNombre: card.nombre,
      arcanoNombreRomano: card.nombreRomano,
      aiInterpretation: null,
      hasProfile: hasProfile,
    );
  }

  static Future<void> saveCard(DailyCard card) async {
    final db = await DatabaseService.database;
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    await db.delete('daily_cards', where: 'date = ?', whereArgs: [dateStr]);

    await db.insert('daily_cards', {
      'date': dateStr,
      'arcano_numero': card.arcanoNumero,
      'arcano_nombre': card.arcanoNombre,
      'arcano_nombre_romano': card.arcanoNombreRomano,
      'ai_interpretation': card.aiInterpretation,
      'has_profile': card.hasProfile ? 1 : 0,
    });
  }

  static Future<void> updateInterpretation(int arcanoNumero, String interpretation) async {
    final db = await DatabaseService.database;
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    await db.update('daily_cards',
      {'ai_interpretation': interpretation},
      where: 'date = ? AND arcano_numero = ?',
      whereArgs: [dateStr, arcanoNumero],
    );
  }
}
