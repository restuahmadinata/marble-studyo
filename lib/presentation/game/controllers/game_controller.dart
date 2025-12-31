import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../marble_game.dart';
import '../components/marble_card.dart';
import '../../../utils/responsive_utils.dart';

class GameController extends GetxController {
  // Observable state
  var questionNumber = 24.obs;
  var divider = 3.obs;
  var shouldResetGame = false.obs;

  // Reference to the game instance
  MarbleGame? gameInstance;
  bool isGameInitialized = false;

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
      Builder(
        builder: (context) {
          final responsive = context.responsive;
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.scaleRadius(12)),
              side: BorderSide(color: const Color(0xFF2D6B4F), width: responsive.scale(3)),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3A8A68),
                borderRadius: BorderRadius.circular(responsive.scaleRadius(12)),
                border: Border.all(color: const Color(0xFF2D6B4F), width: responsive.scale(3)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D6B4F),
                    offset: Offset(responsive.scale(6), responsive.scale(6)),
                    blurRadius: 0,
                  ),
                ],
              ),
              padding: responsive.scalePadding(const EdgeInsets.all(24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/well-done.svg',
                    width: responsive.scale(64),
                    height: responsive.scale(64),
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                  SizedBox(height: responsive.scale(16)),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: responsive.scaleFontSize(24),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: responsive.scale(16)),
                  Text(
                    message,
                    style: TextStyle(fontSize: responsive.scaleFontSize(16), color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: responsive.scale(24)),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                      resetGame();
                    },
                    child: Container(
                      padding: responsive.scaleSymmetricPadding(32, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(responsive.scaleRadius(8)),
                        border: Border.all(
                          color: const Color(0xFF2D6B4F),
                          width: responsive.scale(2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2D6B4F),
                            offset: Offset(responsive.scale(4), responsive.scale(4)),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        'Play Again!',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: responsive.scaleFontSize(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
      Builder(
        builder: (context) {
          final responsive = context.responsive;
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.scaleRadius(12)),
              side: BorderSide(color: const Color(0xFF6B2424), width: responsive.scale(3)),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF8A3333),
                borderRadius: BorderRadius.circular(responsive.scaleRadius(12)),
                border: Border.all(color: const Color(0xFF6B2424), width: responsive.scale(3)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B2424),
                    offset: Offset(responsive.scale(6), responsive.scale(6)),
                    blurRadius: 0,
                  ),
                ],
              ),
              padding: responsive.scalePadding(const EdgeInsets.all(24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/play.svg',
                    width: responsive.scale(64),
                    height: responsive.scale(64),
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                  SizedBox(height: responsive.scale(16)),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: responsive.scaleFontSize(24),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: responsive.scale(16)),
                  Text(
                    message,
                    style: TextStyle(fontSize: responsive.scaleFontSize(16), color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: responsive.scale(24)),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      padding: responsive.scaleSymmetricPadding(32, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(responsive.scaleRadius(8)),
                        border: Border.all(
                          color: const Color(0xFF6B2424),
                          width: responsive.scale(2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B2424),
                            offset: Offset(responsive.scale(4), responsive.scale(4)),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: responsive.scaleFontSize(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
      barrierDismissible: true,
      Builder(
        builder: (context) {
          final responsive = context.responsive;
          return PopScope(
            canPop: true,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) {
                _glintIncorrectCards(expectedCount);
              }
            },
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.scaleRadius(12)),
                side: BorderSide(color: const Color(0xFF6B2424), width: responsive.scale(3)),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF8A3333),
                borderRadius: BorderRadius.circular(responsive.scaleRadius(12)),
                border: Border.all(color: const Color(0xFF6B2424), width: responsive.scale(3)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B2424),
                    offset: Offset(responsive.scale(6), responsive.scale(6)),
                    blurRadius: 0,
                  ),
                ],
              ),
              padding: responsive.scalePadding(const EdgeInsets.all(24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/not-yet.svg',
                    width: responsive.scale(64),
                    height: responsive.scale(64),
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                  SizedBox(height: responsive.scale(16)),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: responsive.scaleFontSize(24),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: responsive.scale(16)),
                  Text(
                    message,
                    style: TextStyle(fontSize: responsive.scaleFontSize(16), color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: responsive.scale(24)),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      padding: responsive.scaleSymmetricPadding(32, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(responsive.scaleRadius(8)),
                        border: Border.all(
                          color: const Color(0xFF6B2424),
                          width: responsive.scale(2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B2424),
                            offset: Offset(responsive.scale(4), responsive.scale(4)),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: responsive.scaleFontSize(16),
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
        },
      ),
    );
  }

  void _glintIncorrectCards(int expectedCount) {
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

      // Glint if count is incorrect
      if (count != expectedCount) {
        card.startGlint();
      }
    }
  }
}
