import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/arcanos_data.dart';
import '../data/pythagorean_table.dart';
import '../models/arcano.dart';
import '../models/constellation_session.dart';
import '../models/family_member.dart';
import '../services/ai_service.dart';
import '../services/life_line_calculator.dart';

class ConstellationService {
  static const posicionesSistemicas = [
    'YO', 'PADRE', 'MADRE', 'HERMANO/A', 'SECRETO', 'ANCESTRO', 'EXCLUIDO',
  ];

  /// Arcano estable para una posicion.
  ///
  /// Nunca usa `Random()` sin semilla: dos guardados de la misma constelacion
  /// devuelven el mismo arcano (antes cada pulsacion daba una sesion distinta).
  static Arcano? arcanoParaPosicion(String posicion, {FamilyMember? miembro, int? edad}) {
    final guardado = miembro?.arcanoNumero;
    if (guardado != null) {
      final arcano = getArcanoByNumero(reducirAArcano(guardado));
      if (arcano != null) return arcano;
    }

    final porFecha = arcanoDesdeMiembro(miembro);
    if (porFecha != null) return porFecha;

    final idx = posicionesSistemicas.indexOf(posicion);
    if (idx >= 0) return allArcanos[idx % allArcanos.length];
    return allArcanos[_semilla(posicion) % allArcanos.length];
  }

  /// Deriva el arcano de un familiar a partir de su nombre y fecha de nacimiento.
  ///
  /// Se usa tanto al crear el miembro (para guardar `arcano_numero`) como al
  /// pintar la rueda cuando el registro viejo no lo tiene.
  static Arcano? arcanoDesdeMiembro(FamilyMember? miembro) {
    if (miembro == null) return null;
    final raw = miembro.fechaNacimiento?.trim() ?? '';
    if (raw.isEmpty) return null;
    final fecha = DateTime.tryParse(raw);
    if (fecha == null) return null;

    final nombre = miembro.nombre.trim();
    if (nombre.isEmpty) {
      final reducido = reducirAArcano(
          sumarDigitosFecha(fecha.day, fecha.month, fecha.year));
      return getArcanoByNumero(reducido);
    }

    final resultado = LifeLineCalculator.calcular(
      nombreCompleto: nombre,
      fechaNacimiento: fecha,
    );
    if (resultado == null || resultado.arcanos.isEmpty) return null;
    return getArcanoByNumero(reducirAArcano(resultado.arcanos.first.arcano.numero));
  }

  static int _semilla(String texto) {
    var acc = 0;
    for (final c in texto.codeUnits) {
      acc = (acc * 31 + c) & 0x7fffffff;
    }
    return acc;
  }

  static List<Map<String, dynamic>> detectarPatronesTransgeneracionales(
    List<FamilyMember> miembros, {
    List<int>? arcanosUsuario,
  }) {
    final arcanoCount = <int, int>{};
    final arcanoMiembros = <int, List<String>>{};

    for (final m in miembros) {
      final numero = m.arcanoNumero ?? arcanoDesdeMiembro(m)?.numero;
      if (numero == null) continue;
      final clave = reducirAArcano(numero);
      arcanoCount[clave] = (arcanoCount[clave] ?? 0) + 1;
      arcanoMiembros.putIfAbsent(clave, () => []);
      arcanoMiembros[clave]!.add('${m.nombre} (${m.relacion})');
    }

    if (arcanosUsuario != null) {
      for (final a in arcanosUsuario) {
        final clave = reducirAArcano(a);
        arcanoCount[clave] = (arcanoCount[clave] ?? 0) + 1;
        arcanoMiembros.putIfAbsent(clave, () => []);
        arcanoMiembros[clave]!.insert(0, 'TU');
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
