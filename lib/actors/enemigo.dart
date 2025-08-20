import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:juanshooter/game.dart';
import 'package:juanshooter/weapons/bullet.dart';
import 'package:juanshooter/weapons/enemy_bullet.dart';

class Enemigo extends SpriteComponent
    with HasGameReference<MyGame>, CollisionCallbacks {
  int hitPoints;
  final int maxHitPoints;
  bool _isActivated = false;
  bool _isAiming = false;
  double _shootCooldown = 0;
  final double _shootInterval = 1.5; // Dispara cada 1.5 segundos
  final double _aimTime = 2.0; // 2 segundos para apuntar

  Enemigo({
    required Sprite sprite,
    required Vector2 position,
    Vector2? size,
    int? hitPoints,
  }) : hitPoints = hitPoints ?? 3,
       maxHitPoints = hitPoints ?? 3,
       super(
         position: position,
         size: size ?? Vector2.all(50),
         anchor: Anchor.center,
         sprite: sprite,
       );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox(collisionType: CollisionType.active));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Si está activado pero no apuntando aún
    if (_isActivated && !_isAiming) {
      _startAiming();
    }

    // Si está apuntando, seguir al jugador y disparar
    if (_isAiming) {
      _followPlayer(dt);
      _handleShooting(dt);
    }
  }

  void _startAiming() {
    _isAiming = true;

    // Programa el inicio del disparo después del tiempo de aim
    Future.delayed(Duration(milliseconds: (_aimTime * 1000).toInt()), () {
      if (isMounted) {
        _shootCooldown =
            _shootInterval; // Dispara inmediatamente después de aim
      }
    });
  }

  void _followPlayer(double dt) {
    if (game.player.isMounted) {
      // Calcula el ángulo hacia el jugador
      final direction = game.player.position - position;
      final targetAngle = atan2(direction.y, direction.x);

      // Suaviza el giro (opcional)
      angle = lerpDouble(angle, targetAngle, 5 * dt) ?? targetAngle;
    }
  }

  void _handleShooting(double dt) {
    if (_shootCooldown > 0) {
      _shootCooldown -= dt;
    } else {
      _shoot();
      _shootCooldown = _shootInterval;
    }
  }

  void _shoot() {
    if (!isMounted || !game.player.isMounted) return;
    try {
      final bullet = EnemyBullet(
        position: position.clone(),
        angle: angle,
        speed: 250,
      );

      game.universo.add(bullet);
    } catch (e) {
      print('Error creating enemy bullet: $e');
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Bullet) {
      other.removeFromParent();
      hitPoints--;

      // Activa el enemigo al primer disparo
      if (!_isActivated) {
        _isActivated = true;
      }

      if (hitPoints <= 0) {
        removeFromParent();
      }

      // game.add(Explosion(position: position));
    }
  }

  // Función de interpolación para giro suave
  double lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
