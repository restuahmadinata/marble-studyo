import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A text widget that animates like a slot machine reel.
///
/// This component displays a number with a slot machine-style reveal animation.
/// When the number changes, it rolls through several random numbers before
/// settling on the final value, creating an engaging visual effect similar
/// to mechanical slot machines.
///
/// The animation consists of:
/// 1. Multiple quick rolls through random numbers
/// 2. Gradual slowdown as it approaches the target
/// 3. Final settlement on the target number
class SlotText extends StatefulWidget {
  /// The target number to display after animation
  final int number;

  /// The text style to apply to the number
  final TextStyle style;

  /// The duration of the complete animation
  final Duration duration;

  /// Creates a slot machine text widget.
  ///
  /// Parameters:
  /// - [number]: The final number to display
  /// - [style]: The text styling
  /// - [duration]: How long the animation should last (default: 600ms)
  const SlotText({
    super.key,
    required this.number,
    required this.style,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<SlotText> createState() => _SlotTextState();
}

class _SlotTextState extends State<SlotText>
    with SingleTickerProviderStateMixin {
  /// Animation controller for the slot machine effect
  late AnimationController _controller;

  /// The currently displayed number during animation
  int _displayNumber = 0;

  /// Random number generator for intermediate values
  final math.Random _random = math.Random();

  // ==================== Lifecycle Methods ====================

  @override
  void initState() {
    super.initState();
    _displayNumber = widget.number;
    _initializeAnimation();
  }

  @override
  void didUpdateWidget(SlotText oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only animate if the number has changed
    if (oldWidget.number != widget.number) {
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ==================== Animation Methods ====================

  /// Initializes the animation controller.
  ///
  /// Sets up the controller with the specified duration and
  /// adds a listener to update the displayed number.
  void _initializeAnimation() {
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _controller.addListener(_updateDisplayNumber);
  }

  /// Starts the slot machine animation.
  ///
  /// Resets the controller and begins the animation from the start.
  void _startAnimation() {
    _controller.reset();
    _controller.forward();
  }

  /// Updates the displayed number based on animation progress.
  ///
  /// Creates a slot machine effect by:
  /// 1. Rapidly cycling through random numbers in the first 70% of animation
  /// 2. Slowing down in the next 20%
  /// 3. Settling on the final value in the last 10%
  void _updateDisplayNumber() {
    final double progress = _controller.value;

    if (progress < 0.7) {
      // Fast rolling phase: show random numbers
      // The range is based on the target number to keep it visually relevant
      final int maxRange = math.max(widget.number * 2, 20);
      setState(() {
        _displayNumber = _random.nextInt(maxRange);
      });
    } else if (progress < 0.9) {
      // Slowdown phase: numbers closer to target
      // Interpolate between random values and target
      final int range = (widget.number * 0.3).toInt() + 1;
      setState(() {
        _displayNumber = widget.number + _random.nextInt(range) - (range ~/ 2);
        _displayNumber = math.max(0, _displayNumber); // Keep positive
      });
    } else {
      // Final phase: settle on target number
      setState(() {
        _displayNumber = widget.number;
      });
    }
  }

  // ==================== Build Methods ====================

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Slide transition for smoother number changes
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -0.3),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Text(
        _displayNumber.toString(),
        key: ValueKey<int>(_displayNumber),
        style: widget.style,
      ),
    );
  }
}
