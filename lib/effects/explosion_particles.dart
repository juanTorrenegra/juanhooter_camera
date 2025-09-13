import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:juanshooter/game.dart';

class ExplosionParticle extends CircleComponent {
  final Vector2 initialPosition;
  final Vector2 velocity;
  final double lifespan;
  double lifeTimer = 0;

  ExplosionParticle({
    required this.initialPosition,
    required this.velocity,
    required this.lifespan,
    required double size,
    required Color color,
  }) : super(
         position: initialPosition.clone(),
         radius: size / 2,
         anchor: Anchor.center,
         paint: Paint()..color = color,
       );

  @override
  void update(double dt) {
    super.update(dt);
    lifeTimer += dt;
    position += velocity * dt;

    // Efecto de desvanecimiento
    final alpha = (1 - lifeTimer / lifespan).clamp(0, 1);
    paint.color = paint.color.withAlpha(150);

    // Escala que crece y luego se reduce
    final scale = 1 + sin(lifeTimer / lifespan * pi) * 0.5;
    radius = (radius * scale).clamp(1, 10);

    if (lifeTimer >= lifespan) {
      removeFromParent();
    }
  }
}

class ExplosionEffect extends Component with HasGameReference<MyGame> {
  final Vector2 center;
  final int particleCount;
  final double explosionRadius;
  final double duration;

  ExplosionEffect({
    required this.center,
    this.particleCount = 30,
    this.explosionRadius = 150,
    this.duration = 3.0,
  });

  @override
  Future<void> onLoad() async {
    _createParticles();
  }

  void _createParticles() {
    final random = Random();

    for (var i = 0; i < particleCount; i++) {
      // Dirección aleatoria
      final angle = random.nextDouble() * 2 * pi;
      final distance = random.nextDouble() * explosionRadius;

      // Velocidad aleatoria
      final speed = 50 + random.nextDouble() * 150;
      final velocity = Vector2(cos(angle), sin(angle)) * speed;

      // Tamaño y color aleatorios
      final size = 3 + random.nextDouble() * 7;
      final hue = random.nextDouble() * 60; // Colores entre rojo y naranja
      final color = Color.fromARGB(
        255,
        255,
        (200 + random.nextDouble() * 55).toInt(),
        (random.nextDouble() * 100).toInt(),
      );

      final particle = ExplosionParticle(
        initialPosition: center,
        velocity: velocity,
        lifespan: duration * (0.5 + random.nextDouble() * 0.5),
        size: size,
        color: color,
      );

      add(particle);
    }
  }
}
