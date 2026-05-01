import 'dart:convert';
import 'dart:io';

import '../../domain/entities/chat_message_entity.dart';
import '../../domain/services/ai_service.dart';

class GeminiService implements AIService {
  GeminiService(this._apiKey);

  final String _apiKey;

  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  @override
  Future<String> generateResponse({
    required List<ChatMessageEntity> messages,
    required List<String> learnedWords,
    required String topic,
  }) async {
    final wordsText = learnedWords.isEmpty ? 'none yet' : learnedWords.join(', ');

    final systemText =
        'You are an assistant for learning English. The student has learned '
        'these words: $wordsText. Always respond in English about the topic: '
        '$topic. Incorporate learned words naturally when relevant. Keep '
        'responses to 2-3 sentences max. If the user makes a grammatical '
        'error, subtly correct it in your response.';

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

    return _post(body);
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
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      request.write(jsonEncode(body));

      final response = await request.close();
      final raw = await response.transform(utf8.decoder).join();
      final data = jsonDecode(raw) as Map<String, dynamic>;

      if (data.containsKey('error')) {
        throw Exception('Gemini error: ${(data['error'] as Map)['message']}');
      }

      final text = (((data['candidates'] as List).first as Map)['content']
              as Map)['parts'][0]['text'] as String;
      return text.trim();
    } finally {
      client.close();
    }
  }
}
