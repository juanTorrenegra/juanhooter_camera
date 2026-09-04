/// Remote-toggled behavior + flavor text from an external service.
class GameFlags {
  const GameFlags({
    required this.leaderboardEnabled,
    required this.transmissionTitle,
    required this.transmissionBody,
    required this.fromRemote,
  });

  final bool leaderboardEnabled;
  final String transmissionTitle;
  final String transmissionBody;
  final bool fromRemote;

  factory GameFlags.offlineFallback() {
    return const GameFlags(
      leaderboardEnabled: true,
      transmissionTitle: 'OUTPOST OFFLINE',
      transmissionBody: 'Local cache only. Ranking will sync when the link returns.',
      fromRemote: false,
    );
  }
}
