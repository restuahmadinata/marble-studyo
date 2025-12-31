import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:get/get.dart';
import '../game/marble_game.dart';
import '../game/controllers/game_controller.dart';
import '../game/components/question_card.dart';
import '../game/components/instruction_card.dart';
import '../game/components/button.dart';
import '../../utils/responsive_utils.dart';

/// The main game screen widget that hosts the marble grouping game.
///
/// This screen sets up the game environment and manages the lifecycle
/// of the Flame game engine. It includes the game canvas, UI overlays,
/// and a check answer button.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

/// State class for GameScreen managing game initialization and rebuilds.
class _GameScreenState extends State<GameScreen> {
  // ==================== Private Properties ====================

  /// Controller for managing game state and logic
  late GameController controller;

  /// The Flame game instance
  late MarbleGame game;

  // ==================== Lifecycle Methods ====================

  /// Initializes the game controller when the widget is first created.
  @override
  void initState() {
    super.initState();
    controller = Get.put(GameController());
  }

  /// Creates a new instance of MarbleGame with current settings.
  ///
  /// Parameters:
  /// - [context]: Build context for accessing screen size
  ///
  /// Returns a new MarbleGame configured with current marble count,
  /// divider, and screen dimensions.
  MarbleGame _createGame(BuildContext context) {
    return MarbleGame(
      marbleCount: controller.marbleCount,
      divider: controller.divider.value,
      screenSize: MediaQuery.of(context).size,
    );
  }

  // ==================== Build Methods ====================

  /// Builds the game screen UI with all components.
  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    // Initialize game on first build
    _initializeGameIfNeeded(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE1BEE7),
      body: SafeArea(
        child: Stack(
          children: [
            _buildGameContainer(responsive),
            _buildCheckAnswerButton(responsive),
          ],
        ),
      ),
    );
  }

  /// Initializes the game instance if not already initialized.
  ///
  /// Sets up the game and listens for reset events to recreate
  /// the game when needed.
  void _initializeGameIfNeeded(BuildContext context) {
    if (!controller.isGameInitialized) {
      game = _createGame(context);
      controller.gameInstance = game;
      controller.isGameInitialized = true;

      // Listen to reset changes and recreate game when needed
      ever(controller.shouldResetGame, (shouldReset) {
        if (shouldReset) {
          setState(() {
            game = _createGame(context);
            controller.gameInstance = game;
          });
        }
      });
    }
  }

  /// Builds the game container with boundary and UI overlays.
  ///
  /// Creates a purple-bordered container that holds the Flame game
  /// canvas along with instruction and question cards.
  Widget _buildGameContainer(ResponsiveUtils responsive) {
    return Padding(
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
    );
  }

  /// Builds the check answer button at the bottom of the screen.
  ///
  /// Creates a styled button with press animation that triggers answer
  /// validation when tapped.
  Widget _buildCheckAnswerButton(ResponsiveUtils responsive) {
    return Positioned(
      bottom: responsive.scale(20),
      left: 0,
      right: 0,
      child: Center(
        child: _CheckAnswerButton(
          responsive: responsive,
          onTap: () => controller.checkAnswer(),
        ),
      ),
    );
  }
}

/// A custom check answer button with press animation.
///
/// This widget wraps the Button to provide
/// the correct sizing and styling for the check answer button.
class _CheckAnswerButton extends StatelessWidget {
  /// The responsive utilities for scaling
  final ResponsiveUtils responsive;

  /// The callback function when the button is tapped
  final VoidCallback onTap;

  const _CheckAnswerButton({required this.responsive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Button(
      text: 'Check Answer',
      color: const Color(0xFF83E4B8),
      borderColor: const Color(0xFF5FB592),
      textColor: Colors.black,
      onTap: onTap,
      responsive: responsive,
      horizontalPadding: 100,
      verticalPadding: 18,
      borderRadius: 30,
    );
  }
}
