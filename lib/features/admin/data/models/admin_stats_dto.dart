import '../../domain/entities/admin_entity.dart';

class AdminStatsDTO {
  const AdminStatsDTO({
    required this.totalUsers,
    required this.activeToday,
    required this.totalCardsReviewed,
    required this.totalDecksCreated,
  });

  final int totalUsers;
  final int activeToday;
  final int totalCardsReviewed;
  final int totalDecksCreated;

  factory AdminStatsDTO.fromJson(Map<String, dynamic> json) => AdminStatsDTO(
        totalUsers: json['total_users'] as int? ?? 0,
        activeToday: json['active_today'] as int? ?? 0,
        totalCardsReviewed: json['total_cards_reviewed'] as int? ?? 0,
        totalDecksCreated: json['total_decks_created'] as int? ?? 0,
      );

  AdminStatsEntity toEntity() => AdminStatsEntity(
        totalUsers: totalUsers,
        activeToday: activeToday,
        totalCardsReviewed: totalCardsReviewed,
        totalDecksCreated: totalDecksCreated,
      );
}
