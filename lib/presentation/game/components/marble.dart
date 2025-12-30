import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../marble_game.dart';

class Marble extends PositionComponent
    with HasGameReference<MarbleGame>, DragCallbacks, TapCallbacks {
  final double radius;
  final Paint _paint;
  final Paint _borderPaint;
  final Paint _centerDotPaint;

  late Vector2 targetPosition;
  late Vector2 originalFormPosition;

  double _timePassed = 0;
  late double _randomSpeed;
  late double _randomRange;

  double _chargingTimer = 0;

  bool isBeingDragged = false;
  bool isConnected = false;
  bool isChargingExplosion = false;
  bool isStuckToCard = false; // New flag for stuck marbles
  bool hasBeenDragged = false; // Track if marble has been dragged at least once
  Color groupColor = Colors.purple; // Default color

  Marble({required double startX, required double startY, this.radius = 15.0})
    : _paint = Paint()..color = Colors.purple,
      _borderPaint = Paint()
        ..color =
            const Color(0xFF6A1B9A) // Darker purple
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
      _centerDotPaint = Paint()..color = Colors.white.withValues(alpha: 0.5),
      super(
        position: Vector2(startX, startY),
        size: Vector2.all(30),
        anchor: Anchor.center,
        priority: 10,
      ) {
    targetPosition = Vector2(startX, startY);
    originalFormPosition = Vector2(startX, startY);

    _randomSpeed = 0.5 + Random().nextDouble() * 1.0;
    _randomRange = 3 + Random().nextDouble() * 5;
    _timePassed = Random().nextDouble() * 100;
  }

  @override
  void render(Canvas canvas) {
    Color currentColor;
    if (isBeingDragged) {
      currentColor = groupColor.withValues(alpha: 0.7);
    } else if (isChargingExplosion) {
      currentColor = Colors.redAccent;
    } else {
      currentColor = groupColor;
    }

    _paint.color = currentColor;

    // Update border color to be darker than the base color
    _borderPaint.color = _darkenColor(currentColor, 0.12);

    // Draw the marble body
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), radius, _paint);

    // Draw the border
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), radius, _borderPaint);

    if (isConnected) {
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), 4, _centerDotPaint);
    }
  }

  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );
    return darkened.toColor();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Skip all physics if stuck to a card
    if (isStuckToCard) {
      return;
    }

    // Physics Inersia
    if (position.distanceTo(targetPosition) > 0.5) {
      position.add((targetPosition - position) * dt * 6);
    } else {
      position.setFrom(targetPosition);
    }

    // Logic Goyang (Idle)
    if (!isBeingDragged && !isChargingExplosion && !isConnected) {
      _timePassed += dt;
      double currentRange = _randomRange * 0.5;
      double offsetX = sin(_timePassed * _randomSpeed) * currentRange;
      double offsetY = cos(_timePassed * _randomSpeed) * (currentRange * 0.7);
      targetPosition = originalFormPosition + Vector2(offsetX, offsetY);
    }

    // Getar saat didrag
    if (isBeingDragged) {
      double shakeX = (Random().nextDouble() - 0.5) * 2;
      double shakeY = (Random().nextDouble() - 0.5) * 2;
      position.add(Vector2(shakeX, shakeY));
    }

    // --- ANIMASI CHARGING (YANG DIPERBAIKI) ---
    if (isChargingExplosion) {
      _chargingTimer += dt;

      // 1. Scale Up: Max 1.4x (sedikit dikurangi biar ga terlalu besar)
      double growFactor = 1.0 + (_chargingTimer * 1.5);
      growFactor = growFactor.clamp(1.0, 1.4);
      scale.setValues(growFactor, growFactor);

      // 2. Controlled Shake:
      // Kita tambahkan .clamp(0, 5.0).
      // Artinya sekeras apapun getarannya, maksimal cuma geser 5 pixel.
      // Ini mencegah marble "teleport" kejauhan sampai physics error.
      double intensity = (_chargingTimer * 10).clamp(0, 5.0);

      double shakeX = (Random().nextDouble() - 0.5) * intensity;
      double shakeY = (Random().nextDouble() - 0.5) * intensity;

      position.add(Vector2(shakeX, shakeY));
    }

    // Boundaries (Container boundaries)
    double minX = radius;
    double maxX = game.size.x - radius;
    double minY = game.topBoundary + radius;
    double maxY = game.bottomBoundary - radius;

    position.x = position.x.clamp(minX, maxX);
    position.y = position.y.clamp(minY, maxY);
    targetPosition.x = targetPosition.x.clamp(minX, maxX);
    targetPosition.y = targetPosition.y.clamp(minY, maxY);
  }

  void scatter(Vector2 pushDirection) {
    isChargingExplosion = false;
    _chargingTimer = 0;
    scale.setValues(1.0, 1.0);

    Vector2 jump = pushDirection * 80;
    targetPosition += jump;
    originalFormPosition += jump;
  }

  void scatterReduced(Vector2 pushDirection) {
    isChargingExplosion = false;
    _chargingTimer = 0;
    scale.setValues(1.0, 1.0);

    Vector2 jump = pushDirection * 40; // Reduced distance (half of normal)
    targetPosition += jump;
    originalFormPosition += jump;
  }

  @override
  void onDragStart(DragStartEvent event) {
    _resetExplosionState();
    super.onDragStart(event);
    isBeingDragged = true;
    hasBeenDragged = true; // Mark as dragged
    scale.setValues(1.2, 1.2);
    game.setGroupPriority(this, 100);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    game.moveGroup(this, event.localDelta);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    isBeingDragged = false;
    scale.setValues(1.0, 1.0);
    game.setGroupPriority(this, 10);
    originalFormPosition.setFrom(targetPosition);
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    if (isConnected) {
      isChargingExplosion = true;
      _chargingTimer = 0;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (isConnected && isChargingExplosion) {
      game.disbandGroup(this);
    }
    _resetExplosionState();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _resetExplosionState();
  }

  void _resetExplosionState() {
    isChargingExplosion = false;
    _chargingTimer = 0;
    if (!isBeingDragged) scale.setValues(1.0, 1.0);
  }
}
