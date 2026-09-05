import 'package:juanshooter/data/datasources/pilot_local_datasource.dart';
import 'package:juanshooter/domain/entities/pilot_identity.dart';
import 'package:juanshooter/domain/repositories/pilot_repository.dart';

class PilotRepositoryImpl implements PilotRepository {
  PilotRepositoryImpl(this._local);

  final PilotLocalDataSource _local;

  @override
  Future<PilotIdentity> current() => _local.loadOrCreate();

  @override
  Future<PilotIdentity> updateCallSign(String callSign) {
    return _local.saveCallSign(callSign);
  }

  @override
  Future<void> signOut() => _local.clearSession();
}
