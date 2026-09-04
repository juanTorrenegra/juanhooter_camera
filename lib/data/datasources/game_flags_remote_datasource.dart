import 'package:juanshooter/core/error/app_failure.dart';
import 'package:juanshooter/core/network/api_client.dart';
import 'package:juanshooter/core/network/api_config.dart';
import 'package:juanshooter/data/models/game_flags_dto.dart';

abstract class GameFlagsRemoteDataSource {
  Future<GameFlagsDto> fetch();
}

class GameFlagsRemoteDataSourceImpl implements GameFlagsRemoteDataSource {
  GameFlagsRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<GameFlagsDto> fetch() {
    return _client.get<GameFlagsDto>(
      ApiPaths.transmission,
      parse: (json) {
        if (json is! Map<String, dynamic>) {
          throw const ParseFailure('Expected a transmission object');
        }
        return GameFlagsDto.fromJson(json);
      },
    );
  }
}
