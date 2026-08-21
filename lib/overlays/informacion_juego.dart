import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart' hide Matrix4;
import 'package:juanshooter/game.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class InformacionJuego extends PositionComponent with HasGameReference<MyGame> {
  static const double padding = 16.0;
  static const double fontSize = 18.0;
  static const double lineHeight = 20.0;
  static const double _valueColumnX = 170.0;
  static const double _skewX = -0.14;
  static const double _borderRadius = 12.0;
  static const String _fontFamily = 'ava';

  late final List<TextComponent> _infoLines;

  final TextPaint _labelStyle = TextPaint(
    style: const TextStyle(
      color: Color.fromARGB(255, 221, 80, 80),
      fontSize: fontSize,
      fontFamily: _fontFamily,
    ),
  );

  final TextPaint _valueStyle = TextPaint(
    style: TextStyle(
      color: Colors.cyan.withAlpha(200),
      fontSize: fontSize,
      fontFamily: _fontFamily,
    ),
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    anchor = Anchor.topLeft;
    position = Vector2(80, 220);

    _infoLines = [];

    _infoLines.add(
      _createInfoLine(
        index: 0,
        label: 'Vida Jugador',
        value: '${game.player.currentHitPoints}/${game.player.maxHitPoints}',
      ),
    );

    _infoLines.add(
      _createInfoLine(
        index: 1,
        label: 'Posición',
        value:
            '${game.player.position.x.toStringAsFixed(1)}, ${game.player.position.y.toStringAsFixed(1)}',
      ),
    );

    _infoLines.add(
      _createInfoLine(
        index: 2,
        label: 'Naves Destruidas',
        value: '${game.shipsDestroyed}',
      ),
    );

    _infoLines.add(
      _createInfoLine(
        index: 3,
        label: 'Time Scale',
        value: '${game.timeScale.toStringAsFixed(2)}x',
      ),
    );

    _infoLines.add(
      _createInfoLine(
        index: 4,
        label: 'Estado',
        value: game.paused ? 'PAUSADO' : 'ACTIVO',
      ),
    );

    _infoLines.add(
      _createInfoLine(
        index: 5,
        label: 'Velocidad',
        value: game.player.currentSpeed.toStringAsFixed(0),
      ),
    );

    _infoLines.add(
      _createInfoLine(
        index: 6,
        label: 'Zoom',
        value: '${game.cameraZoom.toStringAsFixed(2)}x',
      ),
    );

    _calculateSize();
  }

  TextComponent _createInfoLine({
    required int index,
    required String label,
    required String value,
  }) {
    final yPosition = padding + (index * lineHeight);

    add(
      TextComponent(
        text: '$label: ',
        textRenderer: _labelStyle,
        position: Vector2(padding, yPosition),
      ),
    );

    final valueComponent = TextComponent(
      text: value,
      textRenderer: _valueStyle,
      position: Vector2(_valueColumnX, yPosition),
    );
    add(valueComponent);

    return valueComponent;
  }

  void _calculateSize() {
    final totalHeight = padding * 2 + _infoLines.length * lineHeight;
    size = Vector2(320, totalHeight);
  }

  @override
  void render(Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(_borderRadius),
    );

    canvas.drawRRect(rrect, Paint()..color = Colors.black.withAlpha(45));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    super.render(canvas);
  }

  @override
  void renderTree(Canvas canvas) {
    canvas.save();
    canvas.transform(vm.Matrix4.skewX(_skewX).storage);
    super.renderTree(canvas);
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateInfoValues();
  }

  void _updateInfoValues() {
    if (_infoLines.isEmpty) return;

    _infoLines[0].text =
        '${game.player.currentHitPoints}/${game.player.maxHitPoints}';

    if (_infoLines.length > 1) {
      _infoLines[1].text =
          '${game.player.position.x.toStringAsFixed(0)}, ${game.player.position.y.toStringAsFixed(0)}';
    }

    if (_infoLines.length > 2) {
      _infoLines[2].text = '${game.shipsDestroyed}';
    }

    if (_infoLines.length > 3) {
      _infoLines[3].text = '${game.timeScale.toStringAsFixed(2)}x';
    }

    if (_infoLines.length > 4) {
      _infoLines[4].text = game.paused ? 'PAUSADO' : 'ACTIVO';
    }

    if (_infoLines.length > 5) {
      _infoLines[5].text = game.player.currentSpeed.toStringAsFixed(0);
    }

    if (_infoLines.length > 6) {
      _infoLines[6].text = '${game.cameraZoom.toStringAsFixed(2)}x';
    }
  }

  void toggleVisibility() {
    if (isMounted) {
      removeFromParent();
    } else {
      game.camara?.viewport.add(this);
    }
  }

  void setPosition(Vector2 newPosition) {
    position = newPosition;
  }
}
