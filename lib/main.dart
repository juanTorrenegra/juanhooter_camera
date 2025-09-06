import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:juanshooter/game.dart';
import 'package:flutter/services.dart';
import 'package:juanshooter/overlays/main_menu.dart'; //landscape mode

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.setLandscapeRightOnly();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(
      GameWidget<MyGame>.controlled(
        gameFactory: MyGame.new,
        overlayBuilderMap: {
          'MainMenu': (_, game) => MainMenu(game: game),
          //'GameOver': (_, game) => GameOver(game: game),
        },
        initialActiveOverlays: const ['MainMenu'],
      ),
    );
  });
}
