class LeaderboardEntry {
  const LeaderboardEntry({
    required this.pilotId,
    required this.callSign,
    required this.faction,
    required this.score,
    required this.isLocalPilot,
    this.remoteRecordId,
  });

  final String pilotId;
  final String callSign;
  final String faction;
  final int score;
  final bool isLocalPilot;
  final String? remoteRecordId;
}
