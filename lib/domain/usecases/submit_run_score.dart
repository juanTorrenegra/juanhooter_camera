import 'package:juanshooter/core/error/result.dart';
import 'package:juanshooter/domain/entities/leaderboard_entry.dart';
import 'package:juanshooter/domain/entities/pilot_identity.dart';
import 'package:juanshooter/domain/repositories/leaderboard_repository.dart';

class SubmitRunScore {
  const SubmitRunScore(this._repository);

  final LeaderboardRepository _repository;

  Future<Result<LeaderboardEntry>> call({
    required PilotIdentity pilot,
    required int score,
  }) {
    return _repository.submitScore(pilot: pilot, score: score);
  }
}
