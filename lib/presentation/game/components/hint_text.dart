import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class HintText extends PositionComponent {
  final String message;
  late TextPaint _textPaint;
  late TextPaint _outlinePaint;
  
  double _lifetime = 0;
  final double _maxLifetime = 2.0;
  double _opacity = 1.0;

  HintText({required this.message, required Vector2 position})
    : super(
        position: position,
        anchor: Anchor.center,
        priority: 300,
      ) {
    // Soft pastel color for text
    _textPaint = TextPaint(
      style: const TextStyle(
        color: Color(0xFFFFE5B4), // Soft peach/cream color
        fontSize: 18,
        fontWeight: FontWeight.w900, // Extra bold
        fontFamily: 'monospace',
      ),
    );
    
    // Outline for better readability
    _outlinePaint = TextPaint(
      style: const TextStyle(
        color: Color(0xFF8B6F47), // Soft brown outline
        fontSize: 18,
        fontWeight: FontWeight.w900,
        fontFamily: 'monospace',
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    if (_opacity <= 0) return;
    
    canvas.save();
    canvas.translate(0, 0);
    
    // Apply opacity to canvas
    if (_opacity < 1.0) {
      canvas.saveLayer(null, Paint()..color = Colors.white.withOpacity(_opacity));
    }
    
    // Draw outline (stroke effect)
    for (double dx = -1.5; dx <= 1.5; dx += 1.5) {
      for (double dy = -1.5; dy <= 1.5; dy += 1.5) {
        if (dx != 0 || dy != 0) {
          _outlinePaint.render(
            canvas,
            message,
            Vector2(dx, dy),
            anchor: Anchor.center,
          );
        }
      }
    }
    
    // Draw main text
    _textPaint.render(
      canvas,
      message,
      Vector2.zero(),
      anchor: Anchor.center,
    );
    
    if (_opacity < 1.0) {
      canvas.restore();
    }
    
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime += dt;

    // Fade out effect
    if (_lifetime > _maxLifetime * 0.7) {
      double fadeProgress =
          (_lifetime - _maxLifetime * 0.7) / (_maxLifetime * 0.3);
      _opacity = 1.0 - fadeProgress;
    }

    // Remove when lifetime expires
    if (_lifetime >= _maxLifetime) {
      removeFromParent();
    }
  }
}
