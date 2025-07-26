import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MyGame extends FlameGame {
  late final JoystickComponent movementJoystick;
  late final JoystickComponent lookJoystick;
  late final Player player;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    movementJoystick = JoystickComponent(
      knob: CircleComponent(radius: 30, paint: Paint()..color = Colors.grey),
      background: CircleComponent(
        radius: 50,
        paint: Paint()..color = Colors.blueGrey,
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );

    lookJoystick = JoystickComponent(
      knob: CircleComponent(radius: 30, paint: Paint()..color = Colors.grey),
      background: CircleComponent(
        radius: 50,
        paint: Paint()..color = Colors.blueGrey,
      ),
      margin: const EdgeInsets.only(right: 40, bottom: 40),
      position: Vector2(size.x - 100, size.y - 100),
    );

    // Cargar el sprite antes de crear el jugador
    final sprite = await Sprite.load('heart.png');
    player = Player(sprite: sprite, position: Vector2(200, 200));

    add(player);
    add(movementJoystick);
    add(lookJoystick);
  }
}

class Player extends SpriteComponent with HasGameReference<MyGame> {
  Player({required Sprite sprite, required Vector2 position})
    : super(
        position: position,
        size: Vector2.all(25),
        anchor: Anchor.center,
        sprite: sprite,
        priority: 8,
      );

  final double _speed = 80;
  double _angle = 0;

  @override
  void update(double dt) {
    super.update(dt);

    // Movimiento
    if (game.movementJoystick.direction != JoystickDirection.idle) {
      position.add(game.movementJoystick.relativeDelta * _speed * dt);
    }

    // Rotación - ahora aplicamos la rotación al sprite completo
    if (game.lookJoystick.direction != JoystickDirection.idle) {
      _angle = game.lookJoystick.relativeDelta.screenAngle();
      const double orientationCorrection = pi;
      angle = _angle + orientationCorrection; // Esto rotará el sprite completo
    }
  }
}
