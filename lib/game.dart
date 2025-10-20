import 'dart:async';
import 'package:juanhooter_camera/utils/game_utils.dart';
import 'dart:math';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:juanhooter_camera/actors/enemigo.dart';
import 'package:juanhooter_camera/actors/player.dart';
import 'package:juanhooter_camera/actors/ranged_enemy.dart';
import 'package:juanhooter_camera/hud/game_hud.dart';
import 'package:flame_audio/flame_audio.dart';

//tamaño de pantalla = [796.3636474609375,392.7272644042969]
// juego: nave que elimina asteroides para encontrar armas para derrotar monstruos del espacio, escenario: dentro de un imperio y uno es un minero: mision: minar y mejorar la nave para poder acceder a MediumWorld y HardWorld, competir contra otros mineros compitiendo y compartiendo loot.

enum CameraMode { explorer, battle }

class MyGame extends FlameGame
    with HasGameReference<MyGame>, HasCollisionDetection {
  MyGame();

  late final Player player;
  late final RangedEnemy mineroTorretas;
  late final RangedEnemy enemigo1;
  late final Enemigo enemigo2;
  late final Enemigo enemigo3;
  late final Enemigo enemigo4;

  late final GameHud hud;
  late final World universo;
  CameraComponent? camara;
  Vector2 currentPlayerPos = Vector2.zero();
  late AudioPool pool;
  double timeScale = 1.0;

  int shipsDestroyed = 0;

  void incrementShipsDestroyed() {
    shipsDestroyed++;
    hud.updateShipsDestroyed(shipsDestroyed);
  }

  // SISTEMA DE CÁMARA DUAL
  CameraMode currentCameraMode = CameraMode.explorer;
  Vector2 cameraOffset = Vector2.zero();
  double maxCameraOffset = 250.0; // Límite máximo de desplazamiento
  double cameraLerpStrength = 0.002; //suavizado 0.1 = 10%, 1.0 = instantaneo
  double cameraReturnSpeed = 0.0005; //Vel return center(0= no regresa) 0.05=5%
  bool shouldReturnToCenter = true; // idle= back to center

  // Variables para modo batalla
  Enemigo? currentTargetEnemy;
  double battleCameraLerpStrength = 0.08;
  double maxBattleZoom = 1.2; // Zoom máximo en modo batalla
  double minBattleZoom = 0.8; // Zoom mínimo en modo batalla

  double battleZoomLevel = 1.0;
  bool isFirstBattleFrame = true;
  Vector2 battleFocusPoint = Vector2.zero();
  double battlePadding = 100.0; // Espacio adicional alrededor de player/enemigo

  // Método para encontrar el enemigo más cercano en el viewport
  Enemigo? findClosestEnemyInViewport() {
    List<Enemigo> enemiesInViewport = [];

    // Buscar todos los enemigos en el viewport
    for (final component in universo.children) {
      if (component is Enemigo && component.isInViewport) {
        enemiesInViewport.add(component);
      }
    }

    if (enemiesInViewport.isEmpty) return null;

    // Encontrar el más cercano al player
    enemiesInViewport.sort((a, b) {
      final distA = (a.position - player.position).length;
      final distB = (b.position - player.position).length;
      return distA.compareTo(distB);
    });

    return enemiesInViewport.first;
  }

  void _updateExplorerCamera(double dt) {
    final joystickDelta = hud.movementJoystick.relativeDelta;

    Vector2 targetOffset = Vector2.zero();

    if (hud.movementJoystick.direction != JoystickDirection.idle) {
      targetOffset = joystickDelta * maxCameraOffset;

      if (targetOffset.length > maxCameraOffset) {
        targetOffset = targetOffset.normalized() * maxCameraOffset;
      }
    } else {
      if (shouldReturnToCenter) {
        targetOffset = Vector2.zero();
      } else {
        targetOffset = cameraOffset;
      }
    }

    // Suavizado para modo exploración
    cameraOffset.x =
        cameraOffset.x + (targetOffset.x - cameraOffset.x) * cameraLerpStrength;
    cameraOffset.y =
        cameraOffset.y + (targetOffset.y - cameraOffset.y) * cameraLerpStrength;

    final targetPosition = player.position + cameraOffset;
    camara?.viewfinder.position = targetPosition;

    // Resetear zoom en modo exploración
    camara?.viewfinder.zoom = 1.0;
  }

  void _updateBattleCamera(double dt) {
    if (currentTargetEnemy == null || !currentTargetEnemy!.isMounted) {
      _switchToExplorerMode();
      return;
    }

    // PRIMER FRAME DE BATALLA: Calcular encuadre instantáneo
    if (isFirstBattleFrame) {
      _calculateBattleEncuadre();
      isFirstBattleFrame = false;
    }

    // Mantener el encuadre durante la batalla
    _maintainBattleEncuadre(dt);
  }

  void _calculateBattleEncuadre() {
    // 1. Calcular punto medio entre player y enemigo
    battleFocusPoint = (player.position + currentTargetEnemy!.position) / 2;

    // 2. Calcular distancia entre player y enemigo
    final distance = (player.position - currentTargetEnemy!.position).length;

    // 3. Calcular zoom necesario para que ambos quepan en pantalla con padding
    final viewportSize = camara!.viewport.size;
    final requiredWidth = distance + battlePadding * 2;
    final requiredHeight = distance + battlePadding * 2;

    // 4. Calcular zoom basado en la dimensión más grande necesaria
    final zoomBasedOnWidth = viewportSize.x / requiredWidth;
    final zoomBasedOnHeight = viewportSize.y / requiredHeight;

    // 5. Usar el zoom más pequeño (que muestra más área)
    battleZoomLevel = min(zoomBasedOnWidth, zoomBasedOnHeight).clamp(0.3, 1.0);

    // 6. Aplicar instantáneamente
    camara?.viewfinder.position = battleFocusPoint;
    camara?.viewfinder.zoom = battleZoomLevel;

    print("🎥 ENCUADRE BATALLA - Zoom: ${battleZoomLevel.toStringAsFixed(2)}");
  }

  void _maintainBattleEncuadre(double dt) {
    // Recalcular punto medio continuamente
    battleFocusPoint = (player.position + currentTargetEnemy!.position) / 2;

    // Suavizado hacia el nuevo punto medio
    final currentCamPos = camara!.viewfinder.position;
    final targetPosition = Vector2(
      currentCamPos.x + (battleFocusPoint.x - currentCamPos.x) * 0.1,
      currentCamPos.y + (battleFocusPoint.y - currentCamPos.y) * 0.1,
    );

    camara?.viewfinder.position = targetPosition;

    // Recalcular zoom si la distancia cambia significativamente
    final currentDistance =
        (player.position - currentTargetEnemy!.position).length;
    final viewportSize = camara!.viewport.size;
    final requiredWidth = currentDistance + battlePadding * 2;
    final requiredHeight = currentDistance + battlePadding * 2;

    final zoomBasedOnWidth = viewportSize.x / requiredWidth;
    final zoomBasedOnHeight = viewportSize.y / requiredHeight;
    final newZoomLevel = min(
      zoomBasedOnWidth,
      zoomBasedOnHeight,
    ).clamp(0.3, 1.0);

    // Suavizar transición de zoom
    final currentZoom = camara?.viewfinder.zoom ?? 1.0;
    camara?.viewfinder.zoom = currentZoom + (newZoomLevel - currentZoom) * 0.05;
  }

  void _switchToExplorerMode() {
    currentCameraMode = CameraMode.explorer;
    currentTargetEnemy = null;
    isFirstBattleFrame = true;

    // Restaurar zoom normal instantáneamente
    camara?.viewfinder.zoom = 1.0;

    print("🟢 VOLVIENDO A MODO EXPLORACIÓN");
  }

  void updateCameraMode() {
    final closestEnemy = findClosestEnemyInViewport();

    if (closestEnemy != null && currentCameraMode != CameraMode.battle) {
      // Cambiar a modo batalla
      currentCameraMode = CameraMode.battle;
      currentTargetEnemy = closestEnemy;
      isFirstBattleFrame = true;
      print("🔴 MODO BATALLA ACTIVADO");
    } else if (closestEnemy == null && currentCameraMode == CameraMode.battle) {
      _switchToExplorerMode();
    }

    // Si estamos en modo batalla y el enemigo actual murió, buscar nuevo
    if (currentCameraMode == CameraMode.battle &&
        (currentTargetEnemy?.isMounted != true)) {
      currentTargetEnemy = findClosestEnemyInViewport();
      if (currentTargetEnemy == null) {
        _switchToExplorerMode();
      } else {
        isFirstBattleFrame = true; // Recalcular encuadre para nuevo enemigo
      }
    }
  }

  double _calculateBattleZoom(double distance) {
    // Zoom más cercano cuando los enemigos están lejos, más amplio cuando están cerca
    const maxDistance = 500.0;
    const minDistance = 100.0;

    double normalizedDistance =
        (distance - minDistance) / (maxDistance - minDistance);
    normalizedDistance = normalizedDistance.clamp(0.0, 1.0);

    return minBattleZoom + (maxBattleZoom - minBattleZoom) * normalizedDistance;
  }

  void fast() {
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
      sprite: await Sprite.load('stars3000x1500.png'), //Nebula3.png b.png
      size: Vector2(6000, 3000),
      anchor: Anchor.topLeft,
      position: Vector2(0, 0),
    )..priority = -100;
    universo.add(background);

    player = Player(
      sprite: await Sprite.load('ship30x24.png'), // SIMULAR RELOAD LASERS
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
      sprite: await Sprite.load('bite30x24.png'), //IZQUIERDA
      position: Vector2(850, 400),
      size: Vector2(30, 24),
      maxHitPoints: 10,
      rotationSpeed: 3.0,
      bulletSpeed: 100,
      shootingThreshold: 30,
      damage: 2,
    );
    universo.add(enemigo1);

    enemigo2 = RangedEnemy(
      sprite: await Sprite.load('bite30x24.png'), //morado
      position: Vector2(850, 300),
      size: Vector2(30, 24),
      maxHitPoints: 10,
      rotationSpeed: 3.0,
      bulletSpeed: 100,
      shootingThreshold: 30,
      damage: 1,
    );
    universo.add(enemigo2);

    enemigo3 = RangedEnemy(
      sprite: await Sprite.load('bite30x24.png'), //derecha
      position: Vector2(850, 450),
      size: Vector2(30, 24),
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

    // Actualizar el desplazamiento de la cámara basado en el input del joystick
    _updateCameraOffset(dt);
  }

  void _updateCameraOffset(double dt) {
    if (camara == null) return;

    updateCameraMode(); // Actualizar modo primero

    if (currentCameraMode == CameraMode.explorer) {
      _updateExplorerCamera(dt);
    } else {
      _updateBattleCamera(dt);
    }

    final joystickDelta = hud.movementJoystick.relativeDelta;

    // 1. CALCULAR DESPLAZAMIENTO OBJETIVO
    Vector2 targetOffset = Vector2.zero();

    if (hud.movementJoystick.direction != JoystickDirection.idle) {
      targetOffset = joystickDelta * maxCameraOffset;

      if (targetOffset.length > maxCameraOffset) {
        targetOffset = targetOffset.normalized() * maxCameraOffset;
      }
    } else {
      if (shouldReturnToCenter) {
        targetOffset = Vector2.zero();
      } else {
        targetOffset = cameraOffset;
      }
    }

    // 2. SUAVIZADO MANUAL - CONTROL DE VELOCIDAD
    double lerpFactor;
    if (hud.movementJoystick.direction != JoystickDirection.idle) {
      lerpFactor = cameraLerpStrength;
    } else if (shouldReturnToCenter) {
      lerpFactor = cameraReturnSpeed;
    } else {
      lerpFactor = 0.0; // No mover
    }

    // Aplicar interpolación lineal manual
    cameraOffset.x =
        cameraOffset.x + (targetOffset.x - cameraOffset.x) * lerpFactor;
    cameraOffset.y =
        cameraOffset.y + (targetOffset.y - cameraOffset.y) * lerpFactor;

    // 3. APLICAR A LA CÁMARA
    final targetPosition = player.position + cameraOffset;
    camara?.viewfinder.position = targetPosition;
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

//late final Enemigo enemigo5;
//  late final Enemigo enemigo6;
//  late final Enemigo enemigo7;
//  late final Enemigo enemigo8;
//  late final Enemigo enemigo9;
//  late final Enemigo enemigo10;
//  late final Enemigo enemigo11;
//  late final Enemigo enemigo12;
//  late final Enemigo enemigo13;
//  late final Enemigo enemigo14;
//  late final Enemigo enemigo15;
//  late final Enemigo enemigo16;
//  late final Enemigo enemigo17;
//  late final Enemigo enemigo18;
//  late final Enemigo enemigo19;
//  late final Enemigo enemigo20;