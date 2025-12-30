import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class HintText extends TextComponent {
  HintText({required String message, required Vector2 position})
    : super(
        text: message,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: position,
        anchor: Anchor.center,
        priority: 300,
      );

  double _lifetime = 0;
  final double _maxLifetime = 2.0;

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime += dt;

    // Fade out effect
    if (_lifetime > _maxLifetime * 0.7) {
      double fadeProgress =
          (_lifetime - _maxLifetime * 0.7) / (_maxLifetime * 0.3);
      textRenderer = TextPaint(
        style: TextStyle(
          color: Colors.red.withValues(alpha: 1.0 - fadeProgress),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    // Remove when lifetime expires
    if (_lifetime >= _maxLifetime) {
      removeFromParent();
    }
  }
}
