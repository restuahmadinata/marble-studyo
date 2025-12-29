import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class NeoButton extends PositionComponent {
  final Color baseColor;
  final String text;
  final double shadowOffset;
  final double radius;

  late final Paint _fillPaint;
  late final Paint _borderPaint;
  late final Paint _shadowPaint;
  late final TextPaint _textPaint;

  NeoButton({
    required this.baseColor,
    required this.text,
    required Vector2 position,
    required Vector2 size,
    this.shadowOffset = 6.0,
    this.radius = 30.0,
  }) : super(
         position: position,
         size: size,
         anchor: Anchor.topLeft,
         priority: 300,
       ) {
    final Color darker = _darken(baseColor, 0.18);
    _fillPaint = Paint()..color = baseColor;
    _borderPaint = Paint()
      ..color = darker
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    _shadowPaint = Paint()..color = darker;

    _textPaint = TextPaint(
      style: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    // Draw shadow
    final Rect shadowRect = Rect.fromLTWH(
      shadowOffset,
      shadowOffset,
      size.x,
      size.y,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(shadowRect, Radius.circular(radius)),
      _shadowPaint,
    );

    // Draw button body
    final Rect bodyRect = Rect.fromLTWH(0, 0, size.x, size.y);
    final RRect body = RRect.fromRectAndRadius(
      bodyRect,
      Radius.circular(radius),
    );
    canvas.drawRRect(body, _fillPaint);
    canvas.drawRRect(body, _borderPaint);

    // Draw text centered
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: _textPaint.style),
      textDirection: TextDirection.ltr,
    )..layout();

    final textPosition = Offset(
      (size.x - textPainter.width) / 2,
      (size.y - textPainter.height) / 2,
    );
    textPainter.paint(canvas, textPosition);
  }

  static Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final dark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return dark.toColor();
  }
}
