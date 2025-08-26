import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:juanshooter/game.dart';
import 'package:juanshooter/weapons/bullet.dart';

class Player extends SpriteComponent with HasGameReference<MyGame> {
  Player({required Sprite sprite, required Vector2 position})
    : super(
        position: position,
        size: Vector2.all(28),
        anchor: Anchor.center,
        sprite: sprite,
        priority: 8,
      );

  //double _baseSpeed = 80;
  double _currentSpeed = 110;
  bool isFastMode = false;
  double _angle = 0;

  void toggleFastMode(bool activate) {
    isFastMode = !isFastMode; // Invierte el estado actual
    _currentSpeed = isFastMode ? 300 : 80;
  }

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Movement: accede al joystick a través de game.hud
    if (game.hud.movementJoystick.direction != JoystickDirection.idle) {
      position.add(
        game.hud.movementJoystick.relativeDelta * _currentSpeed * dt,
      );
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

  void shoot() {
    final shootPosition = calculateShootPosition(
      position,
      angle,
      size,
      10.0, // Offset adicional desde el borde
    );

    final bullet = Bullet(position: shootPosition, angle: angle, speed: 100);
    game.universo.add(bullet);
    game.pool.start();
  }
}
