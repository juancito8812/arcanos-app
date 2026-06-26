import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../data/arcanos_data.dart';
import '../models/arcano.dart';
import '../models/constellation_session.dart';
import '../models/family_member.dart';
import '../services/ai_service.dart';

class ConstellationService {
  static const posicionesSistemicas = [
    'YO', 'PADRE', 'MADRE', 'HERMANO/A', 'SECRETO', 'ANCESTRO', 'EXCLUIDO',
  ];

  static Arcano? arcanoParaPosicion(String posicion, {FamilyMember? miembro, int? edad}) {
    if (miembro?.arcanoNumero != null) return getArcanoByNumero(miembro!.arcanoNumero!);
    if (miembro?.fechaNacimiento != null && edad != null) {
      return allArcanos[Random(miembro!.fechaNacimiento.hashCode + edad).nextInt(allArcanos.length)];
    }
    final idx = posicionesSistemicas.indexOf(posicion);
    return allArcanos[idx >= 0 ? idx : Random().nextInt(allArcanos.length)];
  }

  static List<Map<String, dynamic>> detectarPatronesTransgeneracionales(
    List<FamilyMember> miembros, {
    List<int>? arcanosUsuario,
  }) {
    final arcanoCount = <int, int>{};
    final arcanoMiembros = <int, List<String>>{};

    for (final m in miembros) {
      if (m.arcanoNumero == null) continue;
      arcanoCount[m.arcanoNumero!] = (arcanoCount[m.arcanoNumero!] ?? 0) + 1;
      arcanoMiembros.putIfAbsent(m.arcanoNumero!, () => []);
      arcanoMiembros[m.arcanoNumero!]!.add('${m.nombre} (${m.relacion})');
    }

    if (arcanosUsuario != null) {
      for (final a in arcanosUsuario) {
        arcanoCount[a] = (arcanoCount[a] ?? 0) + 1;
        arcanoMiembros.putIfAbsent(a, () => []);
        arcanoMiembros[a]!.insert(0, 'TU');
      }
    }

    final patrones = <Map<String, dynamic>>[];
    for (final entry in arcanoCount.entries) {
      if (entry.value >= 2) {
        final arcano = getArcanoByNumero(entry.key);
        patrones.add({
          'arcano': arcano,
          'repeticiones': entry.value,
          'miembros': arcanoMiembros[entry.key],
          'mensaje': 'El arcano ${arcano?.nombre ?? entry.key} aparece ${entry.value} veces. '
              'Leccion: ${arcano?.leccionVida ?? ""}',
        });
      }
    }
    patrones.sort((a, b) => (b['repeticiones'] as int).compareTo(a['repeticiones'] as int));
    return patrones;
  }

  static Future<String?> interpretarConIA(ConstellationSession sesion) async {
    final apiKey = await AIService.getApiKey();
    if (apiKey == null || apiKey.isEmpty) return null;

    var prompt = 'Tema: ${sesion.tema}\n\nPosiciones:\n';
    for (final p in sesion.posiciones) {
      final arcano = getArcanoByNumero(p.arcanoNumero);
      prompt += '- ${p.posicionSistemica}: ${p.memberName} (${p.relacion}) -> ${arcano?.nombre ?? ""}\n';
    }

    try {
      final baseUrl = await AIService.getBaseUrl();
      final model = await AIService.getModel();
      final url = baseUrl.endsWith('/') ? '${baseUrl}chat/completions' : '$baseUrl/chat/completions';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'system', 'content': 'Eres un terapeuta de constelaciones familiares experto en Bert Hellinger. Respondes en espanol. Maximo 200 palabras. Identifica que orden del amor se transgrede y sugiere frases sanadoras.'},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          return (choices[0]['message']['content'] as String).trim();
        }
      }
    } catch (_) {}
    return null;
  }
}
