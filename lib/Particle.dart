import 'package:flutter/material.dart';

class PVector {
  double x, y;

  PVector(x, y) {
    this.x = x;
    this.y = y;
  }
}

class Particle {
  PVector position = PVector(0.0, 0.0);
  PVector velocity = PVector(0.0, 0.0);
  double mass = 10.0;
  double radius = 10 / 100;
  Color color = Colors.green;
  double area = 0.0314;
  double jumpFactor = -0.6;
}
