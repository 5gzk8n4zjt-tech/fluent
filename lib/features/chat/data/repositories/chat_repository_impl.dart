import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_session_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_datasource.dart';
import '../models/chat_message_dto.dart';
import '../models/chat_session_dto.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._ds);

  final ChatDataSource _ds;

  @override
  Future<ChatSessionEntity> createSession(String userId, String topic) async {
    final json = await _ds.createSession(userId, topic);
    return ChatSessionDTO.fromJson(json).toEntity();
  }

  @override
  Future<ChatSessionEntity> getSession(String sessionId) async {
    final json = await _ds.getSession(sessionId);
    return ChatSessionDTO.fromJson(json).toEntity();
  }

  @override
  Future<List<ChatSessionEntity>> getUserSessions(String userId) async {
    final list = await _ds.getUserSessions(userId);
    return list.map((j) => ChatSessionDTO.fromJson(j).toEntity()).toList();
  }

  @override
  Future<ChatMessageEntity> addMessage(
      String sessionId, String role, String content) async {
    final json = await _ds.addMessage(sessionId, role, content);
    return ChatMessageDTO.fromJson(json).toEntity();
  }

  @override
  Future<List<String>> getLearnedWords(String userId) =>
      _ds.getLearnedWords(userId);
}
