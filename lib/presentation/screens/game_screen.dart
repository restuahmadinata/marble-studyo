import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/marble_game.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1BEE7),
      body: SafeArea(
        child: Stack(
          children: [
            // Layer 1: Game Engine dengan Container Boundary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 36.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.purple.shade300,
                    width: 3.0,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFFE1BEE7),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB34FB4),
                      offset: const Offset(4, 4),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: GameWidget(
                    game: MarbleGame(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}