import '../../../../core/constants/supabase_client.dart';

class SupabaseFlashcardDatasource {
  Future<Map<String, dynamic>> getDeckById(String deckId) async {
    final result = await supabase
        .from('decks')
        .select()
        .eq('id', deckId)
        .single();
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllDecks() async {
    return supabase.from('decks').select();
  }

  Future<Map<String, dynamic>> createDeck(
      String title, String level, String topic) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('No authenticated user');
    return supabase
        .from('decks')
        .insert({
          'title': title,
          'level': level,
          'topic': topic,
          'is_predefined': false,
          'created_by': userId,
        })
        .select()
        .single();
  }

  Future<void> deleteDeck(String deckId) async {
    await supabase.from('decks').delete().eq('id', deckId);
  }

  Future<List<Map<String, dynamic>>> getFlashcardsByDeck(String deckId) async {
    return supabase
        .from('flashcards')
        .select()
        .eq('deck_id', deckId)
        .order('created_at');
  }

  Future<Map<String, dynamic>> addFlashcardToDeck(
    String deckId,
    String word,
    String translation, {
    String? audioUrl,
    String? imageUrl,
  }) async {
    return supabase
        .from('flashcards')
        .insert({
          'deck_id': deckId,
          'word': word,
          'translation': translation,
          'audio_url': audioUrl,
          'image_url': imageUrl,
        })
        .select()
        .single();
  }

  Future<void> deleteFlashcard(String flashcardId) async {
    await supabase.from('flashcards').delete().eq('id', flashcardId);
  }

  Future<List<Map<String, dynamic>>> getDueCards(
      String userId, String deckId) async {
    // Fetch all due progress records and filter by deck in Dart
    final result = await supabase
        .from('user_card_progress')
        .select('*, flashcards!inner(id, deck_id)')
        .eq('user_id', userId)
        .lte('next_review', DateTime.now().toUtc().toIso8601String());

    return result
        .where((row) =>
            (row['flashcards'] as Map<String, dynamic>)['deck_id'] == deckId)
        .map((row) {
          final map = Map<String, dynamic>.from(row)..remove('flashcards');
          return map;
        })
        .toList();
  }

  Future<Map<String, dynamic>?> getProgressByCard(
      String userId, String flashcardId) async {
    return supabase
        .from('user_card_progress')
        .select()
        .eq('user_id', userId)
        .eq('flashcard_id', flashcardId)
        .maybeSingle();
  }

  Future<void> updateProgress(Map<String, dynamic> progressData) async {
    await supabase
        .from('user_card_progress')
        .upsert(progressData, onConflict: 'id');
  }
}
