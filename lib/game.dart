import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class MyGame extends FlameGame with HasGameReference<MyGame> {
  late final JoystickComponent movementJoystick;
  late final JoystickComponent lookJoystick;
  late final Player player;
  late final ButtonComponent shootButton;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Movement Joystick
    movementJoystick = JoystickComponent(
      knob: CircleComponent(radius: 30, paint: Paint()..color = Colors.grey),
      background: CircleComponent(
        radius: 50,
        paint: Paint()..color = Colors.blueGrey,
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );

    // Look Joystick
    lookJoystick = JoystickComponent(
      knob: CircleComponent(radius: 30, paint: Paint()..color = Colors.grey),
      background: CircleComponent(
        radius: 50,
        paint: Paint()..color = Colors.blueGrey,
      ),
      margin: const EdgeInsets.only(right: 40, bottom: 40),
      position: Vector2(size.x - 100, size.y - 100),
    );

    // Shoot Button
    shootButton = ButtonComponent(
      button: CircleComponent(radius: 40, paint: Paint()..color = Colors.blue),
      position: Vector2(size.x - 100, 60),
      onPressed: _shoot,
      priority: 10,
    );

    // Player
    final sprite = await Sprite.load('heart.png');
    player = Player(sprite: sprite, position: Vector2(200, 200));

    add(player);
    add(movementJoystick);
    add(lookJoystick);
    add(shootButton);
  }

  void _shoot() {
    final bullet = Bullet(
      position: player.position.clone(),
      angle: player.angle,
      speed: 300,
    );
    add(bullet);
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

class Bullet extends SpriteComponent with HasGameReference<MyGame> {
  final double speed;

  Bullet({
    required Vector2 position,
    required double angle,
    required this.speed,
  }) : super(
         position: position,
         size: Vector2(10, 20), // Adjust size to match your sprite
         anchor: Anchor.center,
         angle: angle,
       );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Load your bullet sprite (make sure the image is in your assets)
    sprite = await Sprite.load('star.png');
  }

  @override
  void update(double dt) {
    super.update(dt);

    final direction = Vector2(cos(angle), sin(angle));
    position.add(direction * speed * dt);

    if (position.x < 0 ||
        position.y < 0 ||
        position.x > game.size.x ||
        position.y > game.size.y) {
      removeFromParent();
    }
  }
}

//import 'dart:math';
//
//import 'package:flame/components.dart';
//import 'package:flame/game.dart';
//import 'package:flutter/material.dart';
//
//class MyGame extends FlameGame {
//  late final JoystickComponent movementJoystick;
//  late final JoystickComponent lookJoystick;
//  late final Player player;
//
//  @override
//  Future<void> onLoad() async {
//    super.onLoad();
//
//    movementJoystick = JoystickComponent(
//      knob: CircleComponent(radius: 30, paint: Paint()..color = Colors.grey),
//      background: CircleComponent(
//        radius: 50,
//        paint: Paint()..color = Colors.blueGrey,
//      ),
//      margin: const EdgeInsets.only(left: 40, bottom: 40),
//    );
//
//    lookJoystick = JoystickComponent(
//      knob: CircleComponent(radius: 30, paint: Paint()..color = Colors.grey),
//      background: CircleComponent(
//        radius: 50,
//        paint: Paint()..color = Colors.blueGrey,
//      ),
//      margin: const EdgeInsets.only(right: 40, bottom: 40),
//      position: Vector2(size.x - 100, size.y - 100),
//    );
//
//    // Cargar el sprite antes de crear el jugador
//    final sprite = await Sprite.load('heart.png');
//    player = Player(sprite: sprite, position: Vector2(200, 200));
//
//    add(player);
//    add(movementJoystick);
//    add(lookJoystick);
//  }
//}
//
//class Player extends SpriteComponent with HasGameReference<MyGame> {
//  Player({required Sprite sprite, required Vector2 position})
//    : super(
//        position: position,
//        size: Vector2.all(25),
//        anchor: Anchor.center,
//        sprite: sprite,
//        priority: 8,
//      );
//
//  final double _speed = 80;
//  double _angle = 0;
//
//  @override
//  void update(double dt) {
//    super.update(dt);
//
//    // Movimiento
//    if (game.movementJoystick.direction != JoystickDirection.idle) {
//      position.add(game.movementJoystick.relativeDelta * _speed * dt);
//    }
//
//    // Rotación - ahora aplicamos la rotación al sprite completo
//    if (game.lookJoystick.direction != JoystickDirection.idle) {
//      _angle = game.lookJoystick.relativeDelta.screenAngle();
//      const double orientationCorrection = pi;
//      angle = _angle + orientationCorrection; // Esto rotará el sprite completo
//    }
//  }
//}
//
