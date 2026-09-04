import 'package:juanshooter/core/error/result.dart';
import 'package:juanshooter/domain/entities/leaderboard_entry.dart';
import 'package:juanshooter/domain/entities/pilot_identity.dart';

abstract class LeaderboardRepository {
  Future<Result<List<LeaderboardEntry>>> fetchTop({int limit = 10});

  Future<Result<LeaderboardEntry>> submitScore({
    required PilotIdentity pilot,
    required int score,
  });
}
