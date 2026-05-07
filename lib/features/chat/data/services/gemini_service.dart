import 'dart:convert';
import 'dart:io';

import '../../domain/entities/chat_message_entity.dart';
import '../../domain/services/ai_service.dart';

class GeminiService implements AIService {
  GeminiService(this._apiKey) {
    print('DEBUG GeminiService: initialized with key: ${_apiKey.substring(0, 10)}...');
  }

  final String _apiKey;

  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  @override
  Future<String> generateResponse({
    required List<ChatMessageEntity> messages,
    required List<String> learnedWords,
    required String topic,
    required String userLevel,
  }) async {
    print('DEBUG Gemini: iniciando generateResponse');
    print('DEBUG Gemini: topic=$topic');
    print('DEBUG Gemini: userLevel=$userLevel');
    print('DEBUG Gemini: learnedWords=${learnedWords.join(", ")}');
    print('DEBUG Gemini: messages count=${messages.length}');

    try {
      final wordsText =
          learnedWords.isEmpty ? 'none yet' : learnedWords.join(', ');

      final systemText = '''
Eres un asistente para aprender inglés. El estudiante está en nivel $userLevel y ha aprendido estas palabras: $wordsText.

Estás teniendo una conversación sobre: $topic

Por favor:
1. Responde SIEMPRE en inglés
2. Actúa como un hablante nativo amable
3. Incorpora naturalmente las palabras que ha aprendido
4. Mantén la conversación fluyendo sobre el tema: $topic
5. Si comete errores gramaticales, corrígelos sutilmente
6. Respuestas cortas (máx 2-3 frases)
7. Usa ejemplos relevantes al tema
''';

      print('DEBUG Gemini: construyendo request...');

      // Gemini requires alternating user/model turns starting with user.
      final contents = <Map<String, dynamic>>[];
      for (final m in messages) {
        final geminiRole = m.role == 'assistant' ? 'model' : 'user';
        // Merge consecutive same-role turns (Gemini constraint).
        if (contents.isNotEmpty && contents.last['role'] == geminiRole) {
          final parts = contents.last['parts'] as List;
          parts.add({'text': m.content});
        } else {
          contents.add({
            'role': geminiRole,
            'parts': [
              {'text': m.content}
            ],
          });
        }
      }

      // Gemini requires the last turn to be from user.
      if (contents.isEmpty || contents.last['role'] != 'user') return '';

      final body = {
        'contents': contents,
        'systemInstruction': {
          'parts': [
            {'text': systemText}
          ],
        },
        'generationConfig': {
          'temperature': 0.8,
          'maxOutputTokens': 256,
        },
      };

      print('DEBUG Gemini: enviando a Gemini...');
      final response = await _post(body);
      print('DEBUG Gemini: respuesta recibida');
      return response;
    } catch (e) {
      print('DEBUG Gemini ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<String> transcribeAudio(String audioPath) async {
    final bytes = await File(audioPath).readAsBytes();
    final base64Audio = base64Encode(bytes);

    final body = {
      'contents': [
        {
          'parts': [
            {
              'inlineData': {
                'mimeType': 'audio/wav',
                'data': base64Audio,
              }
            },
            {
              'text':
                  'Transcribe this audio to text. Return only the transcribed text, nothing else.'
            },
          ],
        }
      ],
    };

    return _post(body);
  }

  Future<String> _post(Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl?key=$_apiKey');
    final client = HttpClient();
    try {
      print('DEBUG _post: enviando request a $uri');
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      request.write(jsonEncode(body));

      final response = await request.close();
      print('DEBUG _post: status code = ${response.statusCode}');

      final raw = await response.transform(utf8.decoder).join();
      print('DEBUG _post: response body = $raw');

      final data = jsonDecode(raw) as Map<String, dynamic>;

      if (data.containsKey('error')) {
        final errorMsg = (data['error'] as Map)['message'];
        print('DEBUG _post ERROR: $errorMsg');
        throw Exception('Gemini error: $errorMsg');
      }

      final text = (((data['candidates'] as List).first as Map)['content']
              as Map)['parts'][0]['text'] as String;
      print('DEBUG _post: texto extraído = $text');
      return text.trim();
    } catch (e) {
      print('DEBUG _post EXCEPTION: $e');
      rethrow;
    } finally {
      client.close();
    }
  }
}
