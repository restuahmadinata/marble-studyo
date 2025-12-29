import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class NeoCard extends PositionComponent {
  final Color baseColor;
  final double shadowOffset;

  late final Paint _fillPaint;
  late final Paint _borderPaint;
  late final Paint _shadowPaint;

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
  }

  static Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final dark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return dark.toColor();
  }
}
