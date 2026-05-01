import '../../../../core/constants/supabase_client.dart';

class ChatDataSource {
  Future<Map<String, dynamic>> createSession(String userId, String topic) =>
      supabase
          .from('chat_sessions')
          .insert({'user_id': userId, 'topic': topic})
          .select()
          .single();

  Future<Map<String, dynamic>> getSession(String sessionId) => supabase
      .from('chat_sessions')
      .select('*, chat_messages(id, session_id, role, content, created_at)')
      .eq('id', sessionId)
      .order('created_at', referencedTable: 'chat_messages')
      .single();

  Future<List<Map<String, dynamic>>> getUserSessions(String userId) => supabase
      .from('chat_sessions')
      .select()
      .eq('user_id', userId)
      .order('started_at', ascending: false);

  Future<Map<String, dynamic>> addMessage(
          String sessionId, String role, String content) =>
      supabase
          .from('chat_messages')
          .insert({'session_id': sessionId, 'role': role, 'content': content})
          .select()
          .single();

  Future<List<String>> getLearnedWords(String userId) async {
    final result = await supabase
        .from('user_card_progress')
        .select('flashcards!inner(word)')
        .eq('user_id', userId)
        .gt('repetitions', 0);

    return result
        .map((r) => (r['flashcards'] as Map)['word'] as String)
        .toSet()
        .toList();
  }
}
