import 'package:juanshooter/core/error/result.dart';
import 'package:juanshooter/domain/entities/game_flags.dart';
import 'package:juanshooter/domain/repositories/game_flags_repository.dart';

class FetchGameFlags {
  const FetchGameFlags(this._repository);

  final GameFlagsRepository _repository;

  Future<Result<GameFlags>> call() => _repository.fetch();
}
