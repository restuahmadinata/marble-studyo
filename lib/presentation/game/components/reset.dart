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

  /// Handles button press.
  ///
  /// Calls the onPressed callback without triggering animation.
  /// The animation should be triggered externally after a reset action.
  void _handlePress() {
    widget.onPressed?.call();
  }

  // ==================== Build Methods ====================

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;
    
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 2 * 3.141592653589793, // 2 * PI
          child: child,
        );
      },
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          iconSize: widget.responsive.scale(28),
          onPressed: isEnabled ? _handlePress : null,
        ),
      ),
    );
  }
}
