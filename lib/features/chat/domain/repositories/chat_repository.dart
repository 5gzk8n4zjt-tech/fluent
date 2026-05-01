import '../entities/chat_message_entity.dart';
import '../entities/chat_session_entity.dart';

abstract class ChatRepository {
  Future<ChatSessionEntity> createSession(String userId, String topic);

  Future<ChatSessionEntity> getSession(String sessionId);

  Future<List<ChatSessionEntity>> getUserSessions(String userId);

  Future<ChatMessageEntity> addMessage(String sessionId, String role, String content);

  /// Returns all words the user has learned via flashcards.
  Future<List<String>> getLearnedWords(String userId);
}
