import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../marble_game.dart';

/// A marble component with physics, animations, and interaction handling.
///
/// This component represents an individual marble in the game that can:
/// - Be dragged and positioned by the user
/// - Form groups with other marbles
/// - Animate with idle wobbling, charging, and scale effects
/// - Stick to cards when placed correctly
/// - Scatter when groups are disbanded
class Marble extends PositionComponent
    with HasGameReference<MarbleGame>, DragCallbacks, TapCallbacks {
  // ==================== Public Properties ====================

  /// The radius of the marble in pixels
  final double radius;

  /// Current color of the marble's group
  Color groupColor = Colors.purple;

  /// Flag indicating if marble is currently being dragged
  bool isBeingDragged = false;

  /// Flag indicating if marble is connected to a group
  bool isConnected = false;

  /// Flag indicating if marble is charging for explosion (long press)
  bool isChargingExplosion = false;

  /// Flag indicating if marble is stuck to a card (physics disabled)
  bool isStuckToCard = false;

  /// Flag tracking if marble has been dragged at least once
  bool hasBeenDragged = false;

  /// Flag marking marble as dying (should be ignored by physics)
  bool isDying = false;

  // ==================== Private Properties ====================

  /// Paint object for the marble body
  final Paint _paint;

  /// Paint object for the marble border
  final Paint _borderPaint;

  /// Paint object for the center dot (when connected)
  final Paint _centerDotPaint;

  /// Target position for smooth movement interpolation
  late Vector2 targetPosition;

  /// Original formation position for idle animation
  late Vector2 originalFormPosition;

  /// Elapsed time for idle wobble animation
  double _timePassed = 0;

  /// Random speed multiplier for idle wobble
  late double _randomSpeed;

  /// Random range multiplier for idle wobble
  late double _randomRange;

  /// Timer for charging explosion animation
  double _chargingTimer = 0;

  // ==================== Constructor ====================

  /// Creates a new Marble at the specified position.
  ///
  /// Parameters:
  /// - [startX]: Initial X coordinate
  /// - [startY]: Initial Y coordinate
  /// - [radius]: Size of the marble (default: 15.0)
  Marble({required double startX, required double startY, this.radius = 15.0})
    : _paint = Paint()..color = Colors.purple,
      _borderPaint = Paint()
        ..color = const Color(0xFF6A1B9A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
      _centerDotPaint = Paint()..color = Colors.white.withValues(alpha: 0.5),
      super(
        position: Vector2(startX, startY),
        size: Vector2.all(30),
        anchor: Anchor.center,
        priority: 10,
      ) {
    _initializePosition(startX, startY);
    _initializeAnimation();
  }

  // ==================== Initialization Methods ====================

  /// Initializes position-related properties.
  void _initializePosition(double startX, double startY) {
    targetPosition = Vector2(startX, startY);
    originalFormPosition = Vector2(startX, startY);
  }

  /// Initializes animation-related properties with random values.
  void _initializeAnimation() {
    _randomSpeed = 0.5 + Random().nextDouble() * 1.0;
    _randomRange = 3 + Random().nextDouble() * 5;
    _timePassed = Random().nextDouble() * 100;
  }

  // ==================== Rendering Methods ====================

  /// Renders the marble on the canvas.
  ///
  /// Draws the marble body, border, and optionally a center dot
  /// when connected to a group.
  @override
  void render(Canvas canvas) {
    final Color currentColor = _getCurrentColor();
    _updatePaintColors(currentColor);

    final Offset center = Offset(size.x / 2, size.y / 2);

    // Draw marble body
    canvas.drawCircle(center, radius, _paint);

    // Draw border
    canvas.drawCircle(center, radius, _borderPaint);

    // Draw center dot if connected
    if (isConnected) {
      canvas.drawCircle(center, 4, _centerDotPaint);
    }
  }

  /// Determines the current color based on marble state.
  Color _getCurrentColor() {
    if (isBeingDragged) {
      return groupColor.withValues(alpha: 0.7);
    } else if (isChargingExplosion) {
      return Colors.redAccent;
    } else {
      return groupColor;
    }
  }

  /// Updates paint colors based on the current marble color.
  void _updatePaintColors(Color currentColor) {
    _paint.color = currentColor;
    _borderPaint.color = _darkenColor(currentColor, 0.12);
  }

  /// Darkens a color by reducing its lightness.
  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );
    return darkened.toColor();
  }

  // ==================== Update Methods ====================

  /// Updates the marble's state each frame.
  ///
  /// Handles physics interpolation, idle wobbling, drag shake,
  /// charging animation, and boundary constraints.
  @override
  void update(double dt) {
    super.update(dt);

    // Skip all physics if stuck to a card
    if (isStuckToCard) return;

    _applyPhysicsInterpolation(dt);
    _applyIdleWobble(dt);
    _applyDragShake();
    _applyChargingAnimation(dt);
    _applyBoundaryConstraints();
  }

  /// Applies smooth physics interpolation toward target position.
  void _applyPhysicsInterpolation(double dt) {
    if (position.distanceTo(targetPosition) > 0.5) {
      position.add((targetPosition - position) * dt * 6);
    } else {
      position.setFrom(targetPosition);
    }
  }

  /// Applies idle wobbling animation when not dragged or connected.
  void _applyIdleWobble(double dt) {
    if (!isBeingDragged && !isChargingExplosion && !isConnected) {
      _timePassed += dt;
      final double currentRange = _randomRange * 0.5;
      final double offsetX = sin(_timePassed * _randomSpeed) * currentRange;
      final double offsetY =
          cos(_timePassed * _randomSpeed) * (currentRange * 0.7);
      targetPosition = originalFormPosition + Vector2(offsetX, offsetY);
    }
  }

  /// Applies shake effect while being dragged.
  void _applyDragShake() {
    if (isBeingDragged) {
      final double shakeX = (Random().nextDouble() - 0.5) * 2;
      final double shakeY = (Random().nextDouble() - 0.5) * 2;
      position.add(Vector2(shakeX, shakeY));
    }
  }

  /// Applies charging explosion animation with controlled shake.
  void _applyChargingAnimation(double dt) {
    if (!isChargingExplosion) return;

    _chargingTimer += dt;

    // Scale up animation (max 1.4x)
    final double growFactor = (1.0 + (_chargingTimer * 1.5)).clamp(1.0, 1.4);
    scale.setValues(growFactor, growFactor);

    // Controlled shake (clamped to prevent teleportation)
    final double intensity = (_chargingTimer * 10).clamp(0, 5.0);
    final double shakeX = (Random().nextDouble() - 0.5) * intensity;
    final double shakeY = (Random().nextDouble() - 0.5) * intensity;
    position.add(Vector2(shakeX, shakeY));
  }

  /// Applies boundary constraints to keep marble in play area.
  void _applyBoundaryConstraints() {
    final double minX = radius;
    final double maxX = game.size.x - radius;
    final double minY = game.topBoundary + radius;
    final double maxY = game.bottomBoundary - radius;

    position.x = position.x.clamp(minX, maxX);
    position.y = position.y.clamp(minY, maxY);
    targetPosition.x = targetPosition.x.clamp(minX, maxX);
    targetPosition.y = targetPosition.y.clamp(minY, maxY);
  }

  // ==================== Animation Methods ====================

  /// Scatters the marble in a direction with full force.
  ///
  /// Parameters:
  /// - [pushDirection]: Normalized direction vector for scatter
  void scatter(Vector2 pushDirection) {
    _resetExplosionState();

    final Vector2 jump = pushDirection * 80;
    targetPosition += jump;
    originalFormPosition += jump;
  }

  /// Scatters the marble with reduced distance.
  ///
  /// Used when disbanding groups that aren't stuck to cards.
  ///
  /// Parameters:
  /// - [pushDirection]: Normalized direction vector for scatter
  void scatterReduced(Vector2 pushDirection) {
    _resetExplosionState();

    final Vector2 jump = pushDirection * 40;
    targetPosition += jump;
    originalFormPosition += jump;
  }

  /// Animates the marble disappearing (scale down to 0).
  ///
  /// Used when removing marbles from the game with smooth exit.
  Future<void> animateDisappear() async {
    isDying = true;

    const int steps = 30;
    const stepDuration = Duration(milliseconds: 10);

    for (int i = 0; i < steps; i++) {
      if (!isMounted) return;

      final double progress = (i + 1) / steps;
      final double scaleValue = 1.0 - progress;
      scale.setValues(scaleValue, scaleValue);

      await Future.delayed(stepDuration);
    }

    if (isMounted) {
      removeFromParent();
    }
  }

  /// Animates the marble appearing (scale up from 0 with elastic effect).
  ///
  /// Parameters:
  /// - [delayMs]: Milliseconds to wait before starting animation
  Future<void> animateAppear({int delayMs = 0}) async {
    if (delayMs > 0) {
      await Future.delayed(Duration(milliseconds: delayMs));
    }

    // Start invisible
    scale.setValues(0.0, 0.0);

    const int steps = 40;
    const stepDuration = Duration(milliseconds: 10);

    for (int i = 0; i < steps; i++) {
      if (!isMounted) return;

      final double progress = (i + 1) / steps;
      final double scaleValue = _calculateElasticScale(progress);

      scale.setValues(scaleValue, scaleValue);
      await Future.delayed(stepDuration);
    }

    // Ensure final scale is exactly 1.0
    if (isMounted) {
      scale.setValues(1.0, 1.0);
    }
  }

  /// Calculates elastic scale value for appear animation.
  ///
  /// Creates an overshoot effect that makes the appearance more dynamic.
  double _calculateElasticScale(double progress) {
    if (progress < 0.7) {
      // First 70%: normal scale up
      return progress / 0.7;
    } else {
      // Last 30%: overshoot and settle
      final double overshootProgress = (progress - 0.7) / 0.3;
      return 1.0 + (sin(overshootProgress * pi) * 0.2);
    }
  }

  // ==================== Interaction Handlers ====================

  /// Handles drag start events.
  @override
  void onDragStart(DragStartEvent event) {
    _resetExplosionState();
    super.onDragStart(event);

    isBeingDragged = true;
    hasBeenDragged = true;
    scale.setValues(1.2, 1.2);
    game.setGroupPriority(this, 100);
  }

  /// Handles drag update events.
  @override
  void onDragUpdate(DragUpdateEvent event) {
    game.moveGroup(this, event.localDelta);
  }

  /// Handles drag end events.
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);

    isBeingDragged = false;
    scale.setValues(1.0, 1.0);
    game.setGroupPriority(this, 10);
    originalFormPosition.setFrom(targetPosition);
  }

  /// Handles long tap down events (charge explosion).
  @override
  void onLongTapDown(TapDownEvent event) {
    if (isConnected) {
      isChargingExplosion = true;
      _chargingTimer = 0;
    }
  }

  /// Handles tap up events (trigger explosion).
  @override
  void onTapUp(TapUpEvent event) {
    if (isConnected && isChargingExplosion) {
      game.disbandGroup(this);
    }
    _resetExplosionState();
  }

  /// Handles tap cancel events.
  @override
  void onTapCancel(TapCancelEvent event) {
    _resetExplosionState();
  }

  /// Resets explosion charging state.
  void _resetExplosionState() {
    isChargingExplosion = false;
    _chargingTimer = 0;
    if (!isBeingDragged) {
      scale.setValues(1.0, 1.0);
    }
  }
}
