import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:juanshooter/actors/enemigo.dart';
import 'package:juanshooter/actors/ranged_enemy.dart';
import 'package:juanshooter/actors/turret.dart';
import 'package:juanshooter/weapons/bullet.dart';
import 'package:juanshooter/utils/game_utils.dart';

class TurretShip extends RangedEnemy {
  final List<Turret> turrets = [];
  final List<TurretConfig>? turretConfigs;

  TurretShip({
    required Sprite sprite,
    required Vector2 position,
    Vector2? size,
    double angle = 0,
    int maxHitPoints = 3,
    int shield = 0,
    double movementSpeed = 0,
    double rotationSpeed = 1.0,
    double shootInterval = 1.5,
    double bulletSpeed = 250,
    double shootingThreshold = 10.0,
    double shootingOffset = 15.0,
    this.turretConfigs, // Configuración de torretas
  }) : super(
         sprite: sprite,
         position: position,
         size: size,
         angle: angle,
         maxHitPoints: maxHitPoints,
         shield: shield,
         movementSpeed: movementSpeed,
         rotationSpeed: rotationSpeed,
         shootInterval: shootInterval,
         bulletSpeed: bulletSpeed,
         shootingThreshold: shootingThreshold,
         shootingOffset: shootingOffset,
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Añadir torretas basadas en la configuración
    if (turretConfigs != null) {
      for (final config in turretConfigs!) {
        print('Cargando torreta en posición: ${config.relativePosition}');
        final turret = Turret(
          sprite: await Sprite.load(config.spritePath),
          relativePosition: config.relativePosition,
          size: config.size,
          rotationSpeed: config.rotationSpeed,
          shootInterval: config.shootInterval,
          bulletSpeed: config.bulletSpeed,
          shootingOffset: config.shootingOffset,
        );
        turrets.add(turret);
        add(turret);
        print('Torreta añadida: ${turret.isMounted}');
      }
    }
    print('Total torretas montadas: ${turrets.length}');
  }

  @override
  void onUpdateBehavior(double dt) {
    super.onUpdateBehavior(dt);

    // Actualizar todas las torretas
    for (final turret in turrets) {
      turret.updateTurret(
        dt,
        position,
        angle,
        game.player.isMounted ? game.player.position : null,
      );
    }
  }
}

// Configuración de torretas
class TurretConfig {
  final String spritePath;
  final Vector2 relativePosition;
  final Vector2? size;
  final double rotationSpeed;
  final double shootInterval;
  final double bulletSpeed;
  final double shootingOffset;

  TurretConfig({
    required this.spritePath,
    required this.relativePosition,
    this.size,
    this.rotationSpeed = 1.0,
    this.shootInterval = 1.5,
    this.bulletSpeed = 250,
    this.shootingOffset = 15.0,
  });
}
