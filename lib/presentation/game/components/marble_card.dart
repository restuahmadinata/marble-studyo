import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class NeoCard extends PositionComponent {
  final Color baseColor;
  final double shadowOffset;
  bool isCorrect = false;
  
  // Glint sweep animation properties
  bool shouldGlint = false;
  double glintTimer = 0.0;
  static const double glintDuration = 2.5; // 2.5 seconds

  late final Paint _fillPaint;
  late final Paint _borderPaint;
  late final Paint _shadowPaint;
  late final Paint _iconPaint;

  NeoCard({
    required this.baseColor,
    required Vector2 position,
    required Vector2 size,
    this.shadowOffset = 6.0,
  }) : super(
         position: position,
         size: size,
         anchor: Anchor.topLeft,
         priority: 5,
       ) {
    final Color darker = _darken(baseColor, 0.18);
    _fillPaint = Paint()..color = baseColor;
    _borderPaint = Paint()
      ..color = darker
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    _shadowPaint = Paint()..color = darker;
    _iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    if (shouldGlint) {
      glintTimer += dt;
      if (glintTimer >= glintDuration) {
        shouldGlint = false;
        glintTimer = 0.0;
      }
    }
  }
  
  void startGlint() {
    shouldGlint = true;
    glintTimer = 0.0;
  }

  @override
  void render(Canvas canvas) {
    final Rect shadowRect = Rect.fromLTWH(
      shadowOffset,
      shadowOffset,
      size.x,
      size.y,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(shadowRect, const Radius.circular(12)),
      _shadowPaint,
    );

    final Rect bodyRect = Rect.fromLTWH(0, 0, size.x, size.y);
    final RRect body = RRect.fromRectAndRadius(
      bodyRect,
      const Radius.circular(12),
    );
    
    canvas.drawRRect(body, _fillPaint);
    canvas.drawRRect(body, _borderPaint);
    
    // Draw glint sweep if active
    if (shouldGlint && glintTimer < glintDuration) {
      canvas.save();
      canvas.clipRRect(body);
      
      double progress = glintTimer / glintDuration;
      
      // Sweep from left to right across the card
      double sweepWidth = size.x * 0.6; // Width of the glint
      double sweepPosition = -sweepWidth + (size.x + sweepWidth * 2) * progress;
      
      // Create gradient for glint effect
      final glintGradient = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.8),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      );
      
      final glintPaint = Paint()
        ..shader = glintGradient.createShader(
          Rect.fromLTWH(sweepPosition, 0, sweepWidth, size.y),
        );
      
      canvas.drawRect(
        Rect.fromLTWH(sweepPosition, 0, sweepWidth, size.y),
        glintPaint,
      );
      
      canvas.restore();
    }

    // Draw checkmark if correct
    if (isCorrect) {
      final double centerX = size.x / 2;
      final double centerY = size.y / 2;
      final double checkSize = size.x * 0.3;

      final Path checkPath = Path()
        ..moveTo(centerX - checkSize, centerY)
        ..lineTo(centerX - checkSize / 3, centerY + checkSize / 2)
        ..lineTo(centerX + checkSize, centerY - checkSize / 2);

      canvas.drawPath(checkPath, _iconPaint);
    }
  }

  static Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final dark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return dark.toColor();
  }
}
