import '../../domain/entities/conversation_topic_entity.dart';
import '../../domain/value_objects/conversation_level.dart';

class ConversationTopicDTO {
  const ConversationTopicDTO({
    required this.id,
    required this.title,
    required this.level,
    required this.description,
  });

  final String id;
  final String title;
  final String level;
  final String description;

  factory ConversationTopicDTO.fromJson(Map<String, dynamic> json) =>
      ConversationTopicDTO(
        id: json['id'] as String,
        title: json['title'] as String,
        level: json['level'] as String,
        description: json['description'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'level': level,
        'description': description,
      };

  ConversationTopicEntity toEntity() => ConversationTopicEntity(
        id: id,
        title: title,
        level: ConversationLevelExtension.fromString(level),
        description: description,
      );
}
