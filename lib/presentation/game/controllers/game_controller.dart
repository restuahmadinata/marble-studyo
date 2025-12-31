import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../marble_game.dart';
import '../components/marble_card.dart';
import '../../../utils/responsive_utils.dart';
import '../components/button.dart';

/// Controller for managing the marble grouping game state and logic.
///
/// This controller handles:
/// - Question generation and validation
/// - Game state management
/// - User feedback through dialogs
/// - Game resets and initialization
class GameController extends GetxController {
  // ==================== Observable State ====================

  /// The current question number (dividend in the division)
  var questionNumber = 24.obs;

  /// The divider number (divisor in the division)
  var divider = 3.obs;

  /// Flag to trigger game reset
  var shouldResetGame = false.obs;

  /// Flag to prevent reset button spam during animations
  var isResetting = false.obs;

  // ==================== Game Instance References ====================

  /// Reference to the current MarbleGame instance
  MarbleGame? gameInstance;

  /// Flag indicating if the game has been initialized
  bool isGameInitialized = false;

  // ==================== Lifecycle Methods ====================

  /// Initializes the controller and generates the first question.
  @override
  void onInit() {
    super.onInit();
    generateRandomQuestion();
  }

  // ==================== Question Management ====================

  /// Generates a new random division question.
  ///
  /// Selects a random multiple of 3 from 3 to 30 as the dividend.
  /// The divider remains 3 for consistent gameplay.
  void generateRandomQuestion() {
    const List<int> multiples = [3, 6, 9, 12, 15, 18, 21, 24, 27, 30];
    final random = Random();
    questionNumber.value = multiples[random.nextInt(multiples.length)];
  }

  /// Returns the formatted question text for display.
  String get questionText => '${questionNumber.value} ÷ ${divider.value}';

  /// Returns the total number of marbles to spawn.
  int get marbleCount => questionNumber.value;

  // ==================== Game Control Methods ====================

  /// Resets the game to a new question.
  ///
  /// Generates a new question and triggers the game's async reset animation.
  /// Prevents multiple resets from being triggered simultaneously.
  Future<void> resetGame() async {
    // Prevent reset spam
    if (isResetting.value) return;
    
    isResetting.value = true;
    generateRandomQuestion();

    // Call the game instance's async reset directly
    if (gameInstance != null) {
      // Update marble count first
      gameInstance!.marbleCount = questionNumber.value;
      // Trigger async reset with animations and wait for completion
      await gameInstance!.resetGame();
    }
    
    isResetting.value = false;
  }

  // ==================== Answer Validation ====================

  /// Checks if the player's marble placement is correct.
  ///
  /// Validates that:
  /// - Marbles have been placed on cards
  /// - Each card has the correct number of marbles
  /// - All cards have marbles placed
  void checkAnswer() {
    if (gameInstance == null) return;

    final cards = gameInstance!.children.whereType<NeoCard>().toList();

    // Check if any marbles have been placed
    if (gameInstance!.stuckGroups.isEmpty) {
      _showNoMarblesDialog();
      return;
    }

    final int expectedCount = questionNumber.value ~/ divider.value;
    final List<int> cardCounts = _getCardMarbleCounts(cards);

    // Validate all cards have correct marble counts
    if (_isAnswerCorrect(cardCounts, expectedCount, cards.length)) {
      _showSuccessDialog();
    } else {
      _showIncorrectCountDialog(expectedCount);
    }
  }

  /// Gets the marble count for each card.
  ///
  /// Parameters:
  /// - [cards]: List of NeoCard components to check
  ///
  /// Returns a list of marble counts, one for each card.
  List<int> _getCardMarbleCounts(List<NeoCard> cards) {
    final List<int> counts = [];

    for (final card in cards) {
      int count = 0;
      for (final groupEntry in gameInstance!.stuckGroups.entries) {
        if (groupEntry.value == card) {
          count = groupEntry.key.length;
          break;
        }
      }
      counts.add(count);
    }

    return counts;
  }

  /// Checks if the answer is correct based on marble counts.
  ///
  /// Parameters:
  /// - [cardCounts]: List of marble counts on each card
  /// - [expectedCount]: The expected number of marbles per card
  /// - [totalCards]: The total number of cards
  ///
  /// Returns true if all conditions are met for a correct answer.
  bool _isAnswerCorrect(
    List<int> cardCounts,
    int expectedCount,
    int totalCards,
  ) {
    final bool allCorrect = cardCounts.every((count) => count == expectedCount);
    final bool allFilled = cardCounts.every((count) => count > 0);
    final bool correctCardCount = totalCards == divider.value;

    return allCorrect && allFilled && correctCardCount;
  }

  // ==================== Dialog Methods ====================

  /// Shows a success dialog with encouraging messages.
  ///
  /// Displays random positive feedback and offers to play again.
  void _showSuccessDialog() {
    final dialogData = _getRandomSuccessMessage();

    Get.dialog(
      Builder(
        builder: (context) {
          final responsive = context.responsive;
          return _buildDialog(
            responsive: responsive,
            backgroundColor: const Color(0xFF3A8A68),
            borderColor: const Color(0xFF2D6B4F),
            iconPath: 'assets/icons/well-done.svg',
            title: dialogData['title']!,
            message: dialogData['message']!,
            buttonText: 'Play Again!',
            buttonColor: Colors.white,
            onButtonTap: () {
              Get.back();
              resetGame();
            },
          );
        },
      ),
    );
  }

