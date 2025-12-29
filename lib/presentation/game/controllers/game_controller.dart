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
      AlertDialog(
        title: const Text('Answer Checked!'),
        content: const Text(
          'This is a dummy dialog. Your answer checking logic will go here.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }
}
