import 'dart:math';

import 'package:flame/components.dart';
import 'package:juanshooter/game.dart';
import 'package:juanshooter/weapons/enemy_bullet.dart';
import 'enemigo.dart';
//shootingThreshold: 5.0,   // Más preciso (+ difícil)
//shootingThreshold: 10.0,  // Balanceado
//shootingThreshold: 20.0,  // Menos preciso (+ fácil)
//shootingThreshold: 0.0,   // Sniper perfecto (muy difícil)
//
//rotationSpeed: 0.5,       // Giro lento
//rotationSpeed: 1.0,       // Giro normal
//rotationSpeed: 2.0,       // Giro rápido
//
//shootInterval: 3.0,       // Dispara lento
//shootInterval: 1.5,       // Dispara normal
//shootInterval: 0.5,       // Dispara rápido

class RangedEnemy extends Enemigo {
  bool _isAiming = false;
  bool _isInShootingPosition = false;
  double _shootCooldown = 0;
  final double _shootInterval;

  final double _bulletSpeed;
  double _targetAngle = 0;
  final double _shootingThreshold; // ✅ Margen de 10 grados para disparar
  final double _shootingOffset; // ✅ Nuevo parámetro para offset de disparo

  RangedEnemy({
    required Sprite sprite,
    required Vector2 position,
    Vector2? size,
    double angle = 0, //Heredado de la clase base
    int maxHitPoints = 3,
    int shield = 0,
    double movementSpeed = 0,
    double rotationSpeed = 1.0, // Heredado de la clase base
    double shootInterval = 1.5,

    double bulletSpeed = 250,
    double shootingThreshold = 10.0, //Grados de margen (10 por defecto)
    double shootingOffset = 15.0, // offset por defecto de 15.0
  }) : _shootInterval = shootInterval,
       _bulletSpeed = bulletSpeed,
       _shootingThreshold =
           shootingThreshold * pi / 180, // Convierte a radianes
       _shootingOffset = shootingOffset, // ✅ Asigna el offset
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

    _isInShootingPosition = false; // ✅ Resetear estado de disparo
    //AQUI DEBERIA ESTAR UN IF PORQUE PUEDE QUE AL PRINCIPIO YA ESTE ALINEADO
    // No iniciar el cooldown de disparo inmediatamente

    //Future.delayed(Duration(milliseconds: (_aimTime * 1000).toInt()), () {
    //  if (isMounted) {
    //    _shootCooldown = _shootInterval;
    //  }
    //});
  }

  @override
  void onUpdateBehavior(double dt) {
    if (_isAiming) {
      _followPlayer(dt);
      //_handleShooting(dt);
      _checkShootingPosition(); // ✅ Verificar si está en posición de disparar
      if (_isInShootingPosition) {
        _handleShooting(dt); // ✅ Solo disparar si está en posición
      }
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

  // ✅ Verifica si está dentro del margen de 10 grados para disparar
  void _checkShootingPosition() {
    if (!_isInShootingPosition) {
      final angleDifference = _getAngleDifference(angle, _targetAngle);
      final thresholdRadians = _shootingThreshold;

      // Si la diferencia es menor al threshold, puede disparar
      if (angleDifference.abs() <= thresholdRadians) {
        _isInShootingPosition = true;
        _shootCooldown = _shootInterval; // ✅ Iniciar cooldown inmediatamente
        print('Enemigo en posición de disparo!');
      }
    }
  }

  // ✅ Calcula la diferencia más corta entre dos ángulos
  double _getAngleDifference(double a, double b) {
    double difference = b - a;
    if (difference > pi) difference -= 2 * pi;
    if (difference < -pi) difference += 2 * pi;
    return difference;
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

    final shootPosition = calculateShootPosition(
      position,
      angle,
      size,
      _shootingOffset, //offset personalizado (antes era 15.0)
    );

    final bullet = EnemyBullet(
      position: shootPosition,
      angle: angle,
      speed: _bulletSpeed,
    );

    game.universo.add(bullet);
  }

  // Opcional: Resetear posición de disparo si el player se mueve mucho
  //void _updateTargetIfNeeded() {
  //  if (_isInShootingPosition && game.player.isMounted) {
  //    final newDirection = game.player.position - position;
  //    final newTargetAngle = atan2(newDirection.y, newDirection.x);
  //
  //    final angleDifference = _getAngleDifference(_targetAngle, newTargetAngle);
  //
  //    // Si el player se movió más de 20 grados, resetear
  //    if (angleDifference.abs() > (20 * pi / 180)) {
  //      _targetAngle = newTargetAngle;
  //      _isInShootingPosition = false;
  //      print('Player se movió, reajustando objetivo...');
  //    }
  //  }
}
