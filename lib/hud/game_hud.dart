import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class GameHud extends HudCompo with HasGameReference {
  late JoystickComponent moveJoystick;
  late JoystickComponent lookJoystick;
  late HudButtonComponent shootButton;

  Vector2 lastMoveDir = Vector2.zero();
  Vector2 lastLookDir = Vector2.zero();
  bool shootPressed = false;

  GameHud();

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // 🎮 Joystick de movimiento
    moveJoystick = JoystickComponent(
      knob: CircleComponent(radius: 20, paint: Paint()..color = Colors.grey),
      background: CircleComponent(
        radius: 50,
        paint: Paint()..color = Colors.black54,
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );

    // 🎯 Joystick de vista
    lookJoystick = JoystickComponent(
      knob: CircleComponent(radius: 20, paint: Paint()..color = Colors.grey),
      background: CircleComponent(
        radius: 50,
        paint: Paint()..color = Colors.black54,
      ),
      margin: const EdgeInsets.only(right: 40, bottom: 40),
    );

    // 🔫 Botón de disparo
    shootButton = HudButtonComponent(
      button: CircleComponent(radius: 30, paint: Paint()..color = Colors.red),
      margin: const EdgeInsets.only(right: 40, top: 40),
      onPressed: () {
        if (!shootPressed) {
          shootPressed = true;
          print("🔫 Disparo iniciado");
        }
      },
      onReleased: () {
        if (shootPressed) {
          shootPressed = false;
          print("🛑 Disparo detenido");
        }
      },
    );

    addAll([moveJoystick, lookJoystick, shootButton]);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Depuración solo si se mueve el joystick de movimiento
    if (moveJoystick.relativeDelta != lastMoveDir) {
      lastMoveDir = moveJoystick.relativeDelta.clone();
      if (lastMoveDir.length > 0) {
        print("🎮 Movimiento: $lastMoveDir");
      }
    }

    // Depuración solo si se mueve el joystick de vista
    if (lookJoystick.relativeDelta != lastLookDir) {
      lastLookDir = lookJoystick.relativeDelta.clone();
      if (lastLookDir.length > 0) {
        print("🎯 Vista: $lastLookDir");
      }
    }
  }
}
