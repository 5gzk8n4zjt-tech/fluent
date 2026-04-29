enum Level { a1, a2, b1, b2 }

extension LevelExtension on Level {
  String get code => name.toUpperCase();

  static Level fromString(String value) {
    return Level.values.firstWhere(
      (l) => l.name == value.toLowerCase(),
      orElse: () => Level.a1,
    );
  }
}
