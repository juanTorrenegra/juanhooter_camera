import 'package:flame/components.dart';

import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:juanshooter/game.dart'; // Importa tu archivo game.dart

class GameHud extends PositionComponent with HasGameReference<MyGame> {
  late final JoystickComponent movementJoystick;
  late final JoystickComponent lookJoystick;
  late final HudButtonComponent shootButton;
  late final HudButtonComponent fastButton;
  late final HudButtonComponent menu;
  late final CustomPainterComponent hudVisor;

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

    fastButton = HudButtonComponent(
      button: CircleComponent(
        radius: 20,
        paint: Paint()..color = Colors.red,
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

    menu = HudButtonComponent(
      button: TextComponent(
        text: String.fromCharCode(Icons.airplay_sharp.codePoint),
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 60,
            fontFamily: Icons.screen_rotation.fontFamily,
            package: Icons.screen_rotation.fontPackage,
            color: Colors.cyanAccent,
          ),
        ),
      ),
      onPressed: () {
        game.overlays.add("MainMenu");
      },
    );

    // Añadir componentes al HUD
    add(menu);
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
      fastButton.position = Vector2(margin, margin);
      menu.position = Vector2(game.size.x / 2 - 30, game.size.y - 60);
    }
  }
}
