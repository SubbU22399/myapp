import 'dart:math';
import 'package:flutter/material.dart';

// A widget that represents an animal piece on the game board.
class AnimalPiece extends StatelessWidget {
  // The home index of the player, used to determine the animal type.
  final int homeIndex;
  // The animation that controls the piece's movement and effects.
  final Animation<double> animation;

  const AnimalPiece({super.key, required this.homeIndex, required this.animation});

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to get the constraints of the parent widget and make the piece responsive.
    return LayoutBuilder(builder: (context, constraints) {
      double size = min(constraints.maxWidth, constraints.maxHeight);
      // Returns a specific animal based on the home index.
      switch (homeIndex) {
        case 0: // Blue - Bird
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Colors.lightBlueAccent, Colors.blue]),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.6),
                  blurRadius: size * 0.3,
                ),
              ],
            ),
            child: Center(
              child: Text('🐦', style: TextStyle(fontSize: size * 0.6)),
            ),
          );
        case 1: // Yellow - Snake
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Colors.amber, Colors.yellow],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.6),
                  blurRadius: size * 0.3,
                ),
              ],
            ),
            child: Center(
              child: Text('🐍', style: TextStyle(fontSize: size * 0.6)),
            ),
          );
        case 2: // Red - Cat
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Colors.orange, Colors.red]),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.6),
                  blurRadius: size * 0.3,
                ),
              ],
            ),
            child: Center(
              child: Text('🐱', style: TextStyle(fontSize: size * 0.6)),
            ),
          );
        case 3: // Green - Frog
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Colors.lime, Colors.green]),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.6),
                  blurRadius: size * 0.3,
                ),
              ],
            ),
            child: Center(
              child: Text('🐸', style: TextStyle(fontSize: size * 0.6)),
            ),
          );
        default:
          return Container();
      }
    });
  }
}
