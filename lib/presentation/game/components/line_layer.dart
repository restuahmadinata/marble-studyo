import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// A component layer for drawing connection lines between marbles.
///
/// This layer renders visual lines that connect grouped marbles,
/// providing visual feedback of which marbles are connected together.
/// The lines are semi-transparent to avoid obscuring game elements.
class LineLayer extends Component {
  // ==================== Public Properties ====================

  /// Paint object for rendering connection lines
  final Paint linePaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.3)
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.round;

  /// List of marble position pairs to draw lines between.
  /// Each inner list contains exactly 2 Vector2 positions.
  List<List<Vector2>> connectionsToDraw = [];

  // ==================== Constructor ====================

  /// Creates a new LineLayer with priority 20.
  ///
  /// Priority is set to 20 to ensure lines are drawn above
  /// the background but below marbles (priority 10+).
  LineLayer() : super(priority: 20);

  // ==================== Rendering Methods ====================

  /// Renders all connection lines on the canvas.
  ///
  /// Iterates through all marble position pairs and draws
  /// a line connecting each pair.
  @override
  void render(Canvas canvas) {
    for (final pair in connectionsToDraw) {
      canvas.drawLine(pair[0].toOffset(), pair[1].toOffset(), linePaint);
    }
  }
}
