import '../../domain/entities/stats_entity.dart';

class SessionSummaryDTO {
  const SessionSummaryDTO({
    required this.id,
    required this.startedAt,
    required this.topic,
    this.messageCount = 0,
  });

  final String id;
  final String startedAt;
  final String topic;
  final int messageCount;

  factory SessionSummaryDTO.fromJson(Map<String, dynamic> json) =>
      SessionSummaryDTO(
        id: json['id'] as String,
        startedAt: json['started_at'] as String,
        topic: json['topic'] as String,
        messageCount: json['message_count'] as int? ?? 0,
      );

  SessionSummary toEntity() => SessionSummary(
        id: id,
        startedAt: DateTime.parse(startedAt),
        topic: topic,
        messageCount: messageCount,
      );
}
