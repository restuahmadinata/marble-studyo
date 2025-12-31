import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// A neomorphic-style button component for Flame game engine.
///
/// This button creates a modern, flat design with a subtle shadow effect
/// that gives it a raised appearance. The button displays centered text
/// and can be customized with colors, size, and border radius.
class NeoButton extends PositionComponent {
  // ==================== Public Properties ====================

  /// The base color of the button
  final Color baseColor;

  /// The text displayed on the button
  final String text;

  /// The offset distance of the shadow from the button
  final double shadowOffset;

  /// The corner radius of the button
  final double radius;

  // ==================== Private Properties ====================

  /// Paint object for the button's fill color
  late final Paint _fillPaint;

  /// Paint object for the button's border
  late final Paint _borderPaint;

  /// Paint object for the button's shadow
  late final Paint _shadowPaint;

  /// Text painter for rendering the button label
  late final TextPaint _textPaint;

  // ==================== Constructor ====================

  /// Creates a new NeoButton with the specified properties.
  ///
  /// Parameters:
  /// - [baseColor]: The main color of the button
  /// - [text]: The text to display on the button
  /// - [position]: The position of the button in the game world
  /// - [size]: The size of the button (width and height)
  /// - [shadowOffset]: The distance of the shadow (default: 6.0)
  /// - [radius]: The corner radius (default: 30.0)
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
    _initializePaints();
  }

  // ==================== Initialization Methods ====================

  /// Initializes all paint objects for rendering the button.
  ///
  /// This method sets up the fill, border, shadow, and text paints
  /// with appropriate colors and styles.
  void _initializePaints() {
    // Create a darker shade for the border and shadow
    final Color darkerShade = _darken(baseColor, 0.18);

    // Initialize fill paint with the base color
    _fillPaint = Paint()..color = baseColor;

    // Initialize border paint with darker shade
    _borderPaint = Paint()
      ..color = darkerShade
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Initialize shadow paint with darker shade
    _shadowPaint = Paint()..color = darkerShade;

    // Initialize text paint with default styling
    _textPaint = TextPaint(
      style: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ==================== Rendering Methods ====================

  /// Renders the button on the canvas.
  ///
  /// This method draws the button in three layers:
  /// 1. Shadow layer (for depth effect)
  /// 2. Button body (fill and border)
  /// 3. Text layer (centered)
  @override
  void render(Canvas canvas) {
    _drawShadow(canvas);
    _drawButtonBody(canvas);
    _drawButtonText(canvas);
  }

  /// Draws the shadow layer beneath the button.
  ///
  /// The shadow is offset by [shadowOffset] pixels to create
  /// a raised appearance.
  void _drawShadow(Canvas canvas) {
    final Rect shadowRect = Rect.fromLTWH(
      shadowOffset,
      shadowOffset,
      size.x,
      size.y,
    );

    final RRect shadowRRect = RRect.fromRectAndRadius(
      shadowRect,
      Radius.circular(radius),
    );

    canvas.drawRRect(shadowRRect, _shadowPaint);
  }

  /// Draws the main body of the button including fill and border.
  void _drawButtonBody(Canvas canvas) {
    final Rect bodyRect = Rect.fromLTWH(0, 0, size.x, size.y);

    final RRect bodyRRect = RRect.fromRectAndRadius(
      bodyRect,
      Radius.circular(radius),
    );

    // Draw fill
    canvas.drawRRect(bodyRRect, _fillPaint);

    // Draw border
    canvas.drawRRect(bodyRRect, _borderPaint);
  }

  /// Draws the button text centered within the button.
  void _drawButtonText(Canvas canvas) {
    // Create and layout text painter
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: _textPaint.style),
      textDirection: TextDirection.ltr,
    )..layout();

    // Calculate centered position
    final textPosition = Offset(
      (size.x - textPainter.width) / 2,
      (size.y - textPainter.height) / 2,
    );

    // Paint the text
    textPainter.paint(canvas, textPosition);
  }

  // ==================== Utility Methods ====================

  /// Darkens a color by reducing its lightness.
  ///
  /// Parameters:
  /// - [color]: The color to darken
  /// - [amount]: The amount to reduce lightness (0.0 to 1.0)
  ///
  /// Returns a new Color that is darker than the input color.
  static Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final darkenedLightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    final darkenedHsl = hsl.withLightness(darkenedLightness);
    return darkenedHsl.toColor();
  }
}
