import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/chat_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/services/mistral_service.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/services/ai_service.dart';

// ── Infrastructure providers ───────────────────────────────────────────────

final chatDataSourceProvider = Provider<ChatDataSource>(
  (_) => ChatDataSource(),
);

final mistralServiceProvider = Provider<AIService>(
  (_) {
    final apiKey = dotenv.env['MISTRAL_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('MISTRAL_API_KEY not found in .env');
    }
    return MistralService(apiKey);
  },
);

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepositoryImpl(ref.watch(chatDataSourceProvider)),
);

// ── Query providers ────────────────────────────────────────────────────────

final userSessionsProvider =
    FutureProvider.family<List<dynamic>, String>((ref, userId) {
  return ref.read(chatRepositoryProvider).getUserSessions(userId);
});

final chatSessionProvider =
    FutureProvider.family<dynamic, String>((ref, sessionId) {
  return ref.read(chatRepositoryProvider).getSession(sessionId);
});

final learnedWordsProvider =
    FutureProvider.family<List<String>, String>((ref, userId) {
  return ref.read(chatRepositoryProvider).getLearnedWords(userId);
});

// ── Chat session state ─────────────────────────────────────────────────────

class ChatState {
  const ChatState({
    this.messages = const [],
    this.isSending = false,
    this.isRecording = false,
    this.error,
    this.sessionId,
    this.topic = 'Ordering food at a restaurant',
    this.userLevel = 'A1',
  });

  final List<ChatMessageEntity> messages;
  final bool isSending;
  final bool isRecording;
  final String? error;
  final String? sessionId;
  final String topic;
  final String userLevel;

  bool get isReady => sessionId != null;

  ChatState copyWith({
    List<ChatMessageEntity>? messages,
    bool? isSending,
    bool? isRecording,
    String? error,
    String? sessionId,
    String? topic,
    String? userLevel,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isSending: isSending ?? this.isSending,
        isRecording: isRecording ?? this.isRecording,
        error: error,
        sessionId: sessionId ?? this.sessionId,
        topic: topic ?? this.topic,
        userLevel: userLevel ?? this.userLevel,
      );
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._repo, this._ai) : super(const ChatState());

  final ChatRepository _repo;
  final AIService _ai;

  Future<void> initSession(String userId,
      {String topic = 'Ordering food at a restaurant',
      String userLevel = 'A1'}) async {
    state = ChatState(topic: topic, userLevel: userLevel);
    try {
      final session = await _repo.createSession(userId, topic);
      state = state.copyWith(sessionId: session.id, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> sendMessage(
      String text, List<String> learnedWords) async {
    final sessionId = state.sessionId;
    if (sessionId == null || text.trim().isEmpty || state.isSending) return;

    state = state.copyWith(isSending: true, error: null);

    try {
      final userMsg =
          await _repo.addMessage(sessionId, 'user', text.trim());
      final withUser = [...state.messages, userMsg];
      state = state.copyWith(messages: withUser);

      final reply = await _ai.generateResponse(
        messages: withUser,
        learnedWords: learnedWords,
        topic: state.topic,
        userLevel: state.userLevel,
      );

      final aiMsg =
          await _repo.addMessage(sessionId, 'assistant', reply);
      state = state.copyWith(
        messages: [...withUser, aiMsg],
        isSending: false,
      );
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }

  Future<void> recordAudio(String audioPath, List<String> learnedWords) async {
    try {
      final text = await _ai.transcribeAudio(audioPath);
      if (text.isNotEmpty) await sendMessage(text, learnedWords);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setRecording(bool value) =>
      state = state.copyWith(isRecording: value);

  void reset() => state = const ChatState();
}

final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(
    ref.watch(chatRepositoryProvider),
    ref.watch(mistralServiceProvider),
  ),
);
