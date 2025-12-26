import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/marble_game.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Layer 1: Game Engine (Paling bawah)
          GameWidget(
            game: MarbleGame(),
          ),
          
          // Layer 2: UI Overlay (Judul, Skor, Tombol) - Nanti kita isi
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Misi: Cari Kelompok 8!",
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}