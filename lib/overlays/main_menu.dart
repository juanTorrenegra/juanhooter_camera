import 'dart:math';

import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:juanshooter/game.dart';

import 'package:flutter/material.dart';

class VisorOverlay extends StatelessWidget {
  const VisorOverlay({required this.game, super.key});

  final MyGame game;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Fondo completamente transparente
      child: Stack(
        children: [
          // 1) -- El fondo con estrellas y el juego se ve a través de la transparencia --
          // (Tu juego ya está aquí de fondo, por eso el color transparente)

          // 2) -- Nuestro visor espacial dibujado encima --
          CustomPaint(
            painter: VisorPainter(), // Esta es la clase que hace toda la magia
            size: Size.infinite, // Que ocupe toda la pantalla
          ),

          // 3) -- Los botones y otros widgets de interfaz encima del visor --
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ... Tus botones animados con SimpleAnimations aquí ...
                Text(
                  'MENU PRINCIPAL',
                  style: TextStyle(color: Colors.cyan, fontSize: 24),
                ),
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
        ],
      ),
    );
  }
}

// --------------------------------------------------------
// LA CLASE QUE DIBUJA EL VISOR - Aquí está la magia
// --------------------------------------------------------
class VisorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.4; // Radio del visor principal

    // -- 1. Fondo del visor: Un negro muy semi-transparente --
    final backgroundPaint = Paint()
      ..color = const Color(0xAA000000); // Negro ~66% opaco
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // -- 2. Borde del visor: Gradiente circular cyan que se difumina --
    final gradient = SweepGradient(
      colors: [Colors.cyan, Colors.transparent],
      stops: [0.7, 1.0],
    );
    final shader = gradient.createShader(
      Rect.fromCircle(center: center, radius: maxRadius),
    );

    final borderPaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        10.0,
      ); // Efecto GLOW/Blur

    canvas.drawCircle(center, maxRadius, borderPaint);

    // -- 3. Cruz de mira en el centro (simulando un telescopio) --
    final crosshairPaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Líneas horizontales y verticales
    double crosshairSize = 20.0;
    canvas.drawLine(
      Offset(center.dx - crosshairSize, center.dy),
      Offset(center.dx + crosshairSize, center.dy),
      crosshairPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - crosshairSize),
      Offset(center.dx, center.dy + crosshairSize),
      crosshairPaint,
    );

    // Círculo de la mira
    canvas.drawCircle(center, crosshairSize / 2, crosshairPaint);

    // -- 4. "Medidores" o marcadores alrededor del borde --
    // Por ejemplo, marcas de grado cada 30 grados
    for (double angle = 0; angle < 360; angle += 30) {
      double radians = angle * (3.14159 / 180.0);
      // Calcula el punto en el borde del círculo
      Offset start = Offset(
        center.dx + maxRadius * cos(radians),
        center.dy + maxRadius * sin(radians),
      );
      // Calcula un punto un poco hacia adentro para la marca
      Offset end = Offset(
        center.dx + (maxRadius - 15) * cos(radians),
        center.dy + (maxRadius - 15) * sin(radians),
      );
      canvas.drawLine(start, end, crosshairPaint);
    }

    // -- 5. Líneas diagonales de "conexión" futuristas --
    // (Podrías animar estas líneas con SimpleAnimations!)
    final linePaint = Paint()
      ..color = Colors.cyan.withValues(alpha: .5)
      ..strokeWidth = 1.0;

    canvas.drawLine(
      const Offset(50, 50),
      Offset(center.dx - 50, center.dy - 50),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width - 50, 50),
      Offset(center.dx + 50, center.dy - 50),
      linePaint,
    );
    // ... y así sucesivamente ...
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Si quieres animar propiedades, aquí debes comparar el oldDelegate con this
    // y return true si cambiaron. Para un diseño estático, return false es eficiente.
    return false;
  }
}
