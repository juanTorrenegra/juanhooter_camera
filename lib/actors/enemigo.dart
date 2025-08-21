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
  double _targetAngle = 0;

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
         //angle: pi,
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
      _targetAngle = atan2(direction.y, direction.x);

      // Normaliza los ángulos para evitar la rotación completa
      angle = _smoothRotation(angle, _targetAngle, 5 * dt);
    }
  }

  double _smoothRotation(double currentAngle, double targetAngle, double t) {
    // Normaliza ambos ángulos al rango [-π, π]
    currentAngle = _normalizeAngle(currentAngle);
    targetAngle = _normalizeAngle(targetAngle);

    // Calcula la diferencia más corta entre los ángulos
    double difference = targetAngle - currentAngle;

    // Ajusta la diferencia para tomar el camino más corto
    if (difference > pi) {
      difference -= 2 * pi;
    } else if (difference < -pi) {
      difference += 2 * pi;
    }

    // Interpola suavemente
    return currentAngle + difference * t;
  }

  double _normalizeAngle(double angle) {
    // Normaliza el ángulo al rango [-π, π]
    angle = angle % (2 * pi);
    if (angle > pi) {
      angle -= 2 * pi;
    } else if (angle < -pi) {
      angle += 2 * pi;
    }
    return angle;
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
        speed: 100,
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
}
