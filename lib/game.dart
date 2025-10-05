import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:juanshooter/actors/enemigo.dart';
import 'package:juanshooter/actors/player.dart';
import 'package:juanshooter/actors/ranged_enemy.dart';
import 'package:juanshooter/hud/game_hud.dart';
import 'package:flame_audio/flame_audio.dart';
//tamaño de pantalla = [796.3636474609375,392.7272644042969]
// juego: nave que elimina asteroides para encontrar armas para derrotar monstruos del espacio, escenario: dentro de un imperio y uno es un minero: mision: minar y mejorar la nave para poder acceder a MediumWorld y HardWorld, competir contra otros mineros compitiendo y compartiendo loot.

//prototipo

class MyGame extends FlameGame
    with HasGameReference<MyGame>, HasCollisionDetection {
  MyGame();

  late final Player player;
  late final RangedEnemy mineroTorretas;
  late final RangedEnemy enemigo1;
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
  late final Enemigo enemigo16;
  late final Enemigo enemigo17;
  late final Enemigo enemigo18;
  late final Enemigo enemigo19;
  late final Enemigo enemigo20;

  late final GameHud hud;
  late final World universo;
  CameraComponent? camara;
  Vector2 currentPlayerPos = Vector2.zero();
  late AudioPool pool;
  double timeScale = 1.0;

  void fast() {
    // Llama al método del player
    player.toggleFastMode(!player.isFastMode); // Alternar estado
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    //debugMode = true;
    pool = await FlameAudio.createPool(
      'fire_2.mp3',
      minPlayers: 1,
      maxPlayers: 3,
    );
    startBgmMusic();

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
      sprite: await Sprite.load('ship.png'), // SIMULAR RELOAD LASERS
      position: Vector2(380, 380),
    );
    player.maxHitPoints = 10;
    player.currentHitPoints = 10;
    universo.add(player);

    mineroTorretas = RangedEnemy(
      sprite: await Sprite.load('5.png'), //MINERO
      position: Vector2(100, 100),
      size: Vector2(530, 300),
      maxHitPoints: 550,
      rotationSpeed: 0.4,
      bulletSpeed: 100,
      shootingThreshold: 30,
      damage: 5,
    );

    universo.add(mineroTorretas);

    enemigo1 = RangedEnemy(
      sprite: await Sprite.load('9B.png'), //IZQUIERDA
      position: Vector2(100, 400),
      size: Vector2(140, 220),
      maxHitPoints: 10,
      rotationSpeed: 3.0,
      bulletSpeed: 100,
      shootingThreshold: 30,
      damage: 2,
    );
    universo.add(enemigo1);

    enemigo2 = RangedEnemy(
      sprite: await Sprite.load('11B.png'), //morado
      position: Vector2(400, 300),
      //size: Vector2(166, 110),
      maxHitPoints: 10,
      rotationSpeed: 3.0,
      bulletSpeed: 100,
      shootingThreshold: 30,
      damage: 1,
    );
    universo.add(enemigo2);

    enemigo3 = RangedEnemy(
      sprite: await Sprite.load('3B.png'), //derecha
      position: Vector2(550, 400),
      rotationSpeed: 4.0,
      maxHitPoints: 10,
      bulletSpeed: 100,
      shootingThreshold: 30,
      damage: 1,
      //size: Vector2(150, 220),
    );
    universo.add(enemigo3);

    enemigo4 = RangedEnemy(
      sprite: await Sprite.load('7B.png'),
      position: Vector2(750, 550),
      maxHitPoints: 10,
      bulletSpeed: 100,
      shootingThreshold: 30,
      damage: 1,
      //size: Vector2(140, 257),
    );
    universo.add(enemigo4);

    hud = GameHud()..priority = 100;
    camara?.viewport.add(hud);

    currentPlayerPos = player.position.clone();

    camara?.follow(player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    super.update(dt * timeScale);
    // Actualizar posición de depuración
    currentPlayerPos.setFrom(player.position);
  }

  @override
  void onGameResize(Vector2 size) {
    debugPrint('4. onGameResize (camera is $camara)');
    super.onGameResize(size);

    debugPrint("🔄 onGameResize - Tamaño: $size ");
  }
}

void startBgmMusic() {
  FlameAudio.bgm.initialize();
  FlameAudio.bgm.play('bg_music.ogg');
}


