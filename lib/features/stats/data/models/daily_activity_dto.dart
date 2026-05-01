import '../../domain/entities/stats_entity.dart';

class DailyActivityDTO {
  const DailyActivityDTO({required this.day, required this.count});

  final String day; // 'YYYY-MM-DD'
  final int count;

  factory DailyActivityDTO.fromJson(Map<String, dynamic> json) =>
      DailyActivityDTO(
        day: json['day'] as String,
        count: json['count'] as int? ?? 0,
      );

  DailyStats toEntity() => DailyStats(
        day: DateTime.parse(day),
        count: count,
      );
}
