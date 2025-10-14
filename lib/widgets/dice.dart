import 'dart:math';
import 'package:flutter/material.dart';

// A widget that represents the animated dice.
class Dice extends StatelessWidget {
  // The animation that controls the dice roll.
  final Animation<double> animation;
  // Whether the dice is currently rolling.
  final bool isRolling;
  // The result of the dice roll.
  final int diceRoll;

  // Constructor for the Dice widget.
  const Dice({
    super.key,
    required this.animation,
    required this.isRolling,
    required this.diceRoll,
  });

  @override
  Widget build(BuildContext context) {
    // If the dice is rolling, display a random number between 1 and 6,
    // otherwise display the actual dice roll result.
    final rollValue = isRolling ? (Random().nextInt(6) + 1) : diceRoll;
    // Use AnimatedBuilder to rebuild the widget when the animation value changes.
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Apply a 3D transformation to the dice container.
        return Transform(
          // Creates a 3D rolling effect on the dice.
          transform:
              Matrix4.identity()
                ..setEntry(3, 2, 0.01) // Add perspective to the transformation.
                ..rotateX(animation.value * pi) // Rotate around the X-axis.
                ..rotateY(animation.value * pi / 2) // Rotate around the Y-axis.
                ..rotateZ(
                  animation.value * pi / 4,
                ), // Rotate around the Z-axis.
          alignment: Alignment.center,
          // The visual representation of the dice.
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              // Add a gradient for a more realistic look.
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade300],
              ),
              // Add a border to the dice.
              border: Border.all(color: Colors.black, width: 2),
              // Round the corners of the dice.
              borderRadius: BorderRadius.circular(10),
              // Add a shadow for a 3D effect.
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(5, 5),
                ),
              ],
            ),
            // Center the dice roll number.
            child: Center(
              child: Text(
                rollValue.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
