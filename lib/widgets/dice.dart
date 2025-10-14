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

  const Dice({super.key, required this.animation, required this.isRolling, required this.diceRoll});

  @override
  Widget build(BuildContext context) {
    // If the dice is rolling, display a random number, otherwise display the result.
    final rollValue = isRolling ? (Random().nextInt(6) + 1) : diceRoll;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform(
          // Creates a 3D rolling effect.
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.01)
            ..rotateX(animation.value * pi)
            ..rotateY(animation.value * pi / 2)
            ..rotateZ(animation.value * pi / 4),
          alignment: Alignment.center,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade300],
              ),
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(5, 5),
                ),
              ],
            ),
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
