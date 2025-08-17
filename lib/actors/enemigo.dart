import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:juanshooter/game.dart';
import 'package:juanshooter/weapons/bullet.dart';

class Enemigo extends SpriteComponent
    with HasGameReference<MyGame>, CollisionCallbacks {
  Enemigo({required Sprite sprite, required Vector2 position})
    : super(
        position: position,
        size: Vector2.all(30),
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
      removeFromParent();
      other.removeFromParent();
      //game.add(Explosion(position: position));
    }
  }
}
