import 'package:juanshooter/domain/entities/pilot_identity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

abstract class PilotLocalDataSource {
  Future<PilotIdentity> loadOrCreate();
  Future<PilotIdentity> saveCallSign(String callSign);
}

class PilotLocalDataSourceImpl implements PilotLocalDataSource {
  PilotLocalDataSourceImpl(this._prefs, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  static const _idKey = 'pilot.id';
  static const _callSignKey = 'pilot.call_sign';

  final SharedPreferences _prefs;
  final Uuid _uuid;

  @override
  Future<PilotIdentity> loadOrCreate() async {
    var id = _prefs.getString(_idKey);
    if (id == null || id.isEmpty) {
      id = _uuid.v4();
      await _prefs.setString(_idKey, id);
    }
    var callSign = _prefs.getString(_callSignKey);
    if (callSign == null || callSign.trim().isEmpty) {
      callSign = 'MINER-${id.substring(0, 4).toUpperCase()}';
      await _prefs.setString(_callSignKey, callSign);
    }
    return PilotIdentity(id: id, callSign: callSign);
  }

  @override
  Future<PilotIdentity> saveCallSign(String callSign) async {
    final current = await loadOrCreate();
    final next = callSign.trim().toUpperCase();
    await _prefs.setString(_callSignKey, next);
    return current.copyWith(callSign: next);
  }
}
