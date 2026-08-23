import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:juanshooter/actors/enemigo.dart';

/// Melee crab: idle until the player enters [alarmRadius] or it takes damage,
/// then chases and slashes at close range.
class CrabEnemy extends Enemigo {
  final int damage;
  final double alarmRadius;
  final double meleeRange;
  final double knockbackDistance;

  bool _slashOnCooldown = false;
  double _slashCooldownTimer = 0;

  CrabEnemy({
    required Sprite sprite,
    required Vector2 position,
    Vector2? size,
    double angle = 0,
    int maxHitPoints = 50,
    int shield = 0,
    double movementSpeed = 60,
    double rotationSpeed = 4.0,
    this.damage = 30,
    this.alarmRadius = 100,
    this.meleeRange = 30,
    this.knockbackDistance = 20,
  }) : super(
         sprite: sprite,
         position: position,
         size: size ?? Vector2(16, 16),
         angle: angle,
         maxHitPoints: maxHitPoints,
         shield: shield,
         movementSpeed: movementSpeed,
         rotationSpeed: rotationSpeed,
       );

  @override
  void update(double dt) {
    if (!isActivated) {
      _tryActivateFromProximity();
    }
    super.update(dt);
  }

  void _tryActivateFromProximity() {
    if (!game.player.isMounted) return;
    if (position.distanceTo(game.player.position) <= alarmRadius) {
      activate();
    }
  }

  @override
  void onDeactivate() {
    _slashOnCooldown = false;
    _slashCooldownTimer = 0;
  }

  @override
  void onUpdateBehavior(double dt) {
    if (!game.player.isMounted) return;

    if (_slashOnCooldown) {
      _slashCooldownTimer -= dt;
      if (_slashCooldownTimer <= 0) {
        _slashOnCooldown = false;
        _slashCooldownTimer = 0;
      } else {
        // Hold still for the slash; keep facing the player.
        final toPlayer = game.player.position - position;
        if (toPlayer.length2 > 0) {
          angle = rotateTowards(atan2(toPlayer.y, toPlayer.x), dt);
        }
        return;
      }
    }

    final toPlayer = game.player.position - position;
    final distance = toPlayer.length;

    if (toPlayer.length2 > 0) {
      angle = rotateTowards(atan2(toPlayer.y, toPlayer.x), dt);
      if (distance > meleeRange) {
        final gap = distance - meleeRange;
        final step = min(movementSpeed * dt, gap);
        position.add(toPlayer.normalized() * step);
      }
    }

    // Re-measure after closing the gap so arriving this frame still attacks.
    // Epsilon covers float error from stopping exactly on the range circle.
    final toPlayerNow = game.player.position - position;
    if (toPlayerNow.length <= meleeRange + 1 && !game.player.isInvulnerable) {
      _slash(toPlayerNow);
    }
  }

  void _slash(Vector2 toPlayer) {
    final player = game.player;

    _slashOnCooldown = true;
    _slashCooldownTimer = SlashHitEffect.lifetime;

    final slashAngle = toPlayer.length2 > 0
        ? atan2(toPlayer.y, toPlayer.x)
        : angle;
    final midpoint = (position + player.position) / 2;
    game.universo.add(
      SlashHitEffect(
        worldPosition: midpoint,
        angle: slashAngle + pi / 4,
      ),
    );

    player.takeDamage(damage);

    final away = player.position - position;
    if (away.length2 > 0) {
      player.position.add(away.normalized() * knockbackDistance);
    } else {
      player.position.add(Vector2(knockbackDistance, 0));
    }
  }
}

/// Three diagonal curved white slashes that flash for [lifetime] seconds.
class SlashHitEffect extends PositionComponent {
  static const double lifetime = 0.8;

  double _elapsed = 0;

  SlashHitEffect({required Vector2 worldPosition, required double angle})
    : super(
        position: worldPosition,
        size: Vector2(48, 48),
        angle: angle,
        anchor: Anchor.center,
        priority: 1500,
      );

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= lifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final t = (_elapsed / lifetime).clamp(0.0, 1.0);
    final flash = 0.55 + 0.45 * sin(_elapsed * pi * 10).abs();
    final opacity = ((1 - t) * flash).clamp(0.0, 1.0);

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.translate(size.x / 2, size.y / 2);
    for (var i = 0; i < 3; i++) {
      final offset = -12.0 + i * 12.0;
      final path = Path()
        ..moveTo(offset - 10, -18)
        ..quadraticBezierTo(offset + 6, -2, offset + 16, 18);
      canvas.drawPath(path, paint);
    }
  }
}
