import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:juanshooter/game.dart';

/// Charge shot: 9 damage tiers over 3 seconds (tap → 4, 1s → 9, 2s → 20, 3s → 50).
class ChargeShot {
  static const double maxChargeSeconds = 3.0;
  static const double drainSeconds = 0.22;
  static const double speedPenalty = 20;

  /// 8 listed values plus 40 so there are 9 tiers (3 normal + 5 double + 1 triple).
  static const List<int> damageTiers = [4, 6, 9, 12, 15, 20, 30, 40, 50];

  static int _tierIndex(double holdSeconds) {
    if (holdSeconds >= maxChargeSeconds) {
      return damageTiers.length - 1;
    }
    final t = (holdSeconds / maxChargeSeconds).clamp(0.0, 1.0);
    return (t * (damageTiers.length - 1)).floor().clamp(
      0,
      damageTiers.length - 1,
    );
  }

  static int damageForHoldTime(double holdSeconds) =>
      damageTiers[_tierIndex(holdSeconds)];

  /// First 3 tiers: 1x. Next 5: 2x. Maximum: 3x.
  static double sizeScaleForHoldTime(double holdSeconds) {
    final index = _tierIndex(holdSeconds);
    if (index >= 8) return 3;
    if (index >= 3) return 2;
    return 1;
  }

  /// Shot SFX: tap–1s `fire_2`, 1–3s `simpleShot`, full charge `shotBigEnd`.
  static String shotSoundForHoldTime(double holdSeconds) {
    if (holdSeconds >= maxChargeSeconds) return 'shotBigEnd.mp3';
    if (holdSeconds >= 1.0) return 'simpleShot.mp3';
    return 'fire_2.mp3';
  }
}

class ChargeShotResult {
  final int damage;
  final double sizeScale;
  final String shotSound;

  const ChargeShotResult({
    required this.damage,
    required this.sizeScale,
    required this.shotSound,
  });
}

/// Top-center thermometer: cyan fill while charging, fast drain on release.
class PotencyBar extends PositionComponent with HasGameReference<MyGame> {
  static const double _borderRadius = 10;
  static const double _strokeWidth = 2.5;
  static const String _chargeSoundFile = 'carga3s.mp3';
  static const String _sustainSoundFile = 'carga5ms.mp3';
  static const double _chargeSoundStartSeconds = 0.5;

  double _fill = 0;
  double _holdSeconds = 0;
  bool _charging = false;
  bool _draining = false;

  AudioPlayer? _chargePlayer;
  AudioPlayer? _sustainPlayer;
  int _chargeSoundGen = 0;
  bool _sustainLooping = false;
  bool _chargeSoundStarted = false;

  bool get isCharging => _charging;

  PotencyBar({Vector2? size})
    : super(
        size: size ?? Vector2(400, 18),
        anchor: Anchor.topLeft,
        priority: 80,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    unawaited(
      FlameAudio.audioCache.loadAll([
        _chargeSoundFile,
        _sustainSoundFile,
        'simpleShot.mp3',
        'shotBigEnd.mp3',
      ]),
    );
  }

  @override
  void onRemove() {
    _stopChargeSound();
    super.onRemove();
  }

  void beginCharge() {
    _charging = true;
    _draining = false;
    _holdSeconds = 0;
    _fill = 0;
    _sustainLooping = false;
    _chargeSoundStarted = false;
  }

  ChargeShotResult? releaseCharge() {
    if (!_charging) return null;
    final result = ChargeShotResult(
      damage: ChargeShot.damageForHoldTime(_holdSeconds),
      sizeScale: ChargeShot.sizeScaleForHoldTime(_holdSeconds),
      shotSound: ChargeShot.shotSoundForHoldTime(_holdSeconds),
    );
    _charging = false;
    _draining = true;
    _stopChargeSound();
    return result;
  }

  void cancelCharge() {
    _charging = false;
    _draining = _fill > 0;
    _holdSeconds = 0;
    _stopChargeSound();
  }

