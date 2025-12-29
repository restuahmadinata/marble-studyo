import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';

class QuestionEqualsCard extends StatelessWidget {
  const QuestionEqualsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController controller = Get.find<GameController>();

    return Obx(
      () => Stack(
        children: [
          // Question Card
          Positioned(
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
              child: Stack(
                children: [
                  // Question Text (centered)
                  Center(
                    child: Text(
                      controller.questionText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 52.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Reset Button (top right)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      iconSize: 28,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Reset Game'),
                              content: const Text(
                                'Are you sure you want to reset the game?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    controller.resetGame();
                                  },
                                  child: const Text('Reset'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Equals Card
          Positioned(
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
          ),
        ],
      ),
    );
  }
}
