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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GameScreen(), // Langsung buka layar game
    );
  }
}
