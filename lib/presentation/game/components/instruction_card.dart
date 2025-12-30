import 'package:flutter/material.dart';
import '../../../utils/responsive_utils.dart';

class InstructionCard extends StatelessWidget {
  final String instruction;

  const InstructionCard({super.key, required this.instruction});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    
    return Positioned(
      top: responsive.scale(16),
      left: responsive.scale(16),
      right: responsive.scale(16),
      child: Card(
        color: const Color(0xFFB34FB4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsive.scaleRadius(50))),
        child: Padding(
          padding: responsive.scalePadding(const EdgeInsets.all(16.0)),
          child: Text(
            instruction,
            style: TextStyle(
              color: Colors.white,
              fontSize: responsive.scaleFontSize(18.0),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
