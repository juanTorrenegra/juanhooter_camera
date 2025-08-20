import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:juanshooter/actors/player.dart';
import 'package:juanshooter/game.dart';

class EnemyBullet extends SpriteComponent with HasGameReference<MyGame> {
  final double speed;
  final Vector2 _direction = Vector2.zero();

  EnemyBullet({
    required Vector2 position,
    required double angle,
    required this.speed,
  }) : super(
         position: position,
         size: Vector2(15, 25),
         anchor: Anchor.center,
         angle: angle,
       ) {
    _direction.setValues(cos(angle), sin(angle));
  }

  @override
  Future<void> onLoad() async {
    try {
      // Usa un sprite que ya existe en tu proyecto
      sprite = await Sprite.load('enemy_bullet.png');
      add(CircleHitbox());
    } catch (e) {
      print('Error loading enemy bullet sprite: $e');
      removeFromParent(); // Elimina si hay error
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += _direction * speed * dt;

    // Eliminar si sale de los límites
    if (position.x < -100 ||
        position.y < -100 ||
        position.x > 1700 ||
        position.y > 1700) {
      removeFromParent();
    }
  }

  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      removeFromParent();
      // Aquí puedes agregar daño al jugador
      // other.takeDamage(1);
    }
  }
}
