import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:juanshooter/actors/enemigo.dart';
import 'package:juanshooter/game.dart';

/// Expanding alarm splash: fades as it grows and wakes enemies the front reaches.
class AlarmRipple extends PositionComponent with HasGameReference<MyGame> {
  static const double waveSpeed = 200;
  static const Color _fill = Color(0xFFFF6E40);
  static const Color _ring = Color(0xFFFFAB91);

  final double maxRadius;
  final Enemigo? source;
  double _radius = 0;

  AlarmRipple({
    required Vector2 origin,
    required this.maxRadius,
    this.source,
  }) : super(
         position: origin.clone(),
         size: Vector2.all(max(maxRadius, 1) * 2),
         anchor: Anchor.center,
         priority: 60,
       );

  @override
  void update(double dt) {
    super.update(dt);
    _radius += waveSpeed * dt;
    _wakeReachedEnemies();
    if (_radius >= maxRadius) {
      _radius = maxRadius;
      _wakeReachedEnemies();
      removeFromParent();
    }
  }

  void _wakeReachedEnemies() {
    if (!game.universo.isMounted) return;
    for (final enemy in game.universo.children.whereType<Enemigo>()) {
      if (identical(enemy, source) || !enemy.isMounted || enemy.isActivated) {
        continue;
      }
      if (enemy.position.distanceTo(position) <= _radius) {
        enemy.activate();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_radius <= 0.5 || maxRadius <= 0) return;
    final t = (_radius / maxRadius).clamp(0.0, 1.0);
    final center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(
      center,
      _radius,
      Paint()..color = _fill.withValues(alpha: 0.28 * (1 - t)),
    );
    canvas.drawCircle(
      center,
      _radius,
      Paint()
        ..color = _ring.withValues(alpha: 0.55 * (1 - t * 0.65))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
  }
}
