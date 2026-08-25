import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Matrix4;
import 'package:flutter/services.dart';
import 'package:juanshooter/game.dart';
import 'package:juanshooter/hud/potency_bar.dart';
import 'package:juanshooter/overlays/informacion_juego.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class HealthBar extends PositionComponent with HasGameReference<MyGame> {
  int maxHealth;
  int currentHealth;
  double width;
  double height;

  static const double _labelGap = 10;
  static const double _skewX = -0.14;
  static const double _labelPad = 4;

  final TextStyle _labelStyle = const TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: "steel700",
  );

  /// Ancho reservado a la izquierda para el número (estable según `maxHealth`).
  double _labelReservedWidth = 0;

  static const double _maxHpPulseDuration = 0.5;
  static const double _maxHpPulseAmplitude = 2.0;
  double _maxHpPulseElapsed = 0;
  bool _maxHpPulseActive = false;

  HealthBar({
    required this.maxHealth,
    required this.currentHealth,
    this.width = 200,
    this.height = 10,
  }) {
    _refreshLabelReserve();
    size = Vector2(layoutWidth, height);
  }

  /// Ancho total: número + separación + barra (para centrar el HUD).
  double get layoutWidth => _labelReservedWidth + _labelGap + width;

  void _refreshLabelReserve() {
    final tpMax = TextPainter(
      text: TextSpan(text: '$maxHealth', style: _labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final tpCur = TextPainter(
      text: TextSpan(text: '$currentHealth', style: _labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    _labelReservedWidth = math.max(tpMax.width, tpCur.width) + _labelPad * 2;
    size = Vector2(layoutWidth, height);
  }

  double _labelPulseScale() {
    if (!_maxHpPulseActive) return 1.0;
    final t = (_maxHpPulseElapsed / _maxHpPulseDuration).clamp(0.0, 1.0);
    return 1.0 + _maxHpPulseAmplitude * math.sin(math.pi * t);
  }

  void _startMaxHpPulse() {
    _maxHpPulseElapsed = 0;
    _maxHpPulseActive = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_maxHpPulseActive) {
      // `dt` sigue al timeScale del juego; normalizamos para ~0.5s reales.
      final realDt = dt / game.timeScale.clamp(0.001, 100.0);
      _maxHpPulseElapsed += realDt;
      if (_maxHpPulseElapsed >= _maxHpPulseDuration) {
        _maxHpPulseActive = false;
        _maxHpPulseElapsed = 0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final labelPainter = TextPainter(
      text: TextSpan(text: '$currentHealth', style: _labelStyle),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: _labelReservedWidth);

    final labelX = _labelReservedWidth - labelPainter.width;
    final labelY = (height - labelPainter.height) / 2;
    final cx = labelX + labelPainter.width / 2;
    final cy = labelY + labelPainter.height / 2;
    final scale = _labelPulseScale();

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);
    canvas.translate(-cx, -cy);
    labelPainter.paint(canvas, Offset(labelX, labelY));
    canvas.restore();

    final borderRadius = height / 2;
    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, height),
      Radius.circular(borderRadius),
    );
    final backgroundPaint = Paint()
      ..color = const Color.fromARGB(88, 244, 54, 54).withAlpha(150);

    final healthPercentage = maxHealth > 0
        ? (currentHealth / maxHealth).clamp(0.0, 1.0)
        : 0.0;
    final healthWidth = width * healthPercentage;

    final healthPaint = Paint()
      ..color = _getHealthColor(healthPercentage)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(_labelReservedWidth + _labelGap, 0);
    canvas.transform(vm.Matrix4.skewX(_skewX).storage);
    canvas.drawRRect(backgroundRect, backgroundPaint);
    if (healthWidth > 0) {
      final fillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, healthWidth, height),
        Radius.circular(borderRadius),
      );
      canvas.drawRRect(fillRect, healthPaint);
    }
    canvas.restore();
  }

  Color _getHealthColor(double percentage) {
    if (percentage > 0.6) return const Color.fromARGB(130, 24, 255, 255);
    if (percentage > 0.3) return Colors.orange;
    return Colors.red;
  }

  void updateHealth(int current, int max) {
    final prevMax = maxHealth;
    final maxIncreased = max > prevMax;
    final maxChanged = max != maxHealth;
    currentHealth = current;
    maxHealth = max;
    if (maxIncreased) {
      _startMaxHpPulse();
    }
    if (maxChanged) {
      _refreshLabelReserve();
    } else {
      size = Vector2(layoutWidth, height);
    }
  }
}

