import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'presentation/screens/game_screen.dart'; // Kita akan buat ini nanti

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan GetMaterialApp agar fitur GetX bisa jalan
    return GetMaterialApp(
      title: 'Marble Grouping',
      debugShowCheckedModeBanner: false, // Hilangkan banner debug
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SFProDisplay',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'SFProDisplay', fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontFamily: 'SFProDisplay', fontWeight: FontWeight.bold),
          displaySmall: TextStyle(fontFamily: 'SFProDisplay', fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(fontFamily: 'SFProDisplay', fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontFamily: 'SFProDisplay', fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontFamily: 'SFProDisplay', fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontFamily: 'SFProDisplay', fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontFamily: 'SFProDisplay', fontWeight: FontWeight.bold),
          titleSmall: TextStyle(fontFamily: 'SFProDisplay', fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontFamily: 'SFProDisplay', fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontFamily: 'SFProDisplay', fontWeight: FontWeight.bold),
          bodySmall: TextStyle(fontFamily: 'SFProDisplay', fontWeight: FontWeight.bold),
          labelLarge: TextStyle(fontFamily: 'SFProDisplay', fontWeight: FontWeight.bold),
          labelMedium: TextStyle(fontFamily: 'SFProDisplay', fontWeight: FontWeight.bold),
          labelSmall: TextStyle(fontFamily: 'SFProDisplay', fontWeight: FontWeight.bold),
        ),
      ),
      home: const GameScreen(), // Langsung buka layar game
    );
  }
}
