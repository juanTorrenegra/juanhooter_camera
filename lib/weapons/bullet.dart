import 'dart:math';

import 'package:flame/components.dart';
import 'package:juanshooter/game.dart';

class Bullet extends SpriteComponent with HasGameReference<MyGame> {
  final double speed;

  Bullet({
    required Vector2 position,
    required double angle,
    required this.speed,
  }) : super(
         position: position,
         size: Vector2(10, 20),
         anchor: Anchor.center,
         angle: angle,
       );

  @override
  Future<void> onLoad() async {
    super.onLoad();
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
