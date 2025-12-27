import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LineLayer extends Component {
  final Paint linePaint = Paint()
    // Opacity dikurangi jadi 0.3 (Sesuai request)
    ..color = Colors.white.withOpacity(0.3) 
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.round;

  List<List<Vector2>> connectionsToDraw = [];

  LineLayer() : super(priority: 20); 

  @override
  void render(Canvas canvas) {
    for (final pair in connectionsToDraw) {
      canvas.drawLine(
        pair[0].toOffset(),
        pair[1].toOffset(),
        linePaint
      );
    }
  }
}