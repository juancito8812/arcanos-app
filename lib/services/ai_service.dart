import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/arcanos_data.dart';
import '../models/arcano.dart';

class AIService {
  static const _defaultBaseUrl = 'https://api.openai.com/v1';
  static const _defaultModel = 'gpt-4o-mini';

  static String? _buildTimeKey;

  static void setBuildTimeKey(String? key) {
    _buildTimeKey = key;
  }

  static Future<String?> getApiKey() async {
    if (_buildTimeKey != null && _buildTimeKey!.isNotEmpty) return _buildTimeKey;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('arcano_ai_key');
  }

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('arcano_ai_base_url') ?? _defaultBaseUrl;
  }

  static Future<String> getModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('arcano_ai_model') ?? _defaultModel;
  }

  static Future<String> interpretDailyCardByNumero(int arcanoNumero, String arcanoNombre) async {
    final arcano = getArcanoByNumero(arcanoNumero);
    if (arcano == null) return 'Arcano no encontrado.';
    return interpretDailyCard(arcano, null);
  }

  static Future<String> interpretDailyCard(Arcano arcano, String? lifeLinePeriod) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return 'Conectate a internet y configura tu API key en Ajustes para obtener una interpretacion personalizada.';
    }

    final systemPrompt = 'Eres un terapeuta de PsicoTarot experto en Arcanos Mayores, '
        'numerologia pitagorica y constelaciones familiares. Respondes en espanol, '
        'tono empatico, psicologico y empoderante. Maximo 150 palabras.';

    var userPrompt = 'Hoy ha salido el arcano ${arcano.nombre} (No.${arcano.numero}).';
    if (lifeLinePeriod != null) {
      userPrompt += ' La linea de vida indica que la persona esta en el periodo: $lifeLinePeriod.';
    }
    userPrompt += ' Interpreta como la energia de este arcano se manifiesta hoy. Da una reflexion practica y una afirmacion.';

    try {
      final baseUrl = await getBaseUrl();
      final model = await getModel();
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
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 300,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>;
        if (choices.isNotEmpty) {
          return (choices[0]['message']['content'] as String).trim();
        }
      }
      return 'No se pudo obtener interpretacion. Intentelo de nuevo mas tarde.';
    } catch (e) {
      return 'Error de conexion. Verifica tu internet e intenta de nuevo.';
    }
  }

  static Future<String> interpretTarotSpread(
    List<Arcano> cards,
    List<String> positions, {
    String? spreadName,
  }) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return 'Conectate a internet y configura tu API key en Ajustes para obtener una interpretacion personalizada.';
    }

    final systemPrompt = 'Eres un terapeuta de PsicoTarot experto en Arcanos Mayores. '
        'Respondes en espanol, tono empatico y psicologico. Maximo 250 palabras.';

    var userPrompt = 'Tirada de tarot';
    if (spreadName != null) userPrompt += ' "$spreadName"';
    userPrompt += ':\n';
    for (int i = 0; i < cards.length; i++) {
      final pos = i < positions.length ? positions[i] : 'Posicion ${i + 1}';
      userPrompt += '$pos: ${cards[i].nombre} (No.${cards[i].numero})\n';
    }

    try {
      final baseUrl = await getBaseUrl();
      final model = await getModel();
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
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>;
        if (choices.isNotEmpty) {
          return (choices[0]['message']['content'] as String).trim();
        }
      }
      return 'No se pudo obtener interpretacion.';
    } catch (e) {
      return 'Error de conexion.';
    }
  }
}
