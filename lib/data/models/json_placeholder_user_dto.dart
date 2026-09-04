import 'package:juanshooter/core/error/app_failure.dart';
import 'package:juanshooter/domain/entities/leaderboard_entry.dart';

class JsonPlaceholderUserDto {
  const JsonPlaceholderUserDto({
    required this.id,
    required this.username,
    required this.companyName,
  });

  final int id;
  final String username;
  final String companyName;

  factory JsonPlaceholderUserDto.fromJson(Map<String, dynamic> json) {
    final company = json['company'];
    if (json['id'] is! int || json['username'] is! String) {
      throw const ParseFailure('User payload missing id or username');
    }
    final companyName = company is Map
        ? (Map<String, dynamic>.from(company)['name'] as String? ??
            'Unknown faction')
        : 'Unknown faction';
    return JsonPlaceholderUserDto(
      id: json['id'] as int,
      username: json['username'] as String,
      companyName: companyName,
    );
  }

  /// JSONPlaceholder has no scores; we project a stable ranking from user id
  /// so the REST mapping is deterministic in demos and tests.
  LeaderboardEntry toDomain() {
    return LeaderboardEntry(
      pilotId: 'jp-user-$id',
      callSign: username.toUpperCase(),
      faction: companyName,
      score: (11 - id).clamp(1, 10) * 870 + id * 13,
      isLocalPilot: false,
      remoteRecordId: '$id',
    );
  }
}
