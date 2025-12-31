import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'presentation/screens/game_screen.dart';

/// Entry point of the Marble Grouping application.
///
/// This function initializes and runs the main application widget.
void main() {
  runApp(const MyApp());
}

/// Root widget of the Marble Grouping application.
///
/// This widget sets up the app-wide configuration including:
/// - GetX state management integration
/// - Custom theme with SF Pro Display font
/// - Navigation setup
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Marble Grouping',
      debugShowCheckedModeBanner: false,
      theme: _buildAppTheme(),
      home: const GameScreen(),
    );
  }

  /// Builds the application theme with custom styling.
  ///
  /// Returns a [ThemeData] object with:
  /// - Primary color set to blue
  /// - SF Pro Display as the default font family
  /// - Bold font weight applied to all text styles
  ThemeData _buildAppTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      fontFamily: 'SFProDisplay',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'SFProDisplay',
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          fontFamily: 'SFProDisplay',
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          fontFamily: 'SFProDisplay',
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'SFProDisplay',
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'SFProDisplay',
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'SFProDisplay',
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          fontFamily: 'SFProDisplay',
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontFamily: 'SFProDisplay',
          fontWeight: FontWeight.bold,
        ),
        titleSmall: TextStyle(
          fontFamily: 'SFProDisplay',
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'SFProDisplay',
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'SFProDisplay',
          fontWeight: FontWeight.bold,
        ),
        bodySmall: TextStyle(
          fontFamily: 'SFProDisplay',
          fontWeight: FontWeight.bold,
        ),
        labelLarge: TextStyle(
          fontFamily: 'SFProDisplay',
          fontWeight: FontWeight.bold,
        ),
        labelMedium: TextStyle(
          fontFamily: 'SFProDisplay',
          fontWeight: FontWeight.bold,
        ),
        labelSmall: TextStyle(
          fontFamily: 'SFProDisplay',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