class GameHud extends PositionComponent
    with HasGameReference<MyGame>, TapCallbacks {
  /// Touch controls: only created on mobile/desktop apps, never on web.
  JoystickComponent? movementJoystick;
  JoystickComponent? lookJoystick;
  HudButtonComponent? shootButton;
  late final HudButtonComponent menu;
  late final HealthBar healthBar;
  late final HudButtonComponent debugMenuButton;
  late final InformacionJuego informacionJuego;
  late final PotencyBar potencyBar;

  /// Web (WASD): dirección normalizada; en otras plataformas permanece en cero.
  final Vector2 _keyboardMovement = Vector2.zero();
  final Vector2 _webMouseLookDelta = Vector2.zero();
  bool _hasWebMouseLookDelta = false;

  bool _spaceWasDown = false;
  bool _chargeHeld = false;

  /// Movimiento: WASD en web; joysticks en app.
  Vector2 get effectiveMovementDelta {
    if (kIsWeb) {
      if (_keyboardMovement.length2 > 0.0001) {
        return _keyboardMovement;
      }
      return Vector2.zero();
    }
    final joystick = movementJoystick;
    if (joystick != null && joystick.direction != JoystickDirection.idle) {
      return joystick.relativeDelta;
    }
    return Vector2.zero();
  }

  /// Rotación: mouse en web; look joystick en app.
  Vector2 get effectiveLookDelta {
    if (kIsWeb) {
      if (_hasWebMouseLookDelta && _webMouseLookDelta.length2 > 0.0001) {
        return _webMouseLookDelta;
      }
      return Vector2.zero();
    }
    final joystick = lookJoystick;
    if (joystick != null && joystick.direction != JoystickDirection.idle) {
      return joystick.relativeDelta;
    }
    return Vector2.zero();
  }

  /// Actualiza el vector de apuntado desde una posición objetivo en mundo.
  void setWebMouseWorldTarget(Vector2 worldTarget) {
    if (!kIsWeb || !game.player.isMounted) return;
    _webMouseLookDelta.setFrom(worldTarget - game.player.position);
    _hasWebMouseLookDelta = _webMouseLookDelta.length2 > 0.0001;
  }

  void _syncWebKeyboardInput() {
    if (!kIsWeb) return;
    final kb = HardwareKeyboard.instance;
    double x = 0;
    double y = 0;
    if (kb.isLogicalKeyPressed(LogicalKeyboardKey.keyW)) y -= 1;
    if (kb.isLogicalKeyPressed(LogicalKeyboardKey.keyS)) y += 1;
    if (kb.isLogicalKeyPressed(LogicalKeyboardKey.keyA)) x -= 1;
    if (kb.isLogicalKeyPressed(LogicalKeyboardKey.keyD)) x += 1;
    _keyboardMovement.setValues(x, y);
    if (_keyboardMovement.length2 > 0) {
      _keyboardMovement.normalize();
    }

    final spaceDown = kb.isLogicalKeyPressed(LogicalKeyboardKey.space);
    if (spaceDown && !_spaceWasDown && !game.paused) {
      beginCharge();
    } else if (!spaceDown && _spaceWasDown) {
      releaseCharge();
    }
    _spaceWasDown = spaceDown;
  }

  void beginCharge() {
    if (_chargeHeld || game.paused || !game.player.isMounted) return;
    _chargeHeld = true;
    potencyBar.beginCharge();
    game.player.applyChargeSlowdown();
  }

  void releaseCharge() {
    if (!_chargeHeld) return;
    _chargeHeld = false;
    final shot = potencyBar.releaseCharge();
    game.player.restoreChargeSpeed();
    if (shot != null && !game.paused && game.player.isMounted) {
      game.player.shoot(
        damage: shot.damage,
        sizeScale: shot.sizeScale,
        sfx: shot.shotSound,
      );
    }
  }

  void cancelCharge() {
    if (_chargeHeld) {
      _chargeHeld = false;
      game.player.restoreChargeSpeed();
    }
    potencyBar.cancelCharge();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!kIsWeb) return;
    beginCharge();
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (!kIsWeb) return;
    releaseCharge();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _syncWebKeyboardInput();
  }

  @override
  Future<void> onLoad() async {
    if (!kIsWeb) {
      movementJoystick = JoystickComponent(
        knob: CircleComponent(
          radius: 50,
          paint: Paint()
            ..color = Colors.cyan.withAlpha(150)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.3,
        ),
        background: CircleComponent(
          radius: 80,
          paint: Paint()
            ..color = Colors.cyan.withAlpha(50)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.3,
        ),
      );
      lookJoystick = JoystickComponent(
        knob: CircleComponent(
          radius: 50,
          paint: Paint()
            ..color = Colors.cyan.withAlpha(150)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.3,
        ),
        background: CircleComponent(
          radius: 80,
          paint: Paint()
            ..color = Colors.cyan.withAlpha(50)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.3,
        ),
      );
      shootButton = HudButtonComponent(
        button: SkewedShootPad(
          fillColor: Colors.cyan.withAlpha(50),
          strokeColor: Colors.cyan.withAlpha(180),
        ),
        buttonDown: SkewedShootPad(
          fillColor: Colors.cyan.withAlpha(140),
          strokeColor: Colors.cyanAccent,
        ),
        onPressed: beginCharge,
        onReleased: releaseCharge,
        onCancelled: releaseCharge,
      );
    }

    menu = HudButtonComponent(
      button: TextComponent(
        text: "A",
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 50,
            fontFamily: "ava",
            color: Colors.cyanAccent.withValues(alpha: 120),
          ),
        ),
      ),
      onPressed: () {
        game.overlays.add("MainMenu");
        //game.setTimeScale(0.0);
        game.pauseEngine();
        game.pauseBgmMusic();
      },
    );
    healthBar = HealthBar(
      maxHealth: game.player.maxHitPoints,
      currentHealth: game.player.currentHitPoints,
      width: 300,
      height: 40,
    );

    debugMenuButton = HudButtonComponent(
      button: RectangleComponent(
        size: Vector2(30, 30),
        paint: Paint()
          ..color = Colors.green.withAlpha(20)
          ..style = PaintingStyle.fill,
      ),
      onPressed: () {
        game.overlays.add('DebugMenu');
      },
    );

    informacionJuego = InformacionJuego()..priority = 1000;
    potencyBar = PotencyBar();

    add(menu);
    final move = movementJoystick;
    final look = lookJoystick;
    final shoot = shootButton;
    if (move != null) add(move);
    if (look != null) add(look);
    if (shoot != null) add(shoot);
    add(healthBar);
    add(debugMenuButton);
    add(informacionJuego);
    add(potencyBar);

    _positionComponents();
  }

  void toggleGameInfo() {
    informacionJuego.toggleVisibility();
  }

  void updateHealthBar(int currentHealth, int maxHealth) {
    healthBar.updateHealth(currentHealth, maxHealth);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _positionComponents();
  }

  void _positionComponents() {
    // HUD lives in the fixed 1280x720 viewport virtual space.
    if (!isLoaded) return;
    final viewSize =
        game.camara?.viewport.virtualSize ??
        Vector2(MyGame.logicalWidth, MyGame.logicalHeight);
    if (viewSize.x <= 0 || viewSize.y <= 0) return;

    size = viewSize;
    position = Vector2.zero();

    final joystickY = viewSize.y * 3 / 4;
    movementJoystick?.position = Vector2(viewSize.x * 1 / 8, joystickY);
    lookJoystick?.position = Vector2(viewSize.x * 7 / 8, joystickY);
    shootButton?.position = Vector2(viewSize.x - 350, 40);
    menu.position = Vector2(viewSize.x / 2 - 15, viewSize.y - 60);
    healthBar.position = Vector2(200, 100);
    debugMenuButton.position = Vector2(10, 40);
    informacionJuego.position = Vector2(80, 260);
    potencyBar.position = Vector2((viewSize.x - potencyBar.size.x) / 2, 24);
  }
}

/// Opposite skew of [InformacionJuego] (`-0.14`).
class SkewedShootPad extends PositionComponent {
  static const double skewX = 0.30;

  final Color fillColor;
  final Color strokeColor;

  SkewedShootPad({
    required this.fillColor,
    required this.strokeColor,
    Vector2? size,
  }) : super(size: size ?? Vector2(250, 80));

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.transform(vm.Matrix4.skewX(skewX).storage);
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(10),
    );
    canvas.drawRRect(rrect, Paint()..color = fillColor);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();
  }
}
