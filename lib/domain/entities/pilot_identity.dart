class PilotIdentity {
  const PilotIdentity({
    required this.id,
    required this.callSign,
  });

  final String id;
  final String callSign;

  PilotIdentity copyWith({String? id, String? callSign}) {
    return PilotIdentity(
      id: id ?? this.id,
      callSign: callSign ?? this.callSign,
    );
  }
}
