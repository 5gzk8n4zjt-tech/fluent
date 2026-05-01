enum ConversationLevel { a1, a2, b1, b2 }

extension ConversationLevelExtension on ConversationLevel {
  String get code => name.toUpperCase();

  static ConversationLevel fromString(String value) =>
      ConversationLevel.values.firstWhere(
        (l) => l.name == value.toLowerCase(),
        orElse: () => ConversationLevel.a1,
      );
}
