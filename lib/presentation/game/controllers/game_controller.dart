import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameController extends GetxController {
  void checkAnswer() {
    Get.dialog(
      AlertDialog(
        title: const Text('Answer Checked!'),
        content: const Text('This is a dummy dialog. Your answer checking logic will go here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
