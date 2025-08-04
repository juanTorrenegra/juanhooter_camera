import 'dart:math';

import 'package:flame/components.dart';
import 'package:juanshooter/game.dart';

class Player extends SpriteComponent with HasGameReference<MyGame> {
  Player({required Sprite sprite, required Vector2 position})
    : super(
        position: position,
        size: Vector2.all(17),
        anchor: Anchor.center,
        sprite: sprite,
        priority: 8,
      );

  final double _speed = 80;
  double _angle = 0;

  @override
  void update(double dt) {
    super.update(dt);

    // Movement
    if (game.movementJoystick.direction != JoystickDirection.idle) {
      position.add(game.movementJoystick.relativeDelta * _speed * dt);
    }

    // Rotation
    if (game.lookJoystick.direction != JoystickDirection.idle) {
      _angle = game.lookJoystick.relativeDelta.screenAngle();
      const double orientationCorrection = pi;
      angle = _angle + orientationCorrection;
    }
  }
}
