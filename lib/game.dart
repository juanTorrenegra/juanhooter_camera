import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:juanshooter/actors/enemigo.dart';
import 'package:juanshooter/actors/player.dart';
import 'package:juanshooter/hud/game_hud.dart';
import 'package:juanshooter/weapons/bullet.dart';
//tamaño de pantalla = [796.3636474609375,392.7272644042969]
// juego: nave que elimina asteroides para encontrar armas para derrotar monstruos del espacio, escenario: dentro de un imperio y uno es un minero: mision: minar y mejorar la nave para poder acceder a MediumWorld y HardWorld, competir contra otros mineros compitiendo y compartiendo loot.

//prototipo

class MyGame extends FlameGame
    with HasGameReference<MyGame>, HasCollisionDetection {
  late final Player player;
  late final Enemigo enemigo;
  late final Enemigo enemigo1;
  late final Enemigo enemigo2;
  late final Enemigo enemigo3;
  late final Enemigo enemigo4;
  late final Enemigo enemigo5;
  late final Enemigo enemigo6;
  late final Enemigo enemigo7;
  late final Enemigo enemigo8;
  late final Enemigo enemigo9;
  late final Enemigo enemigo10;
  late final Enemigo enemigo11;
  late final Enemigo enemigo12;
  late final Enemigo enemigo13;
  late final Enemigo enemigo14;
  late final Enemigo enemigo15;

  late final GameHud hud;
  late final World universo;
  CameraComponent? camara;
  Vector2 currentPlayerPos = Vector2.zero();

  void fast() {
    // Llama al método del player
    player.toggleFastMode(!player.isFastMode); // Alternar estado
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    //debugMode = true;

    universo = World();
    add(universo);

    camara = CameraComponent(
      world: universo,
      viewfinder: Viewfinder()..anchor = Anchor.center,
    );
    //camara?.viewfinder.anchor = Anchor.center;
    add(camara!);

    final background = SpriteComponent(
      sprite: await Sprite.load('b.png'), //Nebula3.png b.png
      size: Vector2(3000, 1500),
      anchor: Anchor.topLeft,
      position: Vector2(0, 0),
    )..priority = -100;
    universo.add(background);

    player = Player(
      sprite: await Sprite.load('ship.png'),
      position: Vector2(400, 400),
    );
    universo.add(player);

    enemigo = Enemigo(
      sprite: await Sprite.load('5.png'),
      position: Vector2(100, 50),
      size: Vector2(523, 390),
    );
    universo.add(enemigo);

    enemigo1 = Enemigo(
      sprite: await Sprite.load('9B.png'),
      position: Vector2(100, 300),
      //size: Vector2(230, 336),
    );
    universo.add(enemigo1);

    enemigo2 = Enemigo(
      sprite: await Sprite.load('11B.png'),
      position: Vector2(400, 300),
      //size: Vector2(166, 110),
    );
    universo.add(enemigo2);

    enemigo3 = Enemigo(
      sprite: await Sprite.load('3B.png'),
      position: Vector2(550, 400),
      //size: Vector2(182, 248),
    );
    universo.add(enemigo3);

    enemigo4 = Enemigo(
      sprite: await Sprite.load('7B.png'),
      position: Vector2(750, 550),
      //size: Vector2(140, 257),
    );
    universo.add(enemigo4);

    enemigo5 = Enemigo(
      sprite: await Sprite.load('2B.png'),
      position: Vector2(900, 400),
      //size: Vector2(134, 199),
    );
    universo.add(enemigo5);

    enemigo6 = Enemigo(
      sprite: await Sprite.load('8B.png'),
      position: Vector2(1050, 550),
      //size: Vector2(182, 232),
    );
    universo.add(enemigo6);

    enemigo7 = Enemigo(
      sprite: await Sprite.load('4B.png'),
      position: Vector2(1300, 650),
      //size: Vector2(130, 185),
    );
    universo.add(enemigo7);

    enemigo8 = Enemigo(
      sprite: await Sprite.load('12.png'),
      position: Vector2(1450, 600),
      //size: Vector2(342, 122),
    );
    universo.add(enemigo8);

    enemigo9 = Enemigo(
      sprite: await Sprite.load('4.png'),
      position: Vector2(1600, 600),
      //size: Vector2(120, 185),
    );
    universo.add(enemigo9);

    enemigo10 = Enemigo(
      sprite: await Sprite.load('13B.png'),
      position: Vector2(1750, 600),
      //size: Vector2(168, 104),
    );
    universo.add(enemigo10);

    enemigo11 = Enemigo(
      sprite: await Sprite.load('5B.png'),
      position: Vector2(1950, 600),
      //size: Vector2(98, 171),
    );
    universo.add(enemigo11);

    enemigo12 = Enemigo(
      sprite: await Sprite.load('6B.png'),
      position: Vector2(1450, 800),
      //size: Vector2(170, 102),
    );
    universo.add(enemigo12);

    enemigo13 = Enemigo(
      sprite: await Sprite.load('5.png'),
      position: Vector2(1600, 700),
      // size: Vector2(98, 171),
    );
    universo.add(enemigo13);

    enemigo14 = Enemigo(
      sprite: await Sprite.load('1B.png'),
      position: Vector2(1050, 700),
      //size: Vector2(124, 135),
    );
    universo.add(enemigo14);

    enemigo15 = Enemigo(
      sprite: await Sprite.load('10B.png'),
      position: Vector2(900, 700),
      //size: Vector2(116, 110),
    );
    universo.add(enemigo15);

    hud = GameHud()..priority = 100;
    camara?.viewport.add(hud);

    currentPlayerPos = player.position.clone();

    camara?.follow(player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Actualizar posición de depuración
    currentPlayerPos.setFrom(player.position);
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
      speed: 200,
    );
    universo.add(bullet);
    print("posicion = $currentPlayerPos");
    print('Bala disparada desde: ${player.position}');
    print('Posición actual del jugador: $currentPlayerPos');
  }
}
