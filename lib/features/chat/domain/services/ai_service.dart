import '../entities/chat_message_entity.dart';

abstract class AIService {
  /// Generates an AI response given conversation history, learned vocabulary, and topic.
  ///
  /// The model is instructed to:
  /// - Respond in English about [topic]
  /// - Incorporate [learnedWords] naturally when relevant
  /// - Keep replies to 2-3 sentences max
  /// - Subtly correct grammatical errors made by the user
  Future<String> generateResponse({
    required List<ChatMessageEntity> messages,
    required List<String> learnedWords,
    required String topic,
  });

  /// Transcribes audio from [audioPath] to text.
  Future<String> transcribeAudio(String audioPath);
}
