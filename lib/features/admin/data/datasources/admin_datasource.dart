import '../../../../core/constants/supabase_client.dart';

class AdminDataSource {
  Future<List<Map<String, dynamic>>> getAllDecks() => supabase
      .from('decks')
      .select()
      .eq('is_predefined', true)
      .order('level')
      .order('title');

  Future<Map<String, dynamic>> createDeck(
      String title, String level, String topic) {
    final userId = supabase.auth.currentUser?.id ?? 'system';
    return supabase
        .from('decks')
        .insert({
          'title': title,
          'level': level,
          'topic': topic,
          'is_predefined': true,
          'created_by': userId,
        })
        .select()
        .single();
  }

  Future<Map<String, dynamic>> updateDeck(
      String deckId, String title, String level, String topic) =>
      supabase
          .from('decks')
          .update({'title': title, 'level': level, 'topic': topic})
          .eq('id', deckId)
          .select()
          .single();

  Future<void> deleteDeck(String deckId) =>
      supabase.from('decks').delete().eq('id', deckId);

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await supabase
        .from('users')
        .select()
        .order('created_at', ascending: false);
  }

  Future<Map<String, dynamic>> getAdminStats() async {
    final todayUtc = DateTime.now().toUtc();
    final todayStr =
        '${todayUtc.year}-${todayUtc.month.toString().padLeft(2, '0')}-${todayUtc.day.toString().padLeft(2, '0')}T00:00:00Z';

    final results = await Future.wait<List<Map<String, dynamic>>>([
      supabase.from('users').select('id'),
      supabase
          .from('user_card_progress')
          .select('user_id')
          .gte('last_reviewed', todayStr),
      supabase.from('user_card_progress').select('id'),
      supabase.from('decks').select('id').eq('is_predefined', true),
    ]);

    final activeToday = results[1].map((r) => r['user_id']).toSet().length;

    return {
      'total_users': results[0].length,
      'active_today': activeToday,
      'total_cards_reviewed': results[2].length,
      'total_decks_created': results[3].length,
    };
  }
}
