import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:juanshooter/actors/player.dart';
import 'package:juanshooter/weapons/bullet.dart';

//pensamientos segundo juego: quiero implementar un videjuego similar dungeons y dragons, empezar en una celda en el inframundo, aprovechar que el movementJoystick tiene diferentes velocidades para implementar el sigilo dependiendo de cuan cerca este a algun enemigo y cuan rapido se mueva para que su presencia no sea detectada

//pensamientos primer juego: nave que elimina asteroides para encontrar armas para derrotar monstruos del espacio, escenario: dentro de un imperio y uno es un minero: mision: minar y mejorar la nave para poder acceder a MediumWorld y HardWorld, competir contra otros mineros compitiendo y compartiendo loot.

class MyGame extends FlameGame with HasGameReference<MyGame> {
  late final JoystickComponent movementJoystick;
  late final JoystickComponent lookJoystick;
  late final Player player;
  //late final ButtonComponent shootButton;
  late final HudButtonComponent shootButton;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final sprite = await Sprite.load('ship.png');
    player = Player(sprite: sprite, position: Vector2(200, 200));
    add(player);

    movementJoystick = JoystickComponent(
      //pregunta: si la instancia de este bloque es late final JoystickComponent movementJoystick; entonces aqui en este  movementJoystick que es? es para saber mas del lingo de flutter y dart, es esto tambien una estancia? aqui se que se crea el componente y se instancia arriba, cierto?
      knob: CircleComponent(radius: 30, paint: Paint()..color = Colors.grey),
      background: CircleComponent(
        radius: 50,
        paint: Paint()..color = Colors.blueGrey,
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    add(movementJoystick);

    lookJoystick = JoystickComponent(
      knob: CircleComponent(radius: 30, paint: Paint()..color = Colors.grey),
      background: CircleComponent(
        radius: 50,
        paint: Paint()..color = Colors.blueGrey,
      ),
      margin: const EdgeInsets.only(right: 40, bottom: 40),
      //position: Vector2(size.x - 100, size.y - 100),
    );
    add(lookJoystick);

    shootButton = HudButtonComponent(
      button: CircleComponent(radius: 40, paint: Paint()..color = Colors.blue),
      //position: Vector2(size.x - 100, 60),
      onPressed: _shoot,
      priority: 10,
    );
    add(shootButton);
  }

  //asegura la posicion de los botones y joystics (se estaba posicionando antes de saber el size, en la mitad)
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    //shootButton.position = Vector2(size.x - 100, 60);
    if (isLoaded) {
      shootButton.position = Vector2(size.x - 100, 60);
      lookJoystick.position = Vector2(size.x - 100, size.y - 100);
    }
  }

  void _shoot() {
    final bullet = Bullet(
      position: player.position.clone(),
      angle: player.angle,
      speed: 300,
    );
    add(bullet);
  }
}
