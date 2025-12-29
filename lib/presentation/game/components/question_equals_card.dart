import 'package:flutter/material.dart';

class QuestionEqualsCard extends StatelessWidget {
  final String question;

  const QuestionEqualsCard({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
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
            child: Text(
              question,
              style: const TextStyle(color: Colors.white, fontSize: 52.0),
              textAlign: TextAlign.center,
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
    );
  }
}
