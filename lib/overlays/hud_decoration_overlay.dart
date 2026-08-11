// hud_decoration_overlay.dart
import 'package:flutter/material.dart';
import 'package:juanshooter/game.dart';

class HudDecorationOverlay extends StatelessWidget {
  const HudDecorationOverlay({required this.game, super.key});
  final MyGame game;

  @override
  Widget build(BuildContext context) {
    // IgnorePointer: este widget no bloquee los botones del hud.
    // SizedBox.expand so the painter uses the game frame size (1280×720),
    // not MediaQuery (browser size) — that mismatch pulled the right corners left.
    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: CustomPaint(
          painter: const _HudDecorationPainter(),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _HudDecorationPainter extends CustomPainter {
  const _HudDecorationPainter();

  static const double _cornerInset = 25;
  static const double _notchInset = 35;
  static const double _edgeY = 15;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 255, 164, 164)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);

    final glowPaint = Paint()
      ..color = const Color.fromARGB(250, 231, 42, 20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    final armEndX = size.width / 3;
    final path = Path();

    // Top-left
    path
      ..moveTo(_cornerInset, _cornerInset)
      ..lineTo(_notchInset, _edgeY)
      ..lineTo(armEndX, _edgeY);

    // Top-right (mirror of top-left)
    path
      ..moveTo(size.width - _cornerInset, _cornerInset)
      ..lineTo(size.width - _notchInset, _edgeY)
      ..lineTo(size.width - armEndX, _edgeY);

    // Bottom-left
    path
      ..moveTo(_cornerInset, size.height - _cornerInset)
      ..lineTo(_notchInset, size.height - _edgeY)
      ..lineTo(armEndX, size.height - _edgeY);

    // Bottom-right (mirror of bottom-left)
    path
      ..moveTo(size.width - _cornerInset, size.height - _cornerInset)
      ..lineTo(size.width - _notchInset, size.height - _edgeY)
      ..lineTo(size.width - armEndX, size.height - _edgeY);

    canvas.drawPath(path, paint);
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _HudDecorationPainter oldDelegate) => false;
}