//
//    enemigo5 = RangedEnemy(
//      sprite: await Sprite.load('2B.png'),
//      position: Vector2(900, 400),
//      maxHitPoints: 10,
//      bulletSpeed: 100,
//      shootingThreshold: 30,
//      damage: 1,
//      //size: Vector2(134, 199),
//    );
//    universo.add(enemigo5);
//
//    enemigo6 = RangedEnemy(
//      sprite: await Sprite.load('9B.png'),
//      position: Vector2(100, 800),
//      size: Vector2(140, 220),
//      maxHitPoints: 20,
//      rotationSpeed: 3.0,
//      bulletSpeed: 115,
//      shootingThreshold: 30,
//      damage: 4,
//    );
//    universo.add(enemigo6);
//
//    enemigo7 = RangedEnemy(
//      sprite: await Sprite.load('11B.png'),
//      position: Vector2(400, 700),
//      maxHitPoints: 20,
//      rotationSpeed: 3.0,
//      bulletSpeed: 115,
//      shootingThreshold: 30,
//      damage: 2,
//    );
//    universo.add(enemigo7);
//
//    enemigo8 = RangedEnemy(
//      sprite: await Sprite.load('3B.png'),
//      position: Vector2(550, 800),
//      maxHitPoints: 20,
//      rotationSpeed: 4.0,
//      bulletSpeed: 115,
//      shootingThreshold: 30,
//      damage: 2,
//    );
//    universo.add(enemigo8);
//
//    enemigo9 = RangedEnemy(
//      sprite: await Sprite.load('7B.png'),
//      position: Vector2(750, 950),
//      maxHitPoints: 20,
//      bulletSpeed: 115,
//      shootingThreshold: 30,
//      damage: 2,
//    );
//    universo.add(enemigo9);
//
//    enemigo10 = RangedEnemy(
//      sprite: await Sprite.load('2B.png'),
//      position: Vector2(900, 800),
//      maxHitPoints: 20,
//      bulletSpeed: 115,
//      shootingThreshold: 30,
//      damage: 2,
//    );
//    universo.add(enemigo10);
//    enemigo11 = RangedEnemy(
//      sprite: await Sprite.load('9B.png'),
//      position: Vector2(100, 1200),
//      size: Vector2(140, 220),
//      maxHitPoints: 40,
//      rotationSpeed: 3.0,
//      bulletSpeed: 130,
//      shootingThreshold: 30,
//      damage: 8,
//    );
//    universo.add(enemigo11);
//
//    enemigo12 = RangedEnemy(
//      sprite: await Sprite.load('11B.png'),
//      position: Vector2(400, 1100),
//      maxHitPoints: 40,
//      rotationSpeed: 3.0,
//      bulletSpeed: 130,
//      shootingThreshold: 30,
//      damage: 4,
//    );
//    universo.add(enemigo12);
//
//    enemigo13 = RangedEnemy(
//      sprite: await Sprite.load('3B.png'),
//      position: Vector2(550, 1200),
//      maxHitPoints: 40,
//      rotationSpeed: 4.0,
//      bulletSpeed: 130,
//      shootingThreshold: 30,
//      damage: 4,
//    );
//    universo.add(enemigo13);
//
//    enemigo14 = RangedEnemy(
//      sprite: await Sprite.load('7B.png'),
//      position: Vector2(750, 1350),
//      maxHitPoints: 40,
//      bulletSpeed: 130,
//      shootingThreshold: 30,
//      damage: 4,
//    );
//    universo.add(enemigo14);
//
//    enemigo15 = RangedEnemy(
//      sprite: await Sprite.load('2B.png'),
//      position: Vector2(900, 1200),
//      maxHitPoints: 40,
//      bulletSpeed: 130,
//      shootingThreshold: 30,
//      damage: 4,
//    );
//    universo.add(enemigo15);
//
//    enemigo16 = RangedEnemy(
//      sprite: await Sprite.load('9B.png'),
//      position: Vector2(100, 1600),
//      size: Vector2(140, 220),
//      maxHitPoints: 80,
//      rotationSpeed: 3.0,
//      bulletSpeed: 145,
//      shootingThreshold: 30,
//      damage: 16,
//    );
//    universo.add(enemigo16);
//
//    enemigo17 = RangedEnemy(
//      sprite: await Sprite.load('11B.png'),
//      position: Vector2(400, 1500),
//      maxHitPoints: 80,
//      rotationSpeed: 3.0,
//      bulletSpeed: 145,
//      shootingThreshold: 30,
//      damage: 8,
//    );
//    universo.add(enemigo17);
//
//    enemigo18 = RangedEnemy(
//      sprite: await Sprite.load('3B.png'),
//      position: Vector2(550, 1600),
//      maxHitPoints: 80,
//      rotationSpeed: 4.0,
//      bulletSpeed: 145,
//      shootingThreshold: 30,
//      damage: 8,
//    );
//    universo.add(enemigo18);
//
//    enemigo19 = RangedEnemy(
//      sprite: await Sprite.load('7B.png'),
//      position: Vector2(750, 1750),
//      maxHitPoints: 80,
//      bulletSpeed: 145,
//      shootingThreshold: 30,
//      damage: 8,
//    );
//    universo.add(enemigo19);
//
//    enemigo20 = RangedEnemy(
//      sprite: await Sprite.load('2B.png'),
//      position: Vector2(900, 1600),
//      maxHitPoints: 80,
//      bulletSpeed: 145,
//      shootingThreshold: 30,
//      damage: 8,
//    );
//    universo.add(enemigo20);