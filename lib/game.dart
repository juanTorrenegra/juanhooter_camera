import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MyGame extends FlameGame {
  late final JoystickComponent joystick;
  late final Player player;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    joystick = JoystickComponent(
      knob: CircleComponent(radius: 30, paint: Paint()..color = Colors.orange),
      background: CircleComponent(
        radius: 50,
        paint: Paint()..color = Colors.yellow,
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
      position: Vector2(200, 200),
      anchor: Anchor.center,
    );
    player = Player(radius: 30, position: Vector2(200, 200));
    add(player);
    add(joystick);
  }
}

class Player extends CircleComponent with HasGameReference<MyGame> {
  Player({required double radius, required Vector2 position})
    : super(
        radius: 20,
        position: Vector2(100, 100),
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0xFF00FF00),
        priority: 8,
        children: [
          CircleComponent(
            radius: 6,
            paint: Paint()..color = Colors.black,
            position: Vector2(5, 5),
          ),
        ],
      );

  final double _speed = 80;

  @override
  void update(double dt) {
    super.update(dt);
    if (game.joystick.direction != JoystickDirection.idle) {
      position.add(game.joystick.relativeDelta * _speed * dt);
    }
  }
}
