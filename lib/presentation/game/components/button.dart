import 'package:flutter/material.dart';
import '../../../utils/responsive_utils.dart';

/// A button widget with neobrutalism style and press animation.
///
/// This component creates a button with a distinct shadow that animates
/// when pressed, simulating a physical button being pushed. The button
/// moves down and right while the shadow disappears on press, and returns
/// to its original position on release.
///
/// The animation follows CSS neobrutalism patterns:
/// - Default: Shadow offset at (4, 4)
/// - Hover (not implemented on mobile): Shadow increases, button moves up/left
/// - Active (pressed): Shadow becomes (0, 0), button moves down/right
class Button extends StatefulWidget {
  /// The text displayed on the button
  final String text;

  /// The background color of the button
  final Color color;

  /// The border color (also used for shadow)
  final Color borderColor;

  /// The text color
  final Color textColor;

  /// The callback function when the button is tapped
  final VoidCallback onTap;

  /// The responsive utilities for scaling
  final ResponsiveUtils responsive;

  /// The horizontal padding inside the button
  final double horizontalPadding;

  /// The vertical padding inside the button
  final double verticalPadding;

  /// The border radius of the button (optional, defaults to 8)
  final double? borderRadius;

  /// Creates an animated neomorphic button.
  ///
  /// Parameters:
  /// - [text]: The label text to display
  /// - [color]: The button's background color
  /// - [borderColor]: The color for both border and shadow
  /// - [textColor]: The color of the text label
  /// - [onTap]: The callback executed on tap
  /// - [responsive]: Utility for responsive scaling
  /// - [horizontalPadding]: Horizontal padding (default: 32)
  /// - [verticalPadding]: Vertical padding (default: 12)
  /// - [borderRadius]: Custom border radius (optional, defaults to 8)
  const Button({
    super.key,
    required this.text,
    required this.color,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
    required this.responsive,
    this.horizontalPadding = 32,
    this.verticalPadding = 12,
    this.borderRadius,
  });

  @override
  State<Button> createState() =>
      _ButtonState();
}

class _ButtonState extends State<Button> {
  /// Tracks whether the button is currently being pressed
  bool _isPressed = false;

  // ==================== Event Handlers ====================

  /// Handles the press down event.
  ///
  /// Updates the state to show the pressed animation.
  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  /// Handles the press up event.
  ///
  /// Returns the button to its default state and triggers the onTap callback.
  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    widget.onTap();
  }

  /// Handles the tap cancel event.
  ///
  /// Returns the button to its default state without triggering onTap.
  /// This occurs when the user moves their finger off the button.
  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  // ==================== Build Methods ====================

  @override
  Widget build(BuildContext context) {
    // Calculate the transform offset based on press state
    // When pressed: move down and right by 4 pixels
    // When not pressed: no offset
    final double offsetX = _isPressed ? widget.responsive.scale(4) : 0;
    final double offsetY = _isPressed ? widget.responsive.scale(4) : 0;

    // Calculate shadow offset
    // When pressed: no shadow (0, 0)
    // When not pressed: shadow at (4, 4)
    final double shadowX = _isPressed ? 0 : widget.responsive.scale(4);
    final double shadowY = _isPressed ? 0 : widget.responsive.scale(4);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(offsetX, offsetY, 0),
        padding: widget.responsive.scaleSymmetricPadding(
          widget.horizontalPadding,
          widget.verticalPadding,
        ),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(
            widget.responsive.scaleRadius(widget.borderRadius ?? 8),
          ),
          border: Border.all(
            color: widget.borderColor,
            width: widget.responsive.scale(2),
          ),
          boxShadow: [
            BoxShadow(
              color: widget.borderColor,
              offset: Offset(shadowX, shadowY),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            color: widget.textColor,
            fontSize: widget.responsive.scaleFontSize(16),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
