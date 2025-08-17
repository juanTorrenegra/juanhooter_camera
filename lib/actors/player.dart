import 'dart:math';

import 'package:flame/components.dart';
import 'package:juanshooter/game.dart';

class Player extends SpriteComponent with HasGameReference<MyGame> {
  Player({required Sprite sprite, required Vector2 position})
    : super(
        position: position,
        size: Vector2.all(30),
        anchor: Anchor.center,
        sprite: sprite,
        priority: 8,
      );

  final double _speed = 250;
  double _angle = 0;

  @override
  void update(double dt) {
    super.update(dt);

    // Movement: accede al joystick a través de game.hud
    if (game.hud.movementJoystick.direction != JoystickDirection.idle) {
      position.add(game.hud.movementJoystick.relativeDelta * _speed * dt);
    }

    // Rotación (corrige el ángulo)
    if (game.hud.lookJoystick.direction != JoystickDirection.idle) {
      // Obtén el ángulo del joystick (en radianes)
      _angle = game.hud.lookJoystick.relativeDelta.screenAngle();

      // Ajusta el ángulo para que coincida con la orientación del sprite
      const double offset = -pi / 2; // Ajusta este valor según tu sprite
      angle = _angle + offset;
    }
  }
}
