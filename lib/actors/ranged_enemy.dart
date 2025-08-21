import 'dart:math';

import 'package:flame/components.dart';
import 'package:juanshooter/game.dart';
import 'package:juanshooter/weapons/enemy_bullet.dart';
import 'enemigo.dart';

class RangedEnemy extends Enemigo {
  bool _isAiming = false;
  double _shootCooldown = 0;
  final double _shootInterval;
  final double _aimTime;
  final double _bulletSpeed;
  double _targetAngle = 0;

  RangedEnemy({
    required Sprite sprite,
    required Vector2 position,
    Vector2? size,
    double angle = 0, // ✅ Heredado de la clase base
    int maxHitPoints = 3,
    int shield = 0,
    double movementSpeed = 0,
    double rotationSpeed = 1.0, // ✅ Heredado de la clase base
    double shootInterval = 1.5,
    double aimTime = 2.0,
    double bulletSpeed = 250,
  }) : _shootInterval = shootInterval,
       _aimTime = aimTime,
       _bulletSpeed = bulletSpeed,
       super(
         sprite: sprite,
         position: position,
         size: size,
         angle: angle, // ✅ Pasa el ángulo a la clase base
         maxHitPoints: maxHitPoints,
         shield: shield,
         movementSpeed: movementSpeed,
         rotationSpeed: rotationSpeed, // ✅ Pasa la velocidad de rotación
       );

  @override
  void onActivate() {
    _startAiming();
  }

  void _startAiming() {
    _isAiming = true;

    Future.delayed(Duration(milliseconds: (_aimTime * 1000).toInt()), () {
      if (isMounted) {
        _shootCooldown = _shootInterval;
      }
    });
  }

  @override
  void onUpdateBehavior(double dt) {
    if (_isAiming) {
      _followPlayer(dt);
      _handleShooting(dt);
    }
  }

  void _followPlayer(double dt) {
    if (game.player.isMounted) {
      final direction = game.player.position - position;
      _targetAngle = atan2(direction.y, direction.x);

      // ✅ Usa el método de rotación de la clase base
      angle = rotateTowards(_targetAngle, dt);
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

    final bullet = EnemyBullet(
      position: position.clone(),
      angle: angle,
      speed: _bulletSpeed,
    );

    game.universo.add(bullet);
  }
}
