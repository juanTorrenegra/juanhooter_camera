import 'package:juanshooter/domain/entities/pilot_identity.dart';

abstract class PilotRepository {
  Future<PilotIdentity> current();
  Future<PilotIdentity> updateCallSign(String callSign);
}
