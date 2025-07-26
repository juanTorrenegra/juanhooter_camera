import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:juanshooter/game.dart';
import 'package:flutter/services.dart'; //landscape mode

//void main() {
//  runApp(GameWidget(game: MyGame()));
//}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(GameWidget(game: MyGame()));
  });
}
