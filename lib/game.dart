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
  CameraComponent? _camera;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    universo = World();
    _camera = CameraComponent(world: universo);
    _camera!.viewfinder.anchor = Anchor.center;
    _camera!.viewfinder.position = Vector2(size.x / 2, size.y / 2);

    final sprite = await Sprite.load('ship.png');
    player = Player(sprite: sprite, position: Vector2(size.x / 2, size.y / 2));
    hud = GameHud();

    add(universo);
    add(_camera!);
    add(hud);

    universo.add(player);
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
    //print("se crea el bullet");
  }
}



//class MyGame extends FlameGame with HasGameReference<MyGame> {
//  late final Player player;
//  late final GameHud hud;
//  late final World universo;
//  CameraComponent? _camera;
//
//  @override
//  Future<void> onLoad() async {
//    //print("se inicia el on Load");
//    await super.onLoad();
//
//    universo = World();
//    //print("se crea el mundo");
//    add(universo);
//    //print("se añade el mundo");
//
//    _camera = CameraComponent(world: universo);
//    //print("se crea la camara");
//
//    //_camera!.viewfinder.anchor = Anchor.topLeft;
//    //_camera!.viewfinder.position = Vector2(size.x / 2, size.y / 2);
//
//    player = Player(
//      sprite: await Sprite.load('ship.png'),
//      position: Vector2(200, 200),
//    );
//    //print("se crea el player");
//    world.add(player);
//    //print("se añade el player");
//
//    final background = SpriteComponent(
//      sprite: await Sprite.load('test.png'),
//      size: Vector2(1600, 1600),
//      //priority: -100,
//    )..priority = -1;
//    //print("se crea el background");
//    //background.position = Vector2(size.x / 2, size.y / 2);
//    //background.anchor = Anchor.topLeft;
//    //background.position = Vector2(800, 800); // Centro del mundo (1600x1600)
//    //print("se crea la posicion del background ");
//    world.add(background);
//    //print("se añade el background");
//
//    add(_camera!);
//    //print("se añade la camara");
//
//    hud = GameHud();
//    //print("se crea el hud");
//    add(hud);
//    //print("se añade el hud");
//  }