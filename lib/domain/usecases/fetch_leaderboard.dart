import 'package:juanshooter/core/error/result.dart';
import 'package:juanshooter/domain/entities/leaderboard_entry.dart';
import 'package:juanshooter/domain/repositories/leaderboard_repository.dart';

class FetchLeaderboard {
  const FetchLeaderboard(this._repository);

  final LeaderboardRepository _repository;

  Future<Result<List<LeaderboardEntry>>> call({int limit = 10}) {
    return _repository.fetchTop(limit: limit);
  }
}
