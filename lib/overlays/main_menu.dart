import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:juanshooter/game.dart';

class MainMenu extends StatelessWidget {
  // Reference to parent game.
  final MyGame game;

  const MainMenu({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/menuTest1.png"),
            fit: BoxFit.cover, // Cubre toda la pantalla
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  game.overlays.remove('MainMenu');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.withValues(alpha: .7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.cyan, width: 2),
                  ),
                  elevation: 8,
                  shadowColor: Colors.blueAccent,
                ),
                child: const Text(
                  'Jugar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .0,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Flame.device.setLandscapeRightOnly();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.withValues(alpha: .7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.cyan, width: 2),
                  ),
                  elevation: 8,
                  shadowColor: Colors.blueAccent,
                ),

                child: const Text(
                  'Landscape Right',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .0,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Flame.device.setLandscapeLeftOnly();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.withValues(alpha: .7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.cyan, width: 2),
                  ),
                  elevation: 8,
                  shadowColor: Colors.blueAccent,
                ),
                child: const Text(
                  'Landscape Left',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//const SizedBox(height: 40),
//              SizedBox(
//                width: 200,
//                height: 75,
//                child: ElevatedButton(
//                  onPressed: () {
//                    game.overlays.remove('MainMenu');
//                  },
//                  style: ElevatedButton.styleFrom(
//                    backgroundColor: whiteTextColor,
//                  ),
//                  child: const Text(
//                    'Play',
//                    style: TextStyle(fontSize: 40.0, color: blackTextColor),
//                  ),
//                ),
//              ),
