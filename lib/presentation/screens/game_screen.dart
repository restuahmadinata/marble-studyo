import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:get/get.dart';
import '../game/marble_game.dart';
import '../game/controllers/game_controller.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController controller = Get.put(GameController());
    
    return Scaffold(
      backgroundColor: const Color(0xFFE1BEE7),
      body: SafeArea(
        child: Stack(
          children: [
            // Layer 1: Game Engine dengan Container Boundary
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 36.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.purple.shade300, width: 3.0),
                  borderRadius: BorderRadius.circular(40),
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
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildInstructionCard(),
                    _buildQuestionCard(question: "24 ÷ 3"),
                    _buildEqualsCard(),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      clipBehavior: Clip.none,
                      child: GameWidget(game: MarbleGame()),
                    ),
                  ],
                ),
              ),
            ),
            // Standalone Check Answer Button
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => controller.checkAnswer(),
                  child: Container(
                    width: 300,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF83E4B8),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFF5FB592), // Darker version
                        width: 3,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF5FB592), // Darker version for shadow
                          offset: Offset(6, 6),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Check Answer',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Card(
        color: const Color(0xFFB34FB4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Find the result of the division",
            style: TextStyle(color: Colors.white, fontSize: 18.0),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard({required String question}) {
    return Positioned(
      top: 102,
      left: 32,
      right: 32,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF7e4db8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF5a1d8c), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF5a1d8c),
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Text(
          question,
          style: const TextStyle(color: Colors.white, fontSize: 52.0),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildEqualsCard() {
    return Positioned(
      top: 190,
      left: 100,
      right: 100,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF561f96),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF32015f),
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        padding: EdgeInsets.zero,
        child: const SizedBox(
          height: 40,
          child: Center(
            child: Text(
              "=",
              style: TextStyle(
                color: Colors.white,
                fontSize: 52.0,
                height: 0.7,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