  void reset() {
    _charging = false;
    _draining = false;
    _holdSeconds = 0;
    _fill = 0;
    _stopChargeSound();
  }

  Future<void> _startChargeSound() async {
    final gen = ++_chargeSoundGen;
    await _chargePlayer?.stop();
    await _sustainPlayer?.stop();
    if (gen != _chargeSoundGen) return;
    try {
      final player = await FlameAudio.play(_chargeSoundFile);
      if (gen != _chargeSoundGen) {
        await player.stop();
        return;
      }
      await player.seek(
        Duration(milliseconds: (_chargeSoundStartSeconds * 1000).round()),
      );
      if (gen != _chargeSoundGen) {
        await player.stop();
        return;
      }
      _chargePlayer = player;
    } catch (_) {
      // Audio is optional; charging still works if playback fails.
    }
  }

  Future<void> _startSustainLoop() async {
    if (_sustainLooping) return;
    _sustainLooping = true;
    final gen = _chargeSoundGen;
    try {
      await _chargePlayer?.stop();
      if (gen != _chargeSoundGen) return;
      final player = await FlameAudio.loop(_sustainSoundFile);
      if (gen != _chargeSoundGen) {
        await player.stop();
        return;
      }
      _sustainPlayer = player;
    } catch (_) {
      _sustainLooping = false;
    }
  }

  void _stopChargeSound() {
    _chargeSoundGen++;
    _sustainLooping = false;
    _chargeSoundStarted = false;
    final charge = _chargePlayer;
    final sustain = _sustainPlayer;
    _chargePlayer = null;
    _sustainPlayer = null;
    if (charge != null) {
      unawaited(charge.stop());
    }
    if (sustain != null) {
      unawaited(sustain.stop());
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    final realDt = dt / game.timeScale.clamp(0.001, 100.0);

    if (_charging) {
      _holdSeconds += realDt;
      _fill = (_holdSeconds / ChargeShot.maxChargeSeconds).clamp(0.0, 1.0);
      if (_holdSeconds >= _chargeSoundStartSeconds && !_chargeSoundStarted) {
        _chargeSoundStarted = true;
        unawaited(_startChargeSound());
      }
      if (_holdSeconds >= ChargeShot.maxChargeSeconds && !_sustainLooping) {
        unawaited(_startSustainLoop());
      }
      return;
    }

    if (_draining) {
      _fill -= realDt / ChargeShot.drainSeconds;
      if (_fill <= 0) {
        _fill = 0;
        _draining = false;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(_borderRadius),
    );

    if (_fill > 0) {
      final heat = _fill;
      final fillColor = Color.lerp(
        const Color.fromARGB(231, 0, 255, 170),
        const Color.fromARGB(225, 180, 255, 255),
        heat,
      )!;
      canvas.save();
      canvas.clipRRect(rrect);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x * _fill, size.y),
        Paint()..color = fillColor,
      );
      canvas.restore();
    }

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color.fromARGB(140, 244, 67, 54)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth,
    );
  }
}

/// Floating damage number above a hit enemy; lasts 1 second.
class DamagePopup extends TextComponent {
  static const double lifetime = 1.0;
  double _elapsed = 0;

  DamagePopup({required Vector2 worldPosition, required int damage})
    : super(
        text: '$damage',
        position: worldPosition,
        anchor: Anchor.center,
        priority: 2000,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontSize: 15,
            fontFamily: 'steel700',
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    position.y -= 28 * dt;
    final t = (1 - _elapsed / lifetime).clamp(0.0, 1.0);
    textRenderer = TextPaint(
      style: TextStyle(
        color: const Color.fromARGB(141, 24, 255, 255).withValues(alpha: t),
        fontSize: 10,
        fontFamily: 'steel700',
        fontWeight: FontWeight.w700,
      ),
    );
    if (_elapsed >= lifetime) {
      removeFromParent();
    }
  }
}
