import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:juanshooter/game.dart';

/// Charge shot: 9 damage tiers over 3 seconds (tap → 4, 1s → 9, 2s → 20, 3s → 50).
class ChargeShot {
  static const double maxChargeSeconds = 3.0;
  static const double drainSeconds = 0.22;
  static const double speedPenalty = 20;

  /// 8 listed values plus 40 so there are 9 tiers (3 normal + 5 double + 1 triple).
  static const List<int> damageTiers = [4, 6, 9, 12, 15, 20, 30, 40, 50];

  static int _tierIndex(double holdSeconds) {
    if (holdSeconds >= maxChargeSeconds) {
      return damageTiers.length - 1;
    }
    final t = (holdSeconds / maxChargeSeconds).clamp(0.0, 1.0);
    return (t * (damageTiers.length - 1)).floor().clamp(
      0,
      damageTiers.length - 1,
    );
  }

  static int damageForHoldTime(double holdSeconds) =>
      damageTiers[_tierIndex(holdSeconds)];

  /// First 3 tiers: 1x. Next 5: 2x. Maximum: 3x.
  static double sizeScaleForHoldTime(double holdSeconds) {
    final index = _tierIndex(holdSeconds);
    if (index >= 8) return 3;
    if (index >= 3) return 2;
    return 1;
  }
}

class ChargeShotResult {
  final int damage;
  final double sizeScale;

  const ChargeShotResult({required this.damage, required this.sizeScale});
}

/// Top-center thermometer: cyan fill while charging, fast drain on release.
class PotencyBar extends PositionComponent with HasGameReference<MyGame> {
  static const double _borderRadius = 10;
  static const double _strokeWidth = 2.5;

  double _fill = 0;
  double _holdSeconds = 0;
  bool _charging = false;
  bool _draining = false;

  bool get isCharging => _charging;

  PotencyBar({Vector2? size})
    : super(
        size: size ?? Vector2(400, 18),
        anchor: Anchor.topLeft,
        priority: 80,
      );

  void beginCharge() {
    _charging = true;
    _draining = false;
    _holdSeconds = 0;
    _fill = 0;
  }

  ChargeShotResult? releaseCharge() {
    if (!_charging) return null;
    final result = ChargeShotResult(
      damage: ChargeShot.damageForHoldTime(_holdSeconds),
      sizeScale: ChargeShot.sizeScaleForHoldTime(_holdSeconds),
    );
    _charging = false;
    _draining = true;
    return result;
  }

  void cancelCharge() {
    _charging = false;
    _draining = _fill > 0;
    _holdSeconds = 0;
  }

  void reset() {
    _charging = false;
    _draining = false;
    _holdSeconds = 0;
    _fill = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final realDt = dt / game.timeScale.clamp(0.001, 100.0);

    if (_charging) {
      _holdSeconds += realDt;
      _fill = (_holdSeconds / ChargeShot.maxChargeSeconds).clamp(0.0, 1.0);
      return;
    }

    if (_draining) {
      _fill -= realDt / ChargeShot.drainSeconds;
      if (_fill <= 0) {
        _fill = 0;
        _draining = false;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(_borderRadius),
    );

    if (_fill > 0) {
      final heat = _fill;
      final fillColor = Color.lerp(
        const Color.fromARGB(231, 0, 255, 170),
        const Color.fromARGB(225, 180, 255, 255),
        heat,
      )!;
      canvas.save();
      canvas.clipRRect(rrect);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x * _fill, size.y),
        Paint()..color = fillColor,
      );
      canvas.restore();
    }

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color.fromARGB(140, 244, 67, 54)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth,
    );
  }
}

/// Floating damage number above a hit enemy; lasts 1 second.
class DamagePopup extends TextComponent {
  static const double lifetime = 1.0;
  double _elapsed = 0;

  DamagePopup({required Vector2 worldPosition, required int damage})
    : super(
        text: '$damage',
        position: worldPosition,
        anchor: Anchor.center,
        priority: 2000,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontSize: 15,
            fontFamily: 'steel700',
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    position.y -= 28 * dt;
    final t = (1 - _elapsed / lifetime).clamp(0.0, 1.0);
    textRenderer = TextPaint(
      style: TextStyle(
        color: const Color.fromARGB(141, 24, 255, 255).withValues(alpha: t),
        fontSize: 10,
        fontFamily: 'steel700',
        fontWeight: FontWeight.w700,
      ),
    );
    if (_elapsed >= lifetime) {
      removeFromParent();
    }
  }
}
