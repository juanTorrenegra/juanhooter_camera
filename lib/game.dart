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

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final sprite = await Sprite.load('ship.png');
    player = Player(sprite: sprite, position: Vector2(200, 200));
    add(player);

    hud = GameHud();
    add(hud);
  }

  void shoot() {
    final bullet = Bullet(
      position: player.position.clone(),
      angle: player.angle,
      speed: 300,
    );
    add(bullet);
  }
}
