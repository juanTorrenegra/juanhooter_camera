import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:juanshooter/actors/player.dart';
import 'package:juanshooter/hud/game_hud.dart';
import 'package:juanshooter/weapons/bullet.dart';

//pensamientos segundo juego: quiero implementar un videjuego similar dungeons y dragons, empezar en una celda en el inframundo, aprovechar que el movementJoystick tiene diferentes velocidades para implementar el sigilo dependiendo de cuan cerca este a algun enemigo y cuan rapido se mueva para que su presencia no sea detectada

//pensamientos primer juego: nave que elimina asteroides para encontrar armas para derrotar monstruos del espacio, escenario: dentro de un imperio y uno es un minero: mision: minar y mejorar la nave para poder acceder a MediumWorld y HardWorld, competir contra otros mineros compitiendo y compartiendo loot.

class MyGame extends FlameGame with HasGameReference<MyGame> {
  late final Player player;
  late final GameHud hud;
  CameraComponent? _camera;

  @override
  Future<void> onLoad() async {
    print("se inicia el on Load");
    await super.onLoad();

    final sprite = await Sprite.load('ship.png');
    player = Player(sprite: sprite, position: Vector2(200, 200));
    print("se crea el player");
    add(player);
    print("se añade el player");

    hud = GameHud();
    print("se crea el hud");
    add(hud);
    print("se añade el hud");

    _camera = CameraComponent(world: World());
    print("se crea la camara");
    add(_camera!);
    print("se añade la camara");
    _camera!.viewfinder.anchor = Anchor.center;
    _camera!.viewfinder.position = Vector2(size.x / 2, size.y / 2);
  }

  @override
  void onGameResize(Vector2 size) {
    debugPrint('4. onGameResize (camera is $_camera)');
    super.onGameResize(size);
  }

  void shoot() {
    final bullet = Bullet(
      position: player.position.clone(),
      angle: player.angle,
      speed: 300,
    );
    add(bullet);
    print("se crea el bullet");
  }
}
