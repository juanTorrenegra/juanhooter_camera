import 'package:flutter_test/flutter_test.dart';
import 'package:juanshooter/core/error/app_failure.dart';
import 'package:juanshooter/data/models/json_placeholder_user_dto.dart';

void main() {
  test('maps a JSONPlaceholder user into a ranked miner', () {
    final dto = JsonPlaceholderUserDto.fromJson({
      'id': 1,
      'username': 'Bret',
      'company': {'name': 'Romaguera-Crona'},
    });

    final entry = dto.toDomain();

    expect(entry.callSign, 'BRET');
    expect(entry.faction, 'Romaguera-Crona');
    expect(entry.isLocalPilot, isFalse);
    expect(entry.score, 8713);
  });

  test('rejects a malformed user payload', () {
    expect(
      () => JsonPlaceholderUserDto.fromJson({'username': 'Bret'}),
      throwsA(isA<ParseFailure>()),
    );
  });
}
