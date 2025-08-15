import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:juanshooter/actors/player.dart';
import 'package:juanshooter/hud/game_hud.dart';
import 'package:juanshooter/weapons/bullet.dart';

//pensamientos primer juego: nave que elimina asteroides para encontrar armas para derrotar monstruos del espacio, escenario: dentro de un imperio y uno es un minero: mision: minar y mejorar la nave para poder acceder a MediumWorld y HardWorld, competir contra otros mineros compitiendo y compartiendo loot.

class MyGame extends FlameGame with HasGameReference<MyGame> {
  late final Player player;
  late final GameHud hud;
  late final World universo;
  CameraComponent? camara;
  Vector2 currentPlayerPos = Vector2.zero();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    universo = World();
    add(universo);

    camara = CameraComponent(world: universo);
    camara?.viewfinder.anchor = Anchor.center;
    add(camara!);

    final background = SpriteComponent(
      sprite: await Sprite.load('test.png'),
      size: Vector2(1600, 1600),
      anchor: Anchor.center,
      position: Vector2(800, 800), // Centro del mundo
    );
    universo.add(background);

    player = Player(
      sprite: await Sprite.load('ship.png'),
      position: Vector2(800, 800),
    );
    await universo.add(player);

    currentPlayerPos = player.position.clone();

    camara?.follow(player);

    hud = GameHud()..priority = 10;
    add(hud);
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

  @override
  void update(double dt) {
    super.update(dt);
    // Actualizar posición de depuración
    currentPlayerPos.setFrom(player.position);
  }
}
