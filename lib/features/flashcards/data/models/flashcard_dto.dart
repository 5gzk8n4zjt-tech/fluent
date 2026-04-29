import '../../domain/entities/flashcard_entity.dart';

class FlashcardDTO {
  const FlashcardDTO({
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
  final String createdAt;

  factory FlashcardDTO.fromJson(Map<String, dynamic> json) => FlashcardDTO.fromMap(json);

  factory FlashcardDTO.fromMap(Map<String, dynamic> map) => FlashcardDTO(
        id: map['id'] as String,
        deckId: map['deck_id'] as String,
        word: map['word'] as String,
        translation: map['translation'] as String,
        audioUrl: map['audio_url'] as String?,
        imageUrl: map['image_url'] as String?,
        createdAt: map['created_at'] as String,
      );

  FlashcardEntity toEntity() => FlashcardEntity(
        id: id,
        deckId: deckId,
        word: word,
        translation: translation,
        audioUrl: audioUrl,
        imageUrl: imageUrl,
        createdAt: DateTime.parse(createdAt),
      );
}
