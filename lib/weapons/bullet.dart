import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:juanshooter/game.dart';

class Bullet extends SpriteComponent with HasGameReference<MyGame> {
  final double speed;
  final Vector2 _direction = Vector2.zero();

  Bullet({
    required Vector2 position,
    required double angle,
    required this.speed,
  }) : super(
         position: position,
         size: Vector2(5, 52),
         anchor: Anchor.center,
         angle: angle + 3 * pi / 2,
       ) {
    //_direction.setFromPolar(angle, speed);
    _direction.setValues(cos(angle), sin(angle));
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await Sprite.load('laserthin.png');
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    position += _direction * speed * dt;

    //final direction = Vector2(cos(angle), sin(angle));
    //position.add(direction * speed * dt);
    if (position.x < 0 ||
        position.y < 0 ||
        position.x > 3000 || // Tamaño de tu mundo
        position.y > 3000) {
      removeFromParent();
    }
  }
}
