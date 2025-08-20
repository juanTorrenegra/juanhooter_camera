import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:juanshooter/game.dart';
import 'package:juanshooter/weapons/bullet.dart';

class Enemigo extends SpriteComponent
    with HasGameReference<MyGame>, CollisionCallbacks {
  int hitPoints;
  final int maxHitPoints;

  Enemigo({
    required Sprite sprite,
    required Vector2 position,
    Vector2? size,
    int? hitPoints,
  }) : hitPoints = hitPoints ?? 3,
       maxHitPoints = hitPoints ?? 3,
       super(
         position: position,
         size: size ?? Vector2.all(50),
         anchor: Anchor.center,
         sprite: sprite,
       );
  @override
  Future<void> onLoad() async {
    add(CircleHitbox(collisionType: CollisionType.active));
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Bullet) {
      other.removeFromParent();
      hitPoints--;

      if (hitPoints <= 0) {
        removeFromParent();
      }

      // game.add(Explosion(position: position));
    }
  }
}
