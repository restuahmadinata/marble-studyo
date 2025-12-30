import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:get/get.dart';
import '../game/marble_game.dart';
import '../game/controllers/game_controller.dart';
import '../game/components/question_card.dart';
import '../game/components/instruction_card.dart';
import '../../utils/responsive_utils.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController controller;
  late MarbleGame game;

  @override
  void initState() {
    super.initState();
    controller = Get.put(GameController());
  }

  MarbleGame _createGame(BuildContext context) {
    return MarbleGame(
      marbleCount: controller.marbleCount,
      divider: controller.divider.value,
      screenSize: MediaQuery.of(context).size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    
    // Initialize game on first build
    if (!controller.isGameInitialized) {
      game = _createGame(context);
      controller.gameInstance = game;
      controller.isGameInitialized = true;

      // Listen to reset changes
      ever(controller.shouldResetGame, (shouldReset) {
        if (shouldReset) {
          setState(() {
            game = _createGame(context);
            controller.gameInstance = game;
          });
        }
      });
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFE1BEE7),
      body: SafeArea(
        child: Stack(
          children: [
            // Layer 1: Game Engine dengan Container Boundary
            Padding(
              padding: responsive.scaleSymmetricPadding(16.0, 36.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.purple.shade300,
                    width: responsive.scale(3.0),
                  ),
                  borderRadius: BorderRadius.circular(responsive.scaleRadius(40)),
                  color: const Color(0xFFE1BEE7),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB34FB4),
                      offset: Offset(responsive.scale(4), responsive.scale(4)),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const InstructionCard(
                      instruction: "Find the result of the division",
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(responsive.scaleRadius(17)),
                      clipBehavior: Clip.none,
                      child: GameWidget(
                        key: ValueKey(controller.marbleCount),
                        game: game,
                      ),
                    ),
                    const QuestionEqualsCard(),
                  ],
                ),
              ),
            ),
            // Standalone Check Answer Button
            Positioned(
              bottom: responsive.scale(20),
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => controller.checkAnswer(),
                  child: Container(
                    width: responsive.scaleWidth(300),
                    height: responsive.scaleHeight(60),
                    decoration: BoxDecoration(
                      color: const Color(0xFF83E4B8),
                      borderRadius: BorderRadius.circular(responsive.scaleRadius(30)),
                      border: Border.all(
                        color: const Color(0xFF5FB592),
                        width: responsive.scale(3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5FB592),
                          offset: Offset(responsive.scale(6), responsive.scale(6)),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Check Answer',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: responsive.scaleFontSize(18),
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
