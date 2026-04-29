import '../entities/card_progress_entity.dart';

class SRSAlgorithm {
  // grade: 0=Otra vez, 1=Difícil, 2=Neutral, 3=Bien, 4=Fácil, 5=Muy fácil
  CardProgressEntity calculateNextReview(
      CardProgressEntity progress, int grade) {
    assert(grade >= 0 && grade <= 5, 'grade debe estar entre 0 y 5');

    final now = DateTime.now();

    if (grade < 3) {
      // Respuesta incorrecta: reiniciar repeticiones, revisar mañana
      return progress.copyWith(
        repetitions: 0,
        intervalDays: 1,
        nextReview: now.add(const Duration(days: 1)),
        lastReviewed: now,
      );
    }

    // Respuesta correcta: actualizar easeFactor e intervalo
    final newEaseFactor = (progress.easeFactor +
            (0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02)))
        .clamp(1.3, 5.0);

    final int newInterval;
    if (progress.repetitions == 0) {
      newInterval = 1;
    } else if (progress.repetitions == 1) {
      newInterval = 3;
    } else {
      newInterval = (newEaseFactor * progress.intervalDays).round();
    }

    return progress.copyWith(
      easeFactor: newEaseFactor,
      intervalDays: newInterval,
      repetitions: progress.repetitions + 1,
      nextReview: now.add(Duration(days: newInterval)),
      lastReviewed: now,
    );
  }
}
