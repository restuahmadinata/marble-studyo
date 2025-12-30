import 'package:flutter/material.dart';
import 'dart:math' as math;

class ResponsiveUtils {
  final BuildContext context;
  late final Size _screenSize;
  late final double _screenWidth;
  late final double _screenHeight;
  late final double _scaleFactor;
  late final double _textScaleFactor;

  // Design reference dimensions (based on your current layout)
  static const double designWidth = 430.0;
  static const double designHeight = 932.0;

  ResponsiveUtils(this.context) {
    _screenSize = MediaQuery.of(context).size;
    _screenWidth = _screenSize.width;
    _screenHeight = _screenSize.height;
    
    // Calculate scale factor based on screen size
    double widthScale = _screenWidth / designWidth;
    double heightScale = _screenHeight / designHeight;
    
    // Use the smaller scale to ensure content fits
    _scaleFactor = math.min(widthScale, heightScale);
    
    // Calculate text scale with limits to maintain readability
    _textScaleFactor = math.max(0.7, math.min(_scaleFactor, 1.5));
  }

  // Getters for screen dimensions
  double get screenWidth => _screenWidth;
  double get screenHeight => _screenHeight;
  double get scaleFactor => _scaleFactor;

  // Scale dimensions proportionally
  double scale(double size) => size * _scaleFactor;
  
  // Scale width specifically
  double scaleWidth(double width) => width * (_screenWidth / designWidth);
  
  // Scale height specifically
  double scaleHeight(double height) => height * (_screenHeight / designHeight);
  
  // Scale font size
  double scaleFontSize(double fontSize) => fontSize * _textScaleFactor;
  
  // Scale radius
  double scaleRadius(double radius) => radius * _scaleFactor;
  
  // Scale padding/margin
  EdgeInsets scalePadding(EdgeInsets padding) {
    return EdgeInsets.fromLTRB(
      scale(padding.left),
      scale(padding.top),
      scale(padding.right),
      scale(padding.bottom),
    );
  }

  EdgeInsets scaleSymmetricPadding(double horizontal, double vertical) {
    return EdgeInsets.symmetric(
      horizontal: scale(horizontal),
      vertical: scale(vertical),
    );
  }

  // Device type detection
  bool get isMobile => _screenWidth < 600;
  bool get isTablet => _screenWidth >= 600 && _screenWidth < 1200;
  bool get isDesktop => _screenWidth >= 1200;
  
  // Orientation
  bool get isPortrait => _screenHeight > _screenWidth;
  bool get isLandscape => _screenWidth > _screenHeight;

  // Safe scaling with min/max constraints
  double scaleWithConstraints(double size, {double? min, double? max}) {
    double scaled = scale(size);
    if (min != null && scaled < min) return min;
    if (max != null && scaled > max) return max;
    return scaled;
  }

  // Get responsive marble radius based on screen size and marble count
  double getMarbleRadius(int marbleCount) {
    double baseRadius;
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

  // Get responsive card dimensions
  Size getCardSize() {
    double width = scaleWithConstraints(60, min: 45, max: 80);
    double height = scaleWithConstraints(120, min: 90, max: 160);
    return Size(width, height);
  }

  // Get responsive game area dimensions
  Size getGameAreaSize() {
    return Size(
      _screenWidth - scale(32), // Account for padding
      _screenHeight - scale(72), // Account for padding
    );
  }
}

// Extension for easy access to responsive utils
extension ResponsiveExtension on BuildContext {
  ResponsiveUtils get responsive => ResponsiveUtils(this);
}
