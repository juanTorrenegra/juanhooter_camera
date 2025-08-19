import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:juanshooter/game.dart'; // Importa tu archivo game.dart

class GameHud extends PositionComponent with HasGameReference<MyGame> {
  late final JoystickComponent movementJoystick;
  late final JoystickComponent lookJoystick;
  late final HudButtonComponent shootButton;
  late final HudButtonComponent fastButton;

  @override
  Future<void> onLoad() async {
    movementJoystick = JoystickComponent(
      knob: CircleComponent(
        radius: 30,
        paint: Paint()
          ..color = Colors.cyan.withAlpha(150)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      ),
      background: CircleComponent(
        radius: 50,
        paint: Paint()
          ..color = Colors.cyan.withAlpha(150)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      ),
    );

    lookJoystick = JoystickComponent(
      knob: CircleComponent(
        radius: 30,
        paint: Paint()
          ..color = Colors.cyan.withAlpha(150)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      ),
      background: CircleComponent(
        radius: 50,
        paint: Paint()
          ..color = Colors.cyan.withAlpha(150)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      ),
    );

    shootButton = HudButtonComponent(
      button: CircleComponent(
        radius: 40,
        paint: Paint()
          ..color = Colors.cyan.withAlpha(150)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      ),

      onPressed: () => game.shoot(),
    );

    fastButton = HudButtonComponent(
      button: CircleComponent(
        radius: 20,
        paint: Paint()..color = Colors.red.shade900,
        children: [
          TextComponent(
            position: Vector2(6, 12),
            text: 'Fast',
            textRenderer: TextPaint(
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
      onPressed: () => game.fast(),
    );

    // Añadir componentes al HUD
    add(movementJoystick);
    add(lookJoystick);
    add(shootButton);
    add(fastButton);

    _positionComponents();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _positionComponents();
  }

  void _positionComponents() {
    // Solo posiciona si los componentes están cargados y el tamaño es válido
    if (isLoaded && game.size.x > 0 && game.size.y > 0) {
      final margin = 60.0; // Ajusta este valor según necesites
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
      shootButton.position = Vector2(
        game.size.x - margin - 40, // 40 = radio del botón
        margin,
      );
      fastButton.position = Vector2(margin, margin);
    }
  }
}
