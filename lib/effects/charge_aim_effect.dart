import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:juanshooter/game.dart';
import 'package:juanshooter/hud/potency_bar.dart';
import 'package:juanshooter/utils/game_utils.dart';

/// Charge VFX on the ship's nose: inbound dots → small core → pulsing full ball.
class ChargeAimEffect extends PositionComponent with HasGameReference<MyGame> {
  static const double _stage1End = 1.0;
  static const double _stage2End = 2.0;
  static const double _fullRadius = 6.0;

  final Random _rng = Random();
  double _spawnAcc = 0;
  double _pulsePhase = 0;
  double _coreRadius = 0;
  double _pulse = 1;
  bool _wasCharging = false;

  ChargeAimEffect()
    : super(
        anchor: Anchor.center,
        priority: 20,
      );

  void _followMuzzle() {
    final player = game.player;
    if (!player.isMounted) return;
    position.setFrom(
      calculateShootPosition(player.position, player.angle, player.size, 10),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _followMuzzle();
    final bar = game.hud.potencyBar;
    if (!bar.isCharging) {
      if (_wasCharging) {
        _reset();
      }
      return;
    }
    _wasCharging = true;
    final hold = bar.holdSeconds;
    _updateCore(hold, dt);
    _spawnDots(hold, dt);
  }

  void _updateCore(double hold, double dt) {
    if (hold < _stage1End) {
      _coreRadius = 0;
      _pulse = 1;
      return;
    }
    if (hold < _stage2End) {
      final t = ((hold - _stage1End) / (_stage2End - _stage1End)).clamp(
        0.0,
        1.0,
      );
      _coreRadius = 1.1 + 0.6 * t;
      _pulse = 0.85 + 0.15 * sin(_pulsePhase);
      _pulsePhase += dt * 5;
      return;
    }
    if (hold < ChargeShot.maxChargeSeconds) {
      final t =
          ((hold - _stage2End) / (ChargeShot.maxChargeSeconds - _stage2End))
              .clamp(0.0, 1.0);
      _coreRadius = 1.7 + (_fullRadius - 1.7) * t;
      _pulse = 0.8 + 0.2 * sin(_pulsePhase);
      _pulsePhase += dt * 6;
      return;
    }
    _coreRadius = _fullRadius;
    _pulsePhase += dt * 8;
    _pulse = 0.55 + 0.45 * (0.5 + 0.5 * sin(_pulsePhase));
  }

  void _spawnDots(double hold, double dt) {
    final maxDots = hold < _stage1End
        ? 5
        : hold < _stage2End
        ? 8
        : 12;
    final interval = hold < _stage1End ? 0.13 : 0.08;
    _spawnAcc += dt;
    if (_spawnAcc < interval) return;
    _spawnAcc = 0;
    final live = children.whereType<_InboundDot>().length;
    if (live >= maxDots) return;
    add(_InboundDot(rng: _rng));
  }

  void _reset() {
    _wasCharging = false;
    _spawnAcc = 0;
    _pulsePhase = 0;
    _coreRadius = 0;
    _pulse = 1;
    for (final dot in children.whereType<_InboundDot>().toList()) {
      dot.removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_wasCharging) return;
    super.render(canvas);
    if (_coreRadius <= 0) return;

    final r = _coreRadius * _pulse.clamp(0.7, 1.25);
    canvas.drawCircle(
      Offset.zero,
      r * 2.6,
      Paint()..color = const Color(0xFF7CFFFF).withValues(alpha: 0.12 * _pulse),
    );
    canvas.drawCircle(
      Offset.zero,
      r * 1.55,
      Paint()..color = const Color(0xFFB8FFFF).withValues(alpha: 0.32 * _pulse),
    );
    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.92 * _pulse.clamp(0.5, 1)),
    );
  }
}

class _InboundDot extends CircleComponent {
  final Vector2 _velocity = Vector2.zero();

  _InboundDot({required Random rng})
    : super(
        anchor: Anchor.center,
        radius: 0.7 + rng.nextDouble() * 0.8,
        paint: Paint()..color = Colors.white,
      ) {
    final angle = rng.nextDouble() * 2 * pi;
    final dist = 16.0 + rng.nextDouble() * 12.0;
    position.setValues(cos(angle) * dist, sin(angle) * dist);
    final speed = 38 + rng.nextDouble() * 36;
    if (position.length2 > 0.001) {
      _velocity.setFrom(-position.normalized() * speed);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(_velocity * dt);
    if (position.length <= 2.2) {
      removeFromParent();
    }
  }
}
