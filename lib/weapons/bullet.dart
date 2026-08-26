import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';
import 'package:juanshooter/game.dart';

/// Off-screen shots still move and collide; they are not drawn, and they
/// despawn after [maxFlightSeconds] so they cannot accumulate forever.
mixin ProjectileLifetimeAndCull on SpriteComponent, HasGameReference<MyGame> {
  static const double maxFlightSeconds = 8;
  static const double renderMargin = 96;

  double _flightAge = 0;

  void tickProjectileLifetime(double dt) {
    _flightAge += dt;
    if (_flightAge >= maxFlightSeconds) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (!game.isWorldPointVisible(position, margin: renderMargin)) return;
    super.render(canvas);
  }
}

class Bullet extends SpriteComponent
    with HasGameReference<MyGame>, ProjectileLifetimeAndCull {
  final double speed;
  final int damage;
  final Vector2 _direction = Vector2.zero();

  Bullet({
    required Vector2 position,
    required double angle,
    required this.speed,
    this.damage = 4,
    double sizeScale = 1,
  }) : super(
         position: position,
         size: Vector2(28, 15) * sizeScale,
         anchor: Anchor.center,
         angle: angle + 0,
       ) {
    _direction.setValues(cos(angle), sin(angle));
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await Sprite.load('laserPointy.png');
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += _direction * speed * dt;
    tickProjectileLifetime(dt);
  }
}
