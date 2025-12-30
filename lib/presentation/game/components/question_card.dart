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
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFF5a1d8c), width: 3),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7e4db8),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF5a1d8c), width: 3),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xFF5a1d8c),
                                      offset: Offset(6, 6),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Reset Game',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Are you sure you want to reset the game?',
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        GestureDetector(
                                          onTap: () => Navigator.of(context).pop(),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
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
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            controller.resetGame();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE5A882),
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
                                            child: const Text(
                                              'Reset',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
            left: 120,
            right: 120,
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
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    "=",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 52.0,
                      height: 0.1,
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
