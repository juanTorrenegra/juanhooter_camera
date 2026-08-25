import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:juanshooter/game.dart';
import 'package:juanshooter/hud/potency_bar.dart';
import 'package:juanshooter/weapons/bullet.dart';

abstract class Enemigo extends SpriteComponent
    with HasGameReference<MyGame>, CollisionCallbacks {
  int hitPoints;
  final int maxHitPoints;
  final int shield;
  final double movementSpeed;
  final double rotationSpeed;
  final double alarmRadius;

  /// Player in this ring (outside [alarmRadius]) shows a blinking `!`.
  final double warningRadius;
  bool _isActivated = false;
  AlarmWarningMark? _warningMark;

  bool get isActivated => _isActivated;

  Enemigo({
    required Sprite sprite,
    required Vector2 position,
    Vector2? size,
    double angle = 0, // ✅ Ángulo inicial personalizable
    int maxHitPoints = 50,
    this.shield = 0,
    this.movementSpeed = 0,
    this.rotationSpeed = 1.0, // ✅ Velocidad de rotación base
    this.alarmRadius = 100,
    this.warningRadius = 180,
  }) : hitPoints = maxHitPoints,
       maxHitPoints = maxHitPoints,
       super(
         position: position,
         size: size ?? Vector2.all(60),
         anchor: Anchor.center,
         angle: angle, // ✅ Usa el ángulo proporcionado
         sprite: sprite,
       );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox(collisionType: CollisionType.active));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_isActivated) {
      _updateProximityState();
    } else {
      _hideWarning();
    }
    if (_isActivated) {
      onUpdateBehavior(dt);
    } else {
      onIdleBehavior(dt);
    }
  }

  void _updateProximityState() {
    if (!game.player.isMounted) {
      _hideWarning();
      return;
    }
    final dist = position.distanceTo(game.player.position);
    if (alarmRadius > 0 && dist <= alarmRadius) {
      activate();
      return;
    }
    if (warningRadius > alarmRadius && dist <= warningRadius) {
      _showWarning();
    } else {
      _hideWarning();
    }
  }

  void _showWarning() {
    if (_warningMark != null) return;
    final mark = AlarmWarningMark(host: this);
    _warningMark = mark;
    add(mark);
  }

  void _hideWarning() {
    _warningMark?.removeFromParent();
    _warningMark = null;
  }

  void onUpdateBehavior(double dt);

  /// Called while idle (not activated). Override for patrol, etc.
  void onIdleBehavior(double dt) {}

  void activate() {
    if (_isActivated) return;
    _hideWarning();
    _isActivated = true;
    onActivate();
    _activateNearby(100);
  }

  /// Wakes other [Enemigo]s within [radius] (chains through [activate]).
  void _activateNearby(double radius) {
    if (!isMounted) return;
    for (final enemy in game.universo.children.whereType<Enemigo>()) {
      if (identical(enemy, this) || !enemy.isMounted || enemy.isActivated) {
        continue;
      }
      if (enemy.position.distanceTo(position) <= radius) {
        enemy.activate();
      }
    }
  }

  void deactivate() {
    _isActivated = false;
    onDeactivate();
  }

  // Método opcional para comportamiento al activarse
  void onActivate() {} //dame un ejemplo de como usar y por que este metodo
  void onDeactivate() {}

  //  Método para rotar suavemente hacia un ángulo objetivo
  double rotateTowards(double targetAngle, double dt) {
    return _smoothRotation(angle, targetAngle, rotationSpeed * dt);
  }

  //  Método para normalizar ángulos (útil para todas las subclases)
  double _normalizeAngle(double angle) {
    angle = angle % (2 * pi);
    if (angle > pi) angle -= 2 * pi;
    if (angle < -pi) angle += 2 * pi;
    return angle;
  }

  //  Método para rotación suave (útil para todas las subclases)
  double _smoothRotation(double currentAngle, double targetAngle, double t) {
    currentAngle = _normalizeAngle(currentAngle);
    targetAngle = _normalizeAngle(targetAngle);

    double difference = targetAngle - currentAngle;

    if (difference > pi) difference -= 2 * pi;
    if (difference < -pi) difference += 2 * pi;

    return currentAngle + difference * t;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Bullet) {
      _showDamagePopup(other.damage);
      _takeDamage(other.damage);
      other.removeFromParent();

      if (!_isActivated) {
        activate();
      }
    }
  }

  void _showDamagePopup(int damage) {
    game.universo.add(
      DamagePopup(
        worldPosition: position.clone() + Vector2(0, -size.y * 0.6),
        damage: damage,
      ),
    );
  }

  void _takeDamage(int damage) {
    final remainingShield = shield - damage;
    if (remainingShield >= 0) {
      // TODO: Efecto visual de escudo hacer
      return;
    }

    hitPoints += remainingShield;

    if (hitPoints <= 0) {
      onDeath();
      removeFromParent();
    }
  } //.

  void onDeath() {
    game.incrementShipsDestroyed();
    game.spawnEnemyExplosion(position);
  }
}

/// Blinking `!` above an idle enemy while the player is in [Enemigo.warningRadius].
class AlarmWarningMark extends TextComponent {
  static const double blinkHz = 2.5;

  final Enemigo host;
  double _elapsed = 0;

  AlarmWarningMark({required this.host})
    : super(
        text: '  !',
        anchor: Anchor.bottomCenter,
        priority: 100,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.amberAccent,
            fontSize: 22,
            fontFamily: 'Megatrans',
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(color: Colors.black, blurRadius: 6, offset: Offset(0, 1)),
            ],
          ),
        ),
      );

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    // Keep the mark world-up and above the sprite, ignoring host rotation.
    final lift = host.size.y * 0.55 + 6;
    position.setValues(0, -lift);
    position.rotate(-host.angle);
    angle = -host.angle;
  }

  @override
  void render(Canvas canvas) {
    // Start visible, then blink off on odd half-cycles.
    if ((_elapsed * blinkHz).floor().isOdd) return;
    super.render(canvas);
  }
}