  /// Shows a dialog when no marbles have been placed.
  void _showNoMarblesDialog() {
    final dialogData = _getRandomNoMarblesMessage();

    Get.dialog(
      Builder(
        builder: (context) {
          final responsive = context.responsive;
          return _buildDialog(
            responsive: responsive,
            backgroundColor: const Color(0xFF8A3333),
            borderColor: const Color(0xFF6B2424),
            iconPath: 'assets/icons/play.svg',
            title: dialogData['title']!,
            message: dialogData['message']!,
            buttonText: 'OK',
            buttonColor: Colors.white,
            onButtonTap: () => Get.back(),
          );
        },
      ),
    );
  }

  /// Shows a dialog for incorrect marble counts.
  ///
  /// Parameters:
  /// - [expectedCount]: The correct number of marbles per card
  void _showIncorrectCountDialog(int expectedCount) {
    final dialogData = _getRandomIncorrectMessage();

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
            child: _buildDialog(
              responsive: responsive,
              backgroundColor: const Color(0xFF8A3333),
              borderColor: const Color(0xFF6B2424),
              iconPath: 'assets/icons/not-yet.svg',
              title: dialogData['title']!,
              message: dialogData['message']!,
              buttonText: 'OK',
              buttonColor: Colors.white,
              onButtonTap: () => Get.back(),
            ),
          );
        },
      ),
    );
  }

  // ==================== Dialog Building Methods ====================

  /// Builds a styled dialog widget.
  ///
  /// Creates a consistent dialog design with customizable colors,
  /// icon, title, message, and button.
  Widget _buildDialog({
    required ResponsiveUtils responsive,
    required Color backgroundColor,
    required Color borderColor,
    required String iconPath,
    required String title,
    required String message,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onButtonTap,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.scaleRadius(12)),
        side: BorderSide(color: borderColor, width: responsive.scale(3)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(responsive.scaleRadius(12)),
          border: Border.all(color: borderColor, width: responsive.scale(3)),
          boxShadow: [
            BoxShadow(
              color: borderColor,
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
              iconPath,
              width: responsive.scale(64),
              height: responsive.scale(64),
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
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
              style: TextStyle(
                fontSize: responsive.scaleFontSize(16),
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.scale(24)),
            _buildDialogButton(
              responsive: responsive,
              text: buttonText,
              color: buttonColor,
              borderColor: borderColor,
              onTap: onButtonTap,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a styled button for dialogs with press animation.
  Widget _buildDialogButton({
    required ResponsiveUtils responsive,
    required String text,
    required Color color,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Button(
      text: text,
      color: color,
      borderColor: borderColor,
      textColor: Colors.black,
      onTap: onTap,
      responsive: responsive,
      horizontalPadding: 32,
      verticalPadding: 12,
    );
  }

  // ==================== Message Generation Methods ====================

  /// Gets a random success message for correct answers.
  Map<String, String> _getRandomSuccessMessage() {
    final List<String> titles = [
      'Awesome!',
      'Fantastic!',
      'Super!',
      'Amazing!',
      'Brilliant!',
      'Wonderful!',
      'Excellent!',
      'Perfect!',
    ];

    final List<String> messages = [
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
    return {
      'title': titles[random.nextInt(titles.length)],
      'message': messages[random.nextInt(messages.length)],
    };
  }

  /// Gets a random message for when no marbles are placed.
  Map<String, String> _getRandomNoMarblesMessage() {
    final List<String> titles = [
      'Oops!',
      'Hey there!',
      'Let\'s try!',
      'Almost!',
      'Ready?',
      'Time to play!',
    ];

    final List<String> messages = [
      'You need to place some marbles on the cards first!',
      'Let\'s put some marbles on the cards to get started!',
      'Try dragging marbles onto the colorful cards!',
      'Place your marbles on the cards to begin the game!',
      'Drag the marbles to the cards to start playing!',
      'Let\'s fill those cards with beautiful marbles!',
    ];

    final random = Random();
    return {
      'title': titles[random.nextInt(titles.length)],
      'message': messages[random.nextInt(messages.length)],
    };
  }

  /// Gets a random message for incorrect marble counts.
  Map<String, String> _getRandomIncorrectMessage() {
    final List<String> titles = [
      'Not quite!',
      'Almost there!',
      'Keep trying!',
      'Nice try!',
      'You\'re close!',
      'Let\'s fix it!',
      'Good effort!',
      'Try again!',
    ];

    final List<String> messages = [
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
    return {
      'title': titles[random.nextInt(titles.length)],
      'message': messages[random.nextInt(messages.length)],
    };
  }

  // ==================== Visual Feedback Methods ====================

  /// Triggers glint animation on cards with incorrect marble counts.
  ///
  /// Parameters:
  /// - [expectedCount]: The correct number of marbles per card
  void _glintIncorrectCards(int expectedCount) {
    if (gameInstance == null) return;

    final cards = gameInstance!.children.whereType<NeoCard>().toList();

    for (final card in cards) {
      final int count = _getCardMarbleCount(card);

      // Trigger glint animation if count is incorrect
      if (count != expectedCount) {
        card.startGlint();
      }
    }
  }

  /// Gets the marble count for a specific card.
  ///
  /// Parameters:
  /// - [card]: The NeoCard to check
  ///
  /// Returns the number of marbles on the card.
  int _getCardMarbleCount(NeoCard card) {
    for (final groupEntry in gameInstance!.stuckGroups.entries) {
      if (groupEntry.value == card) {
        return groupEntry.key.length;
      }
    }
    return 0;
  }
}
