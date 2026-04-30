import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_KEY', defaultValue: "");
  static const String _model = "gemini-2.5-flash-preview-09-2025";

  Future<dynamic> _postWithRetry(Map<String, dynamic> payload) async {
    if (_apiKey.isEmpty) throw Exception("API_KEY_MISSING");

    int retryCount = 0;
    while (retryCount < 3) {
      try {
        final url = "https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey";
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 45));
        if (response.statusCode == 200) return jsonDecode(response.body);
      } catch (e) {}
      retryCount++;
      await Future.delayed(const Duration(seconds: 1));
    }
    throw Exception("Error de red");
  }

  Future<List<Map<String, dynamic>>> generateQuestions({
    String? sourceText,
    String? pdfBase64,
    required int count,
    required String difficulty,
  }) async {
    final systemPrompt = """
    Eres un profesor experto. Genera $count preguntas.
    REGLA CRÍTICA: Cada opción DEBE incluir un campo 'rationale' que explique por qué esa opción es correcta o por qué es un distractor común.
    
    Formato JSON:
    {
      "questions": [
        {
          "statement": "...",
          "topics": ["..."],
          "options": [
            {"text": "...", "correct": true, "rationale": "Explicación detallada de por qué es correcta."},
            {"text": "...", "correct": false, "rationale": "Explicación de por qué esta opción es incorrecta."}
          ]
        }
      ]
    }
    """;

    List<Map<String, dynamic>> parts = [];
    if (pdfBase64 != null) parts.add({"inlineData": {"mimeType": "application/pdf", "data": pdfBase64}});
    parts.add({"text": sourceText ?? "Genera preguntas del temario."});

    final payload = {
      "contents": [{ "role": "user", "parts": parts }],
      "systemInstruction": { "parts": [{ "text": systemPrompt }] },
      "generationConfig": { "responseMimeType": "application/json" }
    };

    final result = await _postWithRetry(payload);
    String rawText = result['candidates'][0]['content']['parts'][0]['text'];
    rawText = rawText.replaceAll('```json', '').replaceAll('```', '').trim();
    final data = jsonDecode(rawText);
    return List<Map<String, dynamic>>.from(data['questions']);
  }
}