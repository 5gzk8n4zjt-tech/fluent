class FlashcardEntity {
  const FlashcardEntity({
    required this.id,
    required this.deckId,
    required this.word,
    required this.translation,
    required this.createdAt,
    this.audioUrl,
    this.imageUrl,
  });

  final String id;
  final String deckId;
  final String word;
  final String translation;
  final String? audioUrl;
  final String? imageUrl;
  final DateTime createdAt;

  factory FlashcardEntity.fromMap(Map<String, dynamic> map) => FlashcardEntity(
        id: map['id'] as String,
        deckId: map['deck_id'] as String,
        word: map['word'] as String,
        translation: map['translation'] as String,
        audioUrl: map['audio_url'] as String?,
        imageUrl: map['image_url'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'deck_id': deckId,
        'word': word,
        'translation': translation,
        'audio_url': audioUrl,
        'image_url': imageUrl,
        'created_at': createdAt.toIso8601String(),
      };
}
