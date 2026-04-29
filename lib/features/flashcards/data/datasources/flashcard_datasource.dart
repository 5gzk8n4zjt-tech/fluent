import '../../../../core/constants/supabase_client.dart';

class FlashcardDataSource {
  Future<Map<String, dynamic>> getDeckById(String deckId) =>
      supabase.from('decks').select().eq('id', deckId).single();

  Future<List<Map<String, dynamic>>> getAllDecks() =>
      supabase.from('decks').select().order('level').order('title');

  Future<Map<String, dynamic>> createDeck(
      String title, String level, String topic) {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('No authenticated user');
    return supabase
        .from('decks')
        .insert({'title': title, 'level': level, 'topic': topic, 'is_predefined': false, 'created_by': userId})
        .select()
        .single();
  }

  Future<void> deleteDeck(String deckId) =>
      supabase.from('decks').delete().eq('id', deckId);

  Future<List<Map<String, dynamic>>> getFlashcardsByDeck(String deckId) =>
      supabase.from('flashcards').select().eq('deck_id', deckId).order('created_at');

  Future<Map<String, dynamic>> addFlashcardToDeck(
      String deckId, String word, String translation,
      {String? audioUrl, String? imageUrl}) =>
      supabase
          .from('flashcards')
          .insert({'deck_id': deckId, 'word': word, 'translation': translation, 'audio_url': audioUrl, 'image_url': imageUrl})
          .select()
          .single();

  Future<void> deleteFlashcard(String flashcardId) =>
      supabase.from('flashcards').delete().eq('id', flashcardId);

  Future<List<Map<String, dynamic>>> getDueCards(
      String userId, String deckId) async {
    final result = await supabase
        .from('user_card_progress')
        .select('*, flashcards!inner(id, deck_id)')
        .eq('user_id', userId)
        .lte('next_review', DateTime.now().toUtc().toIso8601String());

    return result
        .where((r) => (r['flashcards'] as Map)['deck_id'] == deckId)
        .map((r) => Map<String, dynamic>.from(r)..remove('flashcards'))
        .toList();
  }

  Future<void> updateProgress(String progressId, Map<String, dynamic> data) =>
      supabase.from('user_card_progress').upsert({...data, 'id': progressId}, onConflict: 'id');

  Future<Map<String, dynamic>?> getProgressByCard(
      String userId, String flashcardId) =>
      supabase
          .from('user_card_progress')
          .select()
          .eq('user_id', userId)
          .eq('flashcard_id', flashcardId)
          .maybeSingle();
}
