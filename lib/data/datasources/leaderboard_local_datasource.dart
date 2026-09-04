import 'dart:convert';

import 'package:juanshooter/core/error/app_failure.dart';
import 'package:juanshooter/data/models/submitted_score_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LeaderboardLocalDataSource {
  Future<List<SubmittedScoreDto>> loadCachedRuns();
  Future<void> saveRun(SubmittedScoreDto run);
}

class LeaderboardLocalDataSourceImpl implements LeaderboardLocalDataSource {
  LeaderboardLocalDataSourceImpl(this._prefs);

  static const _key = 'leaderboard.local_runs';
  final SharedPreferences _prefs;

  @override
  Future<List<SubmittedScoreDto>> loadCachedRuns() async {
    try {
      final raw = _prefs.getString(_key);
      if (raw == null || raw.isEmpty) return const [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((item) => SubmittedScoreDto.fromCache(Map<String, dynamic>.from(item)))
          .toList();
    } catch (error) {
      throw CacheFailure('Could not read local runs', cause: error);
    }
  }

  @override
  Future<void> saveRun(SubmittedScoreDto run) async {
    try {
      final existing = await loadCachedRuns();
      final next = [...existing, run];
      await _prefs.setString(
        _key,
        jsonEncode(next.map((e) => e.toCacheJson()).toList()),
      );
    } catch (error) {
      if (error is AppFailure) rethrow;
      throw CacheFailure('Could not persist local run', cause: error);
    }
  }
}
