import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart'; // Necesario para el joystick
import 'package:flutter/material.dart';

class MyGame extends FlameGame {
  late final JoystickComponent joystick;
  late final Player player;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final circle = CircleComponent(
      radius: 60,
      position: size / 2,
      paint: Paint()..color = const Color(0xFF00FF00), // Color verde
      anchor: Anchor.center,
    );

    final rec = RectangleComponent(
      position: Vector2(100, 100),
      size: Vector2.all(80),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.white,
      priority: 1,
    );

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
    //final );player = Player(joystick);
    player = Player(radius: 30, position: size / 2);
    add(player);
    add(rec);
    add(circle);
    add(joystick);
  }
}

class Player extends CircleComponent with HasGameReference<MyGame> {
  Player({required double radius, required Vector2 position})
    : super(
        radius: radius,
        position: position,
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0xFF00FF00),
        priority: 8,
      );

  // Velocidad de movimiento del jugador
  final double _speed = 100;

  @override
  void update(double dt) {
    super.update(dt);
    if (game.joystick.direction != JoystickDirection.idle) {
      // Mover el círculo en la dirección del joystick
      position.add(game.joystick.relativeDelta * _speed * dt);
    }
  }
}
