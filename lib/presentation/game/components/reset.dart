import 'package:flutter/material.dart';
import '../../../utils/responsive_utils.dart';

/// A reset button with rotation animation.
///
/// This component displays a refresh icon button that rotates 360 degrees
/// when triggered. The rotation animation provides visual feedback that
/// a reset action has been performed.
///
/// The button maintains the same visual style as other buttons in the app
/// but adds an engaging rotation animation to communicate the reset action.
/// Supports disabled state with reduced opacity.
class ResetButton extends StatefulWidget {
  /// The callback function when the button is tapped (null disables button)
  final VoidCallback? onPressed;

  /// The responsive utilities for scaling
  final ResponsiveUtils responsive;

  /// Creates an animated reset button.
  ///
  /// Parameters:
  /// - [onPressed]: The callback executed when button is tapped (null to disable)
  /// - [responsive]: Utility for responsive scaling
  const ResetButton({
    super.key,
    required this.onPressed,
    required this.responsive,
  });

  @override
  State<ResetButton> createState() => ResetButtonState();
}

class ResetButtonState extends State<ResetButton>
    with SingleTickerProviderStateMixin {
  /// Animation controller for rotation effect
  late AnimationController _rotationController;

  /// Animation for the rotation degrees
  late Animation<double> _rotationAnimation;

  /// Tracks whether the button is currently being pressed
  bool _isPressed = false;

  // ==================== Lifecycle Methods ====================

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  // ==================== Animation Methods ====================

  /// Initializes the rotation animation.
  ///
  /// Sets up a 360-degree rotation that completes in 500ms
  /// with a smooth easeInOut curve.
  void _initializeAnimation() {
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _rotationAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0, // 1.0 represents a full rotation (360 degrees)
        ).animate(
          CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
        );
  }

  /// Triggers the rotation animation.
  ///
  /// Resets the controller to ensure consistent animation even
  /// if triggered multiple times quickly.
  void animate() {
    _rotationController.reset();
    _rotationController.forward();
  }

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
  /// Returns the button to its default state and triggers the onPressed callback.
  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    widget.onPressed?.call();
  }

  /// Handles the tap cancel event.
  ///
  /// Returns the button to its default state without triggering onPressed.
  /// This occurs when the user moves their finger off the button.
  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  // ==================== Build Methods ====================

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;
    
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
    
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 2 * 3.141592653589793, // 2 * PI
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: isEnabled ? _handleTapDown : null,
        onTapUp: isEnabled ? _handleTapUp : null,
        onTapCancel: isEnabled ? _handleTapCancel : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          transform: Matrix4.translationValues(offsetX, offsetY, 0),
          padding: EdgeInsets.all(widget.responsive.scale(8)),
          decoration: BoxDecoration(
            color: const Color(0xFF7e4db8), // Purple color matching question cards
            borderRadius: BorderRadius.circular(
              widget.responsive.scaleRadius(8),
            ),
            border: Border.all(
              color: const Color(0xFF5a1d8c),
              width: widget.responsive.scale(2),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5a1d8c),
                offset: Offset(shadowX, shadowY),
                blurRadius: 0,
              ),
            ],
          ),
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.5,
            child: Icon(
              Icons.refresh,
              color: Colors.white,
              size: widget.responsive.scale(28),
            ),
          ),
        ),
      ),
    );
  }
}
