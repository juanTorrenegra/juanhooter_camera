import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:juanshooter/actors/player.dart';
import 'package:juanshooter/hud/game_hud.dart';
import 'package:juanshooter/weapons/bullet.dart';

//pensamientos primer juego: nave que elimina asteroides para encontrar armas para derrotar monstruos del espacio, escenario: dentro de un imperio y uno es un minero: mision: minar y mejorar la nave para poder acceder a MediumWorld y HardWorld, competir contra otros mineros compitiendo y compartiendo loot.

//implementar test.png ABAJO!!!
class MyGame extends FlameGame with HasGameReference<MyGame> {
  late final Player player;
  late final GameHud hud;
  late final World universo;
  CameraComponent? camara;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    universo = World();
    camara = CameraComponent(world: universo);
    camara!.viewfinder.anchor = Anchor.center;
    camara!.viewfinder.position = Vector2(size.x / 2, size.y / 2);
    final background = SpriteComponent(
      sprite: await Sprite.load('test.png'),
      size: Vector2(1600, 1600),
    );
    //background.position = Vector2(size.x / 2, size.y / 2);

    final sprite = await Sprite.load('ship.png');
    player = Player(sprite: sprite, position: Vector2(size.x / 2, size.y / 2));
    hud = GameHud()..priority = 10;

    add(universo);
    add(camara!);
    add(hud);

    universo.add(background);
    universo.add(player);
  }

  @override
  void onGameResize(Vector2 size) {
    debugPrint('4. onGameResize (camera is $camara)');
    super.onGameResize(size);
  }

  void shoot() {
    final bullet = Bullet(
      position: player.position.clone(),
      angle: player.angle,
      speed: 300,
    );
    add(bullet);
    //print("se crea el bullet");
  }
}
