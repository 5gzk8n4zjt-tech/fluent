import '../../../../core/constants/supabase_client.dart';

class StatsDataSource {
  /// Computes stats from existing tables — no separate user_stats table needed.
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    final progressRows = await supabase
        .from('user_card_progress')
        .select('repetitions, last_reviewed')
        .eq('user_id', userId);

    final totalReviewed = progressRows.length;
    final learned =
        progressRows.where((r) => (r['repetitions'] as int? ?? 0) > 0).length;

    DateTime? lastActive;
    for (final r in progressRows) {
      if (r['last_reviewed'] == null) continue;
      final d = DateTime.parse(r['last_reviewed'] as String);
      if (lastActive == null || d.isAfter(lastActive)) lastActive = d;
    }

    final sessionRows = await supabase
        .from('chat_sessions')
        .select('id')
        .eq('user_id', userId);

    return {
      'total_cards_reviewed': totalReviewed,
      'cards_learned': learned,
      'total_sessions': sessionRows.length,
      'last_active': lastActive?.toIso8601String(),
    };
  }

  /// Returns a map of {level: count} for cards with repetitions > 0.
  Future<Map<String, int>> getProgressByLevel(String userId) async {
    try {
      final rows = await supabase
          .from('user_card_progress')
          .select('flashcards!inner(deck_id, decks!inner(level))')
          .eq('user_id', userId)
          .gt('repetitions', 0);

      final counts = <String, int>{};
      for (final row in rows) {
        final flashcard = row['flashcards'] as Map<String, dynamic>?;
        if (flashcard == null) continue;
        final deck = flashcard['decks'] as Map<String, dynamic>?;
        if (deck == null) continue;
        final level = (deck['level'] as String).toLowerCase();
        counts[level] = (counts[level] ?? 0) + 1;
      }
      return counts;
    } catch (_) {
      return {};
    }
  }

  /// Groups card reviews by UTC date for the last 7 days.
  Future<List<Map<String, dynamic>>> getWeeklyActivity(String userId) async {
    final since =
        DateTime.now().toUtc().subtract(const Duration(days: 7)).toIso8601String();

    final rows = await supabase
        .from('user_card_progress')
        .select('last_reviewed')
        .eq('user_id', userId)
        .gte('last_reviewed', since)
        .not('last_reviewed', 'is', null);

    final counts = <String, int>{};
    for (final row in rows) {
      final day = (row['last_reviewed'] as String).substring(0, 10);
      counts[day] = (counts[day] ?? 0) + 1;
    }

    return counts.entries
        .map((e) => {'day': e.key, 'count': e.value})
        .toList()
      ..sort((a, b) => (a['day'] as String).compareTo(b['day'] as String));
  }

  Future<List<Map<String, dynamic>>> getSessionHistory(
      String userId, int limit) async {
    return supabase
        .from('chat_sessions')
        .select('id, topic, started_at')
        .eq('user_id', userId)
        .order('started_at', ascending: false)
        .limit(limit);
  }
}
