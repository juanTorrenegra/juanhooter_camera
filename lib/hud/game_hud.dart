import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:juanshooter/game.dart'; // Importa tu archivo game.dart

class GameHud extends PositionComponent with HasGameReference<MyGame> {
  late final JoystickComponent movementJoystick;
  late final JoystickComponent lookJoystick;
  late final HudButtonComponent shootButton;

  @override
  Future<void> onLoad() async {
    // Configuración del joystick de movimiento
    movementJoystick = JoystickComponent(
      knob: CircleComponent(radius: 30, paint: Paint()..color = Colors.grey),
      background: CircleComponent(
        radius: 50,
        paint: Paint()..color = Colors.blueGrey,
      ),
    );

    // Configuración del joystick de mira
    lookJoystick = JoystickComponent(
      knob: CircleComponent(radius: 30, paint: Paint()..color = Colors.grey),
      background: CircleComponent(
        radius: 50,
        paint: Paint()..color = Colors.blueGrey,
      ),
    );

    // Configuración del botón de disparo
    shootButton = HudButtonComponent(
      button: CircleComponent(radius: 40, paint: Paint()..color = Colors.blue),

      onPressed: () => game.shoot(),
    );

    // Añadir componentes al HUD
    add(movementJoystick);
    add(lookJoystick);
    add(shootButton);

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
    }
  }
}
