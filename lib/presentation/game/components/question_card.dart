import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../../../utils/responsive_utils.dart';

class QuestionEqualsCard extends StatelessWidget {
  const QuestionEqualsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController controller = Get.find<GameController>();
    final responsive = context.responsive;

    return Obx(
      () => Stack(
        children: [
          // Question Card
          Positioned(
            top: responsive.scale(102),
            left: responsive.scale(32),
            right: responsive.scale(32),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF7e4db8),
                borderRadius: BorderRadius.circular(responsive.scaleRadius(8)),
                border: Border.all(color: const Color(0xFF5a1d8c), width: responsive.scale(2)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5a1d8c),
                    offset: Offset(responsive.scale(4), responsive.scale(4)),
                    blurRadius: 0,
                  ),
                ],
              ),
              padding: EdgeInsets.all(responsive.scale(16.0)),
              child: Stack(
                children: [
                  // Question Text (centered)
                  Center(
                    child: Text(
                      controller.questionText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.scaleFontSize(52.0),
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
                      iconSize: responsive.scale(28),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            final dialogResponsive = dialogContext.responsive;
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(dialogResponsive.scaleRadius(12)),
                                side: BorderSide(color: const Color(0xFF5a1d8c), width: dialogResponsive.scale(3)),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7e4db8),
                                  borderRadius: BorderRadius.circular(dialogResponsive.scaleRadius(12)),
                                  border: Border.all(color: const Color(0xFF5a1d8c), width: dialogResponsive.scale(3)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF5a1d8c),
                                      offset: Offset(dialogResponsive.scale(6), dialogResponsive.scale(6)),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(dialogResponsive.scale(24)),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Reset Game',
                                      style: TextStyle(
                                        fontSize: dialogResponsive.scaleFontSize(24),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: dialogResponsive.scale(16)),
                                    Text(
                                      'Are you sure you want to reset the game?',
                                      style: TextStyle(fontSize: dialogResponsive.scaleFontSize(16), color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: dialogResponsive.scale(24)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        GestureDetector(
                                          onTap: () => Navigator.of(dialogContext).pop(),
                                          child: Container(
                                            padding: dialogResponsive.scaleSymmetricPadding(24, 12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(dialogResponsive.scaleRadius(8)),
                                              border: Border.all(color: const Color(0xFF5a1d8c), width: dialogResponsive.scale(2)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF5a1d8c),
                                                  offset: Offset(dialogResponsive.scale(4), dialogResponsive.scale(4)),
                                                  blurRadius: 0,
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: dialogResponsive.scaleFontSize(16),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(dialogContext).pop();
                                            controller.resetGame();
                                          },
                                          child: Container(
                                            padding: dialogResponsive.scaleSymmetricPadding(24, 12),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE5A882),
                                              borderRadius: BorderRadius.circular(dialogResponsive.scaleRadius(8)),
                                              border: Border.all(color: const Color(0xFF5a1d8c), width: dialogResponsive.scale(2)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF5a1d8c),
                                                  offset: Offset(dialogResponsive.scale(4), dialogResponsive.scale(4)),
                                                  blurRadius: 0,
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              'Reset',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: dialogResponsive.scaleFontSize(16),
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
            top: responsive.scale(190),
            left: responsive.scale(120),
            right: responsive.scale(120),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF561f96),
                borderRadius: BorderRadius.circular(responsive.scaleRadius(8)),
                border: Border.all(color: Colors.black, width: responsive.scale(2)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF32015f),
                    offset: Offset(responsive.scale(4), responsive.scale(4)),
                    blurRadius: 0,
                  ),
                ],
              ),
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: responsive.scale(40),
                child: Padding(
                  padding: EdgeInsets.only(top: responsive.scale(12)),
                  child: Text(
                    "=",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsive.scaleFontSize(52.0),
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
