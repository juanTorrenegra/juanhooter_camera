import 'package:flame/components.dart';

import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:juanshooter/game.dart';

class HealthBar extends PositionComponent {
  int maxHealth;
  int currentHealth;
  double width;
  double height;

  HealthBar({
    required this.maxHealth,
    required this.currentHealth,
    this.width = 200,
    this.height = 20,
  });

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final borderRadius = height / 2;

    // Fondo de la barra con bordes redondos
    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, height),
      Radius.circular(borderRadius),
    );
    final backgroundPaint = Paint()..color = Colors.red.withAlpha(150);
    canvas.drawRRect(backgroundRect, backgroundPaint);

    // Barra de vida actual con bordes redondos
    final healthPercentage = currentHealth / maxHealth;
    final healthWidth = width * healthPercentage;

    if (healthWidth > 0) {
      final healthRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, healthWidth, height),
        Radius.circular(borderRadius),
      );

      final healthPaint = Paint()
        ..color = _getHealthColor(healthPercentage)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(healthRect, healthPaint);

      // Borde de la barra
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawRRect(backgroundRect, borderPaint);
    }
  }

  Color _getHealthColor(double percentage) {
    if (percentage > 0.6) return Colors.cyanAccent;
    if (percentage > 0.3) return Colors.orange;
    return Colors.red;
  }

  void updateHealth(int current, int max) {
    currentHealth = current;
    maxHealth = max;
  }
}

class GameHud extends PositionComponent with HasGameReference<MyGame> {
  late final JoystickComponent movementJoystick;
  late final JoystickComponent lookJoystick;
  late final HudButtonComponent shootButton;
  late final HudButtonComponent fastButton;
  late final HudButtonComponent menu;
  late final CustomPainterComponent hudVisor;
  late final HealthBar healthBar;

  late final TextComponent shipsDestroyedText;

  late final HudButtonComponent debugMenuButton;

  @override
  Future<void> onLoad() async {
    movementJoystick = JoystickComponent(
      knob: CircleComponent(
        radius: 30,
        paint: Paint()
          ..color = Colors.red.withAlpha(150)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.3,
      ),
      background: CircleComponent(
        radius: 50,
        paint: Paint()
          ..color = Colors.red.withAlpha(150)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.3,
      ),
    );

    lookJoystick = JoystickComponent(
      knob: CircleComponent(
        radius: 30,
        paint: Paint()
          ..color = Colors.red.withAlpha(150)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.3,
      ),
      background: CircleComponent(
        radius: 50,
        paint: Paint()
          ..color = Colors.red.withAlpha(150)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.3,
      ),
    );

    shootButton = HudButtonComponent(
      button: CircleComponent(
        radius: 40,
        paint: Paint()
          ..color = Colors.red.withAlpha(150)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.3,
      ),

      onPressed: () => game.player.shoot(),
    );

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
      },
    );

    healthBar = HealthBar(
      maxHealth: game.player.maxHitPoints,
      currentHealth: game.player.currentHitPoints,
      width: 200,
      height: 20,
    );

    shipsDestroyedText = TextComponent(
      text: '0',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.cyanAccent,
          fontSize: 44,
          fontFamily: "Megatrans",
        ),
      ),
    );

    debugMenuButton = HudButtonComponent(
      button: RectangleComponent(
        size: Vector2(40, 40),
        paint: Paint()
          ..color = Colors.blue.withAlpha(100)
          ..style = PaintingStyle.fill,
      ),
      onPressed: () {
        // Abrir el overlay del debug menu
        game.overlays.add('DebugMenu');
      },
    );

    // Añadir componentes al HUD
    add(menu);
    add(movementJoystick);
    add(lookJoystick);
    add(shootButton);
    add(fastButton);

    add(healthBar);
    add(shipsDestroyedText);
    add(debugMenuButton);

    _positionComponents();
  }

  void updateShipsDestroyed(int count) {
    shipsDestroyedText.text = '$count';
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
    // Solo posiciona si los componentes están cargados y el tamaño es válido
    if (isLoaded && game.size.x > 0 && game.size.y > 0) {
      final margin = 30.0; // Ajusta este valor según necesites
      final joystickSize = 100.0; // Tamaño del joystick (radio + margen)

      // Posiciona el joystick de movimiento (abajo-izquierda)
      movementJoystick.position = Vector2(
        margin + joystickSize / 2,
        game.size.y - margin - joystickSize / 2,
      );

      // Posiciona el joystick de mira (abajo-derecha)
      lookJoystick.position = Vector2(
        game.size.x - margin - joystickSize / 2,
        game.size.y - margin - joystickSize / 2,
      );

      // Posiciona el botón de disparo (arriba-derecha)
      shootButton.position = Vector2(game.size.x - 160, 20);
      menu.position = Vector2(game.size.x / 2 - 15, game.size.y - 60);

      healthBar.position = Vector2((game.size.x - healthBar.width) / 2, 20);
      shipsDestroyedText.position = Vector2(margin + 150, margin);

      debugMenuButton.position = Vector2(20, 20);
    }
  }
}
