class AdminStatsEntity {
  const AdminStatsEntity({
    required this.totalUsers,
    required this.activeToday,
    required this.totalCardsReviewed,
    required this.totalDecksCreated,
  });

  final int totalUsers;
  final int activeToday;
  final int totalCardsReviewed;
  final int totalDecksCreated;
}
