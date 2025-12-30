import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameController extends GetxController {
  // Observable state
  var questionNumber = 24.obs;
  var divider = 3.obs;
  var shouldResetGame = false.obs;

  @override
  void onInit() {
    super.onInit();
    generateRandomQuestion();
  }

  void generateRandomQuestion() {
    // Generate random multiple of 3 from 3 to 30
    final multiples = [3, 6, 9, 12, 15, 18, 21, 24, 27, 30];
    final random = Random();
    questionNumber.value = multiples[random.nextInt(multiples.length)];
  }

  String get questionText => '${questionNumber.value} ÷ ${divider.value}';

  int get marbleCount => questionNumber.value;

  void resetGame() {
    generateRandomQuestion();
    shouldResetGame.value = true;
    // Reset the flag after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      shouldResetGame.value = false;
    });
  }

  void checkAnswer() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF5FB592), width: 3),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF83E4B8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF5FB592), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF5FB592),
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
                'Answer Checked!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This is a dummy dialog. Your answer checking logic will go here.',
                style: TextStyle(fontSize: 16, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF5FB592), width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF5FB592),
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Text(
                    'OK',
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
        ),
      ),
    );
  }
}
