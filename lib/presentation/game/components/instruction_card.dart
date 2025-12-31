import 'package:flutter/material.dart';
import '../../../utils/responsive_utils.dart';

/// A widget that displays game instructions to the user.
///
/// This card appears at the top of the game screen with a purple
/// background and white text, providing clear instructions about
/// the current game objective.
class InstructionCard extends StatelessWidget {
  // ==================== Public Properties ====================

  /// The instruction text to display to the user
  final String instruction;

  // ==================== Constructor ====================

  /// Creates an InstructionCard with the given instruction text.
  ///
  /// Parameters:
  /// - [instruction]: The text to display in the card
  const InstructionCard({super.key, required this.instruction});

  // ==================== Build Methods ====================

  /// Builds the instruction card widget.
  ///
  /// Returns a positioned card at the top of the screen with
  /// responsive sizing and styling.
  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Positioned(
      top: responsive.scale(16),
      left: responsive.scale(16),
      right: responsive.scale(16),
      child: Card(
        color: const Color(0xFFB34FB4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.scaleRadius(50)),
        ),
        child: Padding(
          padding: responsive.scalePadding(const EdgeInsets.all(16.0)),
          child: Text(
            instruction,
            style: TextStyle(
              color: Colors.white,
              fontSize: responsive.scaleFontSize(18.0),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
