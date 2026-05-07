import 'dart:convert';
import 'dart:io';

import '../../domain/entities/chat_message_entity.dart';
import '../../domain/services/ai_service.dart';

class MistralService implements AIService {
  MistralService(this._apiKey);

  final String _apiKey;

  static const _baseUrl = 'https://api.mistral.ai/v1/chat/completions';
  static const _model = 'mistral-small-latest';

  @override
  Future<String> generateResponse({
    required List<ChatMessageEntity> messages,
    required List<String> learnedWords,
    required String topic,
    required String userLevel,
  }) async {
    final wordsText =
        learnedWords.isEmpty ? 'none yet' : learnedWords.join(', ');

    final systemPrompt =
        'Eres un asistente para aprender inglés. El estudiante está en nivel '
        '$userLevel y ha aprendido estas palabras: $wordsText.\n\n'
        'Estás teniendo una conversación sobre: $topic\n\n'
        'Por favor:\n'
        '1. Responde SIEMPRE en inglés\n'
        '2. Actúa como un hablante nativo amable\n'
        '3. Incorpora naturalmente las palabras que ha aprendido\n'
        '4. Mantén la conversación fluyendo sobre el tema: $topic\n'
        '5. Si comete errores gramaticales, corrígelos sutilmente\n'
        '6. Respuestas cortas (máx 2-3 frases)\n'
        '7. Usa ejemplos relevantes al tema';

    final mistralMessages = <Map<String, dynamic>>[
      {'role': 'system', 'content': systemPrompt},
      for (final m in messages)
        {'role': m.role == 'assistant' ? 'assistant' : 'user', 'content': m.content},
    ];

    final body = {
      'model': _model,
      'messages': mistralMessages,
      'temperature': 0.7,
      'max_tokens': 256,
    };

    final uri = Uri.parse(_baseUrl);
    final client = HttpClient();
    try {
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $_apiKey');
      request.write(jsonEncode(body));

      final response = await request.close();
      final raw = await response.transform(utf8.decoder).join();
      final data = jsonDecode(raw) as Map<String, dynamic>;

      if (data.containsKey('error')) {
        final err = data['error'];
        throw Exception(
            'Mistral error: ${err is Map ? err['message'] : err}');
      }

      final content =
          ((data['choices'] as List).first as Map)['message']['content']
              as String;
      return content.trim();
    } finally {
      client.close();
    }
  }

  @override
  Future<String> transcribeAudio(String audioPath) async {
    throw UnimplementedError(
        'Audio transcription is not supported by Mistral API.');
  }
}
