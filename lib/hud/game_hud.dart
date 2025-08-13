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

  //soluciona El problema de posicionamiento inicial se debe a que size no está disponible hasta que se ejecuta
  //@override
  //void onGameResize(Vector2 size) {
  //  super.onGameResize(size);
  //  //shootButton.position = Vector2(size.x - 100, 60);
  //  if (isLoaded) {
  //    shootButton.position = Vector2(size.x - 100, 60);
  //    lookJoystick.position = Vector2(size.x - 100, size.y - 100);
  //  }
  //}
  //@override
  //void onGameResize(Vector2 size) {
  //  super.onGameResize(size);
  //  // Posicionamiento relativo
  //  movementJoystick.position = Vector2(40, size.y - 40);
  //  lookJoystick.position = Vector2(size.x - 40, size.y - 40);
  //  shootButton.position = Vector2(size.x - 40, 40);
  //}
//

  // Depuración en tiempo real
  //@override
  //void update(double dt) {
  //  super.update(dt);
  //  if (movementJoystick.delta.isZero() == false) {
  //    print("🕹 Movimiento: ${movementJoystick.delta}");
  //  }
  //  if (lookJoystick.delta.isZero() == false) {
  //    print("🎯 Mira: ${lookJoystick.delta}");
  //  }
  //}
//
