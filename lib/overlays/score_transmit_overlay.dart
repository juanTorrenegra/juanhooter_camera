import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juanshooter/core/di/providers.dart';
import 'package:juanshooter/game.dart';

class ScoreTransmitOverlay extends ConsumerWidget {
  const ScoreTransmitOverlay({required this.game, super.key});

  final MyGame game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submit = ref.watch(scoreSubmitControllerProvider);
    final message = switch (submit) {
      ScoreSubmitIdle() => '',
      ScoreSubmitInFlight(:final score) => 'TRANSMITTING SCORE $score…',
      ScoreSubmitSuccess(:final entry) =>
        'SCORE LOGGED  ·  ${entry.callSign}  ${entry.score}',
      ScoreSubmitFailure(:final message) => 'TRANSMIT FAILED  ·  $message',
    };
    if (message.isEmpty) return const SizedBox.shrink();

    final color = switch (submit) {
      ScoreSubmitFailure() => Colors.orangeAccent,
      ScoreSubmitSuccess() => Colors.cyanAccent,
      _ => Colors.white70,
    };

    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              border: Border.all(color: color.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Text(
                message,
                style: TextStyle(
                  color: color,
                  fontFamily: 'Megatrans',
                  fontSize: 13,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
