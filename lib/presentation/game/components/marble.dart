import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../marble_game.dart';

class Marble extends PositionComponent with HasGameReference<MarbleGame>, DragCallbacks, TapCallbacks {
  final double radius = 20;
  final Paint _paint;
  final Paint _centerDotPaint;
  final Paint _outlinePaint; 

  late Vector2 targetPosition;
  late Vector2 originalFormPosition; 

  double _timePassed = 0;
  late double _randomSpeed;
  late double _randomRange;
  
  double _chargingTimer = 0; 
  
  bool isBeingDragged = false;
  bool isConnected = false; 
  bool isChargingExplosion = false;

  Marble({
    required double startX,
    required double startY,
  }) : _paint = Paint()..color = Colors.purple,
       _outlinePaint = Paint()
          ..color = Colors.purpleAccent.shade100 
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0,
       _centerDotPaint = Paint()..color = Colors.white.withValues(alpha: 0.5), 
       super(
         position: Vector2(startX, startY),
         size: Vector2.all(40),
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
    if (isBeingDragged) {
      _paint.color = Colors.purpleAccent;
    } else if (isChargingExplosion) {
      _paint.color = Colors.redAccent; 
    } else {
      _paint.color = Colors.purple;
    }
    
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), radius, _paint);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), radius, _outlinePaint);

    if (isConnected) {
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), 4, _centerDotPaint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
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
    double minY = radius;
    double maxY = game.size.y - radius;

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

  @override
  void onDragStart(DragStartEvent event) {
    _resetExplosionState(); 
    super.onDragStart(event);
    isBeingDragged = true;
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