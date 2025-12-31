import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../../../utils/responsive_utils.dart';
import 'button.dart';
import 'reset.dart';
import 'slot_text.dart';

/// A widget that displays the division question and equals sign.
///
/// This component shows the current math problem at the top of the
/// game area and includes a reset button for starting a new game.
class QuestionEqualsCard extends StatefulWidget {
  const QuestionEqualsCard({super.key});

  @override
  State<QuestionEqualsCard> createState() => _QuestionEqualsCardState();
}

class _QuestionEqualsCardState extends State<QuestionEqualsCard> {
  /// Global key to access the AnimatedResetButton's state
  final GlobalKey<ResetButtonState> _resetButtonKey =
      GlobalKey<ResetButtonState>();

  // ==================== Build Methods ====================

  /// Builds the question and equals cards stacked together.
  @override
  Widget build(BuildContext context) {
    final GameController controller = Get.find<GameController>();
    final responsive = context.responsive;

    return Obx(
      () => Stack(
        children: [
          _buildQuestionCard(context, controller, responsive),
          _buildEqualsCard(responsive),
        ],
      ),
    );
  }

  /// Builds the main question card displaying the division problem.
  ///
  /// Includes the question text and a reset button in the top-right corner.
  Widget _buildQuestionCard(
    BuildContext context,
    GameController controller,
    ResponsiveUtils responsive,
  ) {
    return Positioned(
      top: responsive.scale(102),
      left: responsive.scale(32),
      right: responsive.scale(32),
      child: Container(
        decoration: _getCardDecoration(
          backgroundColor: const Color(0xFF7e4db8),
          borderColor: const Color(0xFF5a1d8c),
          shadowColor: const Color(0xFF5a1d8c),
          responsive: responsive,
        ),
        padding: EdgeInsets.all(responsive.scale(16.0)),
        child: Stack(
          children: [
            _buildQuestionText(controller, responsive),
            _buildResetButton(context, responsive),
          ],
        ),
      ),
    );
  }

  /// Builds the centered question text showing the division problem.
  ///
  /// Uses SlotText for the dividend (first number) to create
  /// an engaging animation when the question changes.
  Widget _buildQuestionText(
    GameController controller,
    ResponsiveUtils responsive,
  ) {
    // Parse the question to separate dividend and divisor
    // Format is "X ÷ Y" where X is dividend and Y is divisor
    final parts = controller.questionText.split('÷');

    if (parts.length == 2) {
      final int dividend = int.tryParse(parts[0].trim()) ?? 0;
      final String divisor = parts[1].trim();

      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated dividend using SlotText
            SlotText(
              number: dividend,
              style: TextStyle(
                color: Colors.white,
                fontSize: responsive.scaleFontSize(52.0),
              ),
            ),
            SizedBox(width: responsive.scale(8)),
            // Static division symbol
            Text(
              '÷',
              style: TextStyle(
                color: Colors.white,
                fontSize: responsive.scaleFontSize(52.0),
              ),
            ),
            SizedBox(width: responsive.scale(8)),
            // Static divisor (no animation)
            Text(
              divisor,
              style: TextStyle(
                color: Colors.white,
                fontSize: responsive.scaleFontSize(52.0),
              ),
            ),
          ],
        ),
      );
    }

    // Fallback to original text if parsing fails
    return Center(
      child: Text(
        controller.questionText,
        style: TextStyle(
          color: Colors.white,
          fontSize: responsive.scaleFontSize(52.0),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Builds the reset button in the top-right corner.
  ///
  /// When tapped, shows a confirmation dialog before resetting the game.
  /// The button animates with a rotation when the reset is confirmed.
  /// Button is disabled during reset animations to prevent spam.
  Widget _buildResetButton(BuildContext context, ResponsiveUtils responsive) {
    final GameController controller = Get.find<GameController>();
    
    return Positioned(
      top: 0,
      right: 0,
      child: Obx(() => ResetButton(
        key: _resetButtonKey,
        responsive: responsive,
        onPressed: controller.isResetting.value 
            ? null 
            : () => _showResetDialog(context),
      )),
    );
  }

  /// Builds the equals sign card below the question card.
  Widget _buildEqualsCard(ResponsiveUtils responsive) {
    return Positioned(
      top: responsive.scale(190),
      left: responsive.scale(120),
      right: responsive.scale(120),
      child: Container(
        decoration: _getCardDecoration(
          backgroundColor: const Color(0xFF561f96),
          borderColor: Colors.black,
          shadowColor: const Color(0xFF32015f),
          responsive: responsive,
        ),
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: responsive.scale(40),
          child: Padding(
            padding: EdgeInsets.only(top: responsive.scale(12)),
            child: Text(
              "=",
              style: TextStyle(
                color: Colors.white,
                fontSize: responsive.scaleFontSize(52.0),
                height: 0.1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== Dialog Methods ====================

  /// Shows a confirmation dialog for resetting the game.
  ///
  /// Prompts the user to confirm before resetting to prevent
  /// accidental game resets.
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final dialogResponsive = dialogContext.responsive;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              dialogResponsive.scaleRadius(12),
            ),
            side: BorderSide(
              color: const Color(0xFF5a1d8c),
              width: dialogResponsive.scale(3),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF7e4db8),
              borderRadius: BorderRadius.circular(
                dialogResponsive.scaleRadius(12),
              ),
              border: Border.all(
                color: const Color(0xFF5a1d8c),
                width: dialogResponsive.scale(3),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5a1d8c),
                  offset: Offset(
                    dialogResponsive.scale(6),
                    dialogResponsive.scale(6),
                  ),
                  blurRadius: 0,
                ),
              ],
            ),
            padding: EdgeInsets.all(dialogResponsive.scale(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTitle(dialogResponsive),
                SizedBox(height: dialogResponsive.scale(16)),
                _buildDialogMessage(dialogResponsive),
                SizedBox(height: dialogResponsive.scale(24)),
                _buildDialogActions(dialogContext, dialogResponsive),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the dialog title text.
  Widget _buildDialogTitle(ResponsiveUtils responsive) {
    return Text(
      'Reset Game',
      style: TextStyle(
        fontSize: responsive.scaleFontSize(24),
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  /// Builds the dialog confirmation message.
  Widget _buildDialogMessage(ResponsiveUtils responsive) {
    return Text(
      'Are you sure you want to reset the game?',
      style: TextStyle(
        fontSize: responsive.scaleFontSize(16),
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Builds the dialog action buttons (Cancel and Reset).
  Widget _buildDialogActions(
    BuildContext dialogContext,
    ResponsiveUtils responsive,
  ) {
    final GameController controller = Get.find<GameController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDialogButton(
          text: 'Cancel',
          color: Colors.white,
          onTap: () => Navigator.of(dialogContext).pop(),
          responsive: responsive,
        ),
        _buildDialogButton(
          text: 'Reset',
          color: const Color(0xFFE5A882),
          onTap: () {
            Navigator.of(dialogContext).pop();
            controller.resetGame();
            // Trigger the reset button rotation animation
            _resetButtonKey.currentState?.animate();
          },
          responsive: responsive,
        ),
      ],
    );
  }

  /// Builds a styled dialog button with press animation.
  Widget _buildDialogButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
    required ResponsiveUtils responsive,
  }) {
    return Button(
      text: text,
      color: color,
      borderColor: const Color(0xFF5a1d8c),
      textColor: Colors.black,
      onTap: onTap,
      responsive: responsive,
      horizontalPadding: 24,
      verticalPadding: 12,
    );
  }

  // ==================== Utility Methods ====================

  /// Creates a decoration for neomorphic-style cards.
  ///
  /// Returns a BoxDecoration with the specified colors and
  /// responsive sizing for borders and shadows.
  BoxDecoration _getCardDecoration({
    required Color backgroundColor,
    required Color borderColor,
    required Color shadowColor,
    required ResponsiveUtils responsive,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(responsive.scaleRadius(8)),
      border: Border.all(color: borderColor, width: responsive.scale(2)),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          offset: Offset(responsive.scale(4), responsive.scale(4)),
          blurRadius: 0,
        ),
      ],
    );
  }
}
