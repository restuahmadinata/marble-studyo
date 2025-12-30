import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../marble_game.dart';
import '../components/marble_card.dart';

class GameController extends GetxController {
  // Observable state
  var questionNumber = 24.obs;
  var divider = 3.obs;
  var shouldResetGame = false.obs;

  // Reference to the game instance
  MarbleGame? gameInstance;

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
    if (gameInstance == null) return;

    // Get all cards from the game
    final cards = gameInstance!.children.whereType<NeoCard>().toList();

    // Check if there are any stuck marbles
    if (gameInstance!.stuckGroups.isEmpty) {
      _showNoMarblesDialog();
      return;
    }

    // Calculate expected count per card
    int expectedCount = questionNumber.value ~/ divider.value;

    // Check marble counts on each card
    List<int> cardCounts = [];
    for (final card in cards) {
      int count = 0;
      for (final groupEntry in gameInstance!.stuckGroups.entries) {
        if (groupEntry.value == card) {
          count = groupEntry.key.length;
          break;
        }
      }
      cardCounts.add(count);
    }

    // Check if all cards have correct count
    bool allCardsHaveCorrectCount = cardCounts.every(
      (count) => count == expectedCount,
    );
    bool allCardsHaveMarbles = cardCounts.every((count) => count > 0);

    if (allCardsHaveCorrectCount &&
        allCardsHaveMarbles &&
        cards.length == divider.value) {
      // All cards have correct count - show success dialog
      _showSuccessDialog();
    } else {
      // Show incorrect count dialog
      _showIncorrectCountDialog(expectedCount);
    }
  }

  void _showSuccessDialog() {
    // Random success messages for kids
    final List<String> successTitles = [
      'Awesome!',
      'Fantastic!',
      'Super!',
      'Amazing!',
      'Brilliant!',
      'Wonderful!',
      'Excellent!',
      'Perfect!',
    ];

    final List<String> successMessages = [
      'You did it! All the marbles are in the right spots!',
      'Great job! Every marble found its perfect home!',
      'You\'re a marble master! All spots are filled correctly!',
      'Wow! You got all the marbles in the right places!',
      'Super star! Every card has just the right number!',
      'You\'re amazing! All marbles are perfectly placed!',
      'Brilliant work! Every spot is filled just right!',
      'Fantastic! You solved the marble puzzle perfectly!',
    ];

    final random = Random();
    final title = successTitles[random.nextInt(successTitles.length)];
    final message = successMessages[random.nextInt(successMessages.length)];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2D6B4F), width: 3),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF3A8A68),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2D6B4F), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF2D6B4F),
                offset: Offset(6, 6),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/well-done.svg',
                width: 64,
                height: 64,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Get.back();
                  resetGame();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF2D6B4F),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF2D6B4F),
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Text(
                    'Play Again!',
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

  void _showNoMarblesDialog() {
    // Random messages for when no marbles are placed
    final List<String> noMarblesTitles = [
      'Oops!',
      'Hey there!',
      'Let\'s try!',
      'Almost!',
      'Ready?',
      'Time to play!',
    ];

    final List<String> noMarblesMessages = [
      'You need to place some marbles on the cards first!',
      'Let\'s put some marbles on the cards to get started!',
      'Try dragging marbles onto the colorful cards!',
      'Place your marbles on the cards to begin the game!',
      'Drag the marbles to the cards to start playing!',
      'Let\'s fill those cards with beautiful marbles!',
    ];

    final random = Random();
    final title = noMarblesTitles[random.nextInt(noMarblesTitles.length)];
    final message = noMarblesMessages[random.nextInt(noMarblesMessages.length)];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF6B2424), width: 3),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF8A3333),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF6B2424), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF6B2424),
                offset: Offset(6, 6),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/play.svg',
                width: 64,
                height: 64,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF6B2424),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF6B2424),
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

  void _showIncorrectCountDialog(int expectedCount) {
    // Random messages for incorrect marble counts
    final List<String> incorrectTitles = [
      'Not quite!',
      'Almost there!',
      'Keep trying!',
      'Nice try!',
      'You\'re close!',
      'Let\'s fix it!',
      'Good effort!',
      'Try again!',
    ];

    final List<String> incorrectMessages = [
      'Some cards have incorrect amount of marbles!',
      'A few cards need different numbers of marbles!',
      'Let\'s check which cards need more or fewer marbles!',
      'Some cards don\'t have the right number of marbles yet!',
      'Look at the cards - some need different marble counts!',
      'Almost perfect! Some cards need marble adjustments!',
      'Great try! Let\'s fix the marble numbers on some cards!',
      'You\'re doing well! Some cards need marble count changes!',
    ];

    final random = Random();
    final title = incorrectTitles[random.nextInt(incorrectTitles.length)];
    final message = incorrectMessages[random.nextInt(incorrectMessages.length)];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF6B2424), width: 3),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF8A3333),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF6B2424), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF6B2424),
                offset: Offset(6, 6),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/not-yet.svg',
                width: 64,
                height: 64,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Get.back();
                  _pulseIncorrectCards(expectedCount);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF6B2424),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF6B2424),
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

  void _pulseIncorrectCards(int expectedCount) {
    if (gameInstance == null) return;

    final cards = gameInstance!.children.whereType<NeoCard>().toList();
    for (final card in cards) {
      // Count marbles on this card
      int count = 0;
      for (final groupEntry in gameInstance!.stuckGroups.entries) {
        if (groupEntry.value == card) {
          count = groupEntry.key.length;
          break;
        }
      }

      // Pulse if count is incorrect
      if (count != expectedCount) {
        card.startGlint();
      }
    }
  }
}
