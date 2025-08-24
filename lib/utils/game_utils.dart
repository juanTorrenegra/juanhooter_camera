// utils/game_utils.dart
import 'dart:math';
import 'package:flame/game.dart';

// Funciones matemáticas y de utilidad para el juego
Vector2 calculateShootPosition(
  Vector2 entityPosition,
  double angle,
  Vector2 entitySize,
  double offsetDistance,
) {
  final offset = Vector2(
    cos(angle) * (entitySize.x / 2 + offsetDistance),
    sin(angle) * (entitySize.y / 2 + offsetDistance),
  );
  return entityPosition + offset;
}

// Conversión de grados a radianes (más intuitivo)
double degreesToRadians(double degrees) => degrees * pi / 180;

// Conversión de radianes a grados (para debugging)
double radiansToDegrees(double radians) => radians * 180 / pi;

// Calcula distancia entre dos puntos
double distanceBetween(Vector2 a, Vector2 b) => (a - b).length;

// Calcula ángulo entre dos puntos
double angleBetween(Vector2 a, Vector2 b) => atan2(b.y - a.y, b.x - a.x);

// Interpolación lineal entre dos valores
double lerp(double a, double b, double t) => a + (b - a) * t;

// Interpolación lineal para Vector2
Vector2 vectorLerp(Vector2 a, Vector2 b, double t) => a + (b - a) * t;

// Limita un valor entre mínimo y máximo
double clamp(double value, double min, double max) => value < min
    ? min
    : value > max
    ? max
    : value;
