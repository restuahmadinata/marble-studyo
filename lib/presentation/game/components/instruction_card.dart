import 'package:flutter/material.dart';

class InstructionCard extends StatelessWidget {
  final String instruction;

  const InstructionCard({super.key, required this.instruction});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Card(
        color: const Color(0xFFB34FB4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            instruction,
            style: const TextStyle(color: Colors.white, fontSize: 18.0),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
