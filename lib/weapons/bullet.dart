import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:juanshooter/game.dart';

enum BulletState { spawn, travel, impact }

class Bullet extends SpriteGroupComponent<BulletState>
    with HasGameReference<MyGame>, CollisionCallbacks {
  final double speed;
  final Vector2 _direction = Vector2.zero();

  Bullet({
    required Vector2 position,
    required double angle,
    required this.speed,
  }) : super(
         position: position,
         size: Vector2(10, 20),
         anchor: Anchor.center,
         angle: angle,
       ) {
    //_direction.setFromPolar(angle, speed);
    _direction.setValues(cos(angle), sin(angle));
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprites = {
      BulletState.spawn: await Sprite.load('bullet_spawn.png'),
      BulletState.travel: await Sprite.load('bullet_travel.png'),
      BulletState.impact: await Sprite.load('bullet_impact.png'),
    };
    current = BulletState.spawn;

    // Después de un tiempo corto, pasar al estado de viaje
    Future.delayed(const Duration(milliseconds: 100), () {
      if (isMounted) current = BulletState.travel;
    });

    add(RectangleHitbox(collisionType: CollisionType.active));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (current == BulletState.travel) {
      position += _direction * speed * dt;
    }
    //final direction = Vector2(cos(angle), sin(angle));
    //position.add(direction * speed * dt);
    if (position.x < 0 ||
        position.y < 0 ||
        position.x > 1600 || // Tamaño de tu mundo
        position.y > 1600) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    // Al colisionar cambiamos a impacto y removemos luego
    current = BulletState.impact;

    Future.delayed(const Duration(milliseconds: 800), () {
      removeFromParent();
    });
  }
}
