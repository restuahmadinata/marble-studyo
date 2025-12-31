import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// A neomorphic-style card component for marble placement.
///
/// This card serves as a target area where players can place grouped
/// marbles. Features a soft shadow effect and glint animation for
/// visual feedback when incorrect marble counts are placed.
class NeoCard extends PositionComponent {
  // ==================== Public Properties ====================

  /// The base color of the card
  final Color baseColor;

  /// The offset distance of the shadow from the card
  final double shadowOffset;

  /// Flag indicating if the card has the correct number of marbles
  bool isCorrect = false;

  // ==================== Animation Properties ====================

  /// Flag to trigger the glint sweep animation
  bool shouldGlint = false;

  /// Timer for tracking glint animation progress
  double glintTimer = 0.0;

  /// Duration of the glint animation in seconds
  static const double glintDuration = 2.5;

  // ==================== Private Properties ====================

  /// Paint object for the card's fill color
  late final Paint _fillPaint;

  /// Paint object for the card's border
  late final Paint _borderPaint;

  /// Paint object for the card's shadow
  late final Paint _shadowPaint;

  // ==================== Constructor ====================

  /// Creates a new NeoCard with the specified properties.
  ///
  /// Parameters:
  /// - [baseColor]: The main color of the card
  /// - [position]: The position of the card in the game world
  /// - [size]: The size of the card (width and height)
  /// - [shadowOffset]: The distance of the shadow (default: 6.0)
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
    _initializePaints();
  }

  // ==================== Initialization Methods ====================

  /// Initializes all paint objects for rendering the card.
  ///
  /// Sets up fill, border, and shadow paints with appropriate
  /// colors based on the base color.
  void _initializePaints() {
    final Color darkerShade = _darken(baseColor, 0.18);

    _fillPaint = Paint()..color = baseColor;

    _borderPaint = Paint()
      ..color = darkerShade
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    _shadowPaint = Paint()..color = darkerShade;
  }

  // ==================== Update Methods ====================

  /// Updates the card's animation state.
  ///
  /// Tracks the glint animation timer and resets when complete.
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

  /// Starts the glint sweep animation.
  ///
  /// This animation is triggered to provide visual feedback when
  /// the card has an incorrect number of marbles.
  void startGlint() {
    shouldGlint = true;
    glintTimer = 0.0;
  }

  // ==================== Rendering Methods ====================

  /// Renders the card on the canvas.
  ///
  /// Draws the card in layers:
  /// 1. Shadow layer (for depth)
  /// 2. Card body (fill and border)
  /// 3. Glint animation (if active)
  @override
  void render(Canvas canvas) {
    _drawShadow(canvas);
    _drawCardBody(canvas);

    if (shouldGlint && glintTimer < glintDuration) {
      _drawGlintEffect(canvas);
    }
  }

  /// Draws the shadow layer beneath the card.
  void _drawShadow(Canvas canvas) {
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
  }

  /// Draws the main body of the card including fill and border.
  void _drawCardBody(Canvas canvas) {
    final Rect bodyRect = Rect.fromLTWH(0, 0, size.x, size.y);
    final RRect body = RRect.fromRectAndRadius(
      bodyRect,
      const Radius.circular(12),
    );

    canvas.drawRRect(body, _fillPaint);
    canvas.drawRRect(body, _borderPaint);
  }

  /// Draws the glint sweep animation effect.
  ///
  /// Creates a white gradient that sweeps across the card from
  /// left to right to indicate an incorrect state.
  void _drawGlintEffect(Canvas canvas) {
    final Rect bodyRect = Rect.fromLTWH(0, 0, size.x, size.y);
    final RRect body = RRect.fromRectAndRadius(
      bodyRect,
      const Radius.circular(12),
    );

    canvas.save();
    canvas.clipRRect(body);

    final double progress = glintTimer / glintDuration;

    // Calculate sweep position (left to right)
    final double sweepWidth = size.x * 0.6;
    final double sweepPosition =
        -sweepWidth + (size.x + sweepWidth * 2) * progress;

    // Create gradient for glint effect
    final glintGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.white.withValues(alpha: 0.0),
        Colors.white.withValues(alpha: 0.8),
        Colors.white.withValues(alpha: 0.0),
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
