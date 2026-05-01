import '../value_objects/conversation_level.dart';

class ConversationTopicEntity {
  const ConversationTopicEntity({
    required this.id,
    required this.title,
    required this.level,
    required this.description,
  });

  final String id;
  final String title;
  final ConversationLevel level;
  final String description;
}
