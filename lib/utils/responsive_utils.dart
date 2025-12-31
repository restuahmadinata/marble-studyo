import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Utility class for responsive UI scaling across different screen sizes.
///
/// This class provides methods to scale dimensions, fonts, and spacing
/// based on the device's screen size, ensuring consistent appearance
/// across various devices (phones, tablets, desktops).
///
/// Design is based on reference dimensions of 430x932 (typical mobile phone).
class ResponsiveUtils {
  // ==================== Public Properties ====================

  /// The build context for accessing screen information
  final BuildContext context;

  // ==================== Private Properties ====================

  /// The size of the current device screen
  late final Size _screenSize;

  /// The width of the current device screen
  late final double _screenWidth;

  /// The height of the current device screen
  late final double _screenHeight;

  /// The scale factor for general UI elements
  late final double _scaleFactor;

  /// The scale factor specifically for text elements
  late final double _textScaleFactor;

  // ==================== Design Constants ====================

  /// Reference design width (typical mobile phone width)
  static const double designWidth = 430.0;

  /// Reference design height (typical mobile phone height)
  static const double designHeight = 932.0;

  // ==================== Constructor ====================

  /// Creates a ResponsiveUtils instance for the given context.
  ///
  /// Automatically calculates scale factors based on screen size
  /// compared to the design reference dimensions.
  ResponsiveUtils(this.context) {
    _screenSize = MediaQuery.of(context).size;
    _screenWidth = _screenSize.width;
    _screenHeight = _screenSize.height;

    _calculateScaleFactors();
  }

  // ==================== Initialization Methods ====================

  /// Calculates scale factors for UI and text elements.
  ///
  /// Uses the smaller of width and height scale to ensure content fits.
  /// Text scale is limited between 0.7 and 1.5 for readability.
  void _calculateScaleFactors() {
    final double widthScale = _screenWidth / designWidth;
    final double heightScale = _screenHeight / designHeight;

    // Use the smaller scale to ensure content fits on screen
    _scaleFactor = math.min(widthScale, heightScale);

    // Calculate text scale with limits to maintain readability
    _textScaleFactor = math.max(0.7, math.min(_scaleFactor, 1.5));
  }

  // ==================== Getters ====================

  /// Returns the screen width in pixels
  double get screenWidth => _screenWidth;

  /// Returns the screen height in pixels
  double get screenHeight => _screenHeight;

  /// Returns the calculated scale factor
  double get scaleFactor => _scaleFactor;

  // ==================== Scaling Methods ====================

  /// Scales a dimension proportionally to screen size.
  ///
  /// Parameters:
  /// - [size]: The original size from the design
  ///
  /// Returns the scaled size appropriate for current screen.
  double scale(double size) => size * _scaleFactor;

  /// Scales width specifically based on screen width ratio.
  ///
  /// Parameters:
  /// - [width]: The original width from the design
  ///
  /// Returns the scaled width.
  double scaleWidth(double width) => width * (_screenWidth / designWidth);

  /// Scales height specifically based on screen height ratio.
  ///
  /// Parameters:
  /// - [height]: The original height from the design
  ///
  /// Returns the scaled height.
  double scaleHeight(double height) => height * (_screenHeight / designHeight);

  /// Scales font size with readability constraints.
  ///
  /// Parameters:
  /// - [fontSize]: The original font size from the design
  ///
  /// Returns the scaled font size, limited for readability.
  double scaleFontSize(double fontSize) => fontSize * _textScaleFactor;

  /// Scales border radius for rounded corners.
  ///
  /// Parameters:
  /// - [radius]: The original radius from the design
  ///
  /// Returns the scaled radius.
  double scaleRadius(double radius) => radius * _scaleFactor;

  /// Scales padding/margin with all directional values.
  ///
  /// Parameters:
  /// - [padding]: The original EdgeInsets from the design
  ///
  /// Returns scaled EdgeInsets for the current screen.
  EdgeInsets scalePadding(EdgeInsets padding) {
    return EdgeInsets.fromLTRB(
      scale(padding.left),
      scale(padding.top),
      scale(padding.right),
      scale(padding.bottom),
    );
  }

  /// Scales symmetric padding (horizontal and vertical).
  ///
  /// Parameters:
  /// - [horizontal]: The horizontal padding value
  /// - [vertical]: The vertical padding value
  ///
  /// Returns scaled symmetric EdgeInsets.
  EdgeInsets scaleSymmetricPadding(double horizontal, double vertical) {
    return EdgeInsets.symmetric(
      horizontal: scale(horizontal),
      vertical: scale(vertical),
    );
  }

  // ==================== Device Type Detection ====================

  /// Returns true if the device is a mobile phone (width < 600px)
  bool get isMobile => _screenWidth < 600;

  /// Returns true if the device is a tablet (600px <= width < 1200px)
  bool get isTablet => _screenWidth >= 600 && _screenWidth < 1200;

  /// Returns true if the device is a desktop (width >= 1200px)
  bool get isDesktop => _screenWidth >= 1200;

  /// Returns true if the device is in portrait orientation
  bool get isPortrait => _screenHeight > _screenWidth;

  /// Returns true if the device is in landscape orientation
  bool get isLandscape => _screenWidth > _screenHeight;

  // ==================== Advanced Scaling Methods ====================

  /// Scales a size with optional minimum and maximum constraints.
  ///
  /// Parameters:
  /// - [size]: The original size to scale
  /// - [min]: Optional minimum value (no minimum if null)
  /// - [max]: Optional maximum value (no maximum if null)
  ///
  /// Returns the scaled size constrained within min/max bounds.
  double scaleWithConstraints(double size, {double? min, double? max}) {
    double scaled = scale(size);
    if (min != null && scaled < min) return min;
    if (max != null && scaled > max) return max;
    return scaled;
  }

  /// Calculates responsive marble radius based on screen size and count.
  ///
  /// Parameters:
  /// - [marbleCount]: The number of marbles to display
  ///
  /// Returns an appropriate radius that ensures marbles fit well
  /// and remain readable regardless of count.
  double getMarbleRadius(int marbleCount) {
    double baseRadius;

    // Determine base radius based on marble count
    if (marbleCount <= 18) {
      baseRadius = 15.0;
    } else if (marbleCount <= 24) {
      baseRadius = 12.0;
    } else {
      baseRadius = 10.0;
    }

    // Scale but ensure minimum readable size
    return scaleWithConstraints(baseRadius, min: 8.0, max: 20.0);
  }

  /// Returns responsive card dimensions.
  ///
  /// Returns a [Size] object with width and height appropriate
  /// for the current screen size.
  Size getCardSize() {
    final double width = scaleWithConstraints(60, min: 45, max: 80);
    final double height = scaleWithConstraints(120, min: 90, max: 160);
    return Size(width, height);
  }

  /// Returns responsive game area dimensions.
  ///
  /// Accounts for screen padding to calculate available game space.
  Size getGameAreaSize() {
    return Size(_screenWidth - scale(32), _screenHeight - scale(72));
  }
}

// ==================== Extension Methods ====================

/// Extension to easily access ResponsiveUtils from BuildContext.
///
/// Usage: `context.responsive.scale(100)`
extension ResponsiveExtension on BuildContext {
  /// Returns a ResponsiveUtils instance for this context
  ResponsiveUtils get responsive => ResponsiveUtils(this);
}
