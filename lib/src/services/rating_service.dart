import 'dart:math';

class RatingService {
  // Simple deterministic Elo implementation
  static const int kFactor = 32;

  /// Calculate new ratings for two teams based on match outcome
  /// [scoreA] and [scoreB] are the raw scores
  /// Returns a tuple of (newRatingA, newRatingB)
  static (int, int) calculateNewRatings({
    required int ratingA,
    required int ratingB,
    required int scoreA,
    required int scoreB,
  }) {
    final expectedA = 1 / (1 + pow(10, (ratingB - ratingA) / 400));
    final expectedB = 1 / (1 + pow(10, (ratingA - ratingB) / 400));
    
    double actualA;
    if (scoreA > scoreB) {
      actualA = 1.0;
    } else if (scoreA < scoreB) {
      actualA = 0.0;
    } else {
      actualA = 0.5;
    }
    
    final newRatingA = (ratingA + kFactor * (actualA - expectedA)).round();
    final newRatingB = (ratingB + kFactor * ((1 - actualA) - expectedB)).round();
    
    return (newRatingA, newRatingB);
  }

  /// Predict win probability for Team A against Team B
  static double predictWinProbability(int ratingA, int ratingB) {
    return 1 / (1 + pow(10, (ratingB - ratingA) / 400));
  }
}
