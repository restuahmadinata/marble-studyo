import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:get/get.dart';
import '../game/marble_game.dart';
import '../game/controllers/game_controller.dart';
import '../game/components/question_equals_card.dart';
import '../game/components/instruction_card.dart';

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
                    const InstructionCard(instruction: "Find the result of the division"),
                    const QuestionEqualsCard(question: "24 ÷ 3"),
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


}
