import 'package:juanshooter/core/error/app_failure.dart';
import 'package:juanshooter/core/network/api_client.dart';
import 'package:juanshooter/core/network/api_config.dart';
import 'package:juanshooter/data/models/json_placeholder_user_dto.dart';
import 'package:juanshooter/data/models/submitted_score_dto.dart';

abstract class LeaderboardRemoteDataSource {
  Future<List<JsonPlaceholderUserDto>> fetchPilots();
  Future<SubmittedScoreDto> submitScore(SubmittedScoreDto request);
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  LeaderboardRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<JsonPlaceholderUserDto>> fetchPilots() {
    return _client.get<List<JsonPlaceholderUserDto>>(
      ApiPaths.users,
      parse: (json) {
        if (json is! List) {
          throw const ParseFailure('Expected a list of pilots');
        }
        return json
            .whereType<Map>()
            .map((item) => JsonPlaceholderUserDto.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList();
      },
    );
  }

  @override
  Future<SubmittedScoreDto> submitScore(SubmittedScoreDto request) {
    return _client.post<SubmittedScoreDto>(
      ApiPaths.posts,
      body: request.toJson(),
      parse: (json) {
        if (json is! Map<String, dynamic>) {
          throw const ParseFailure('Expected a score receipt object');
        }
        final echoed = SubmittedScoreDto.fromJson({
          ...request.toCacheJson(),
          'id': json['id'],
        });
        return echoed;
      },
    );
  }
}
