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

//prototipo.

class MyGame extends FlameGame
    with HasGameReference<MyGame>, HasCollisionDetection {
  late final Player player;
  late final Enemigo enemigo;
  late final GameHud hud;
  late final World universo;
  CameraComponent? camara;
  Vector2 currentPlayerPos = Vector2.zero();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    debugMode = true;

    universo = World();
    add(universo);

    camara = CameraComponent(
      world: universo,
      viewfinder: Viewfinder()..anchor = Anchor.center,
    );
    //camara?.viewfinder.anchor = Anchor.center;
    add(camara!);

    final background = SpriteComponent(
      sprite: await Sprite.load('teststars.png'),
      size: Vector2(1600, 1600),
      anchor: Anchor.center,
      position: Vector2(800, 800),
    )..priority = -100;
    universo.add(background);

    player = Player(
      sprite: await Sprite.load('ship.png'),
      position: Vector2(800, 800),
    );
    universo.add(player);

    enemigo = Enemigo(
      sprite: await Sprite.load('enemigo.png'),
      position: Vector2(900, 800),
    );
    universo.add(enemigo);

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
    //print("se crea el bullet");

    print('Bala disparada desde: ${player.position}');
    print('Posición actual del jugador: $currentPlayerPos');
  }
}
