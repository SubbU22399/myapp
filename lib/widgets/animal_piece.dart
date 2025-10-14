import 'dart:math';
import 'package:flutter/material.dart';

// A widget that represents an animated animal piece on the game board.
class AnimalPiece extends StatelessWidget {
  // The home index of the player, used to determine the animal type.
  final int homeIndex;
  // The animation that controls the piece's movement and effects.
  final Animation<double> animation;

  const AnimalPiece({super.key, required this.homeIndex, required this.animation});

  @override
  Widget build(BuildContext context) {
    // Returns a specific animated animal based on the home index.
    switch (homeIndex) {
      case 0: // Blue - Bird
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.translate(
              // Creates a bouncing effect.
              offset: Offset(0, -sin(animation.value * 2 * pi) * 15),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Colors.blue, Colors.cyan]),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🐦', style: TextStyle(fontSize: 20)),
                ),
              ),
            );
          },
        );
      case 1: // Yellow - Snake
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.translate(
              // Creates a slithering effect.
              offset: Offset(sin(animation.value * 2 * pi) * 10, 0),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Colors.yellow, Colors.amber],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🐍', style: TextStyle(fontSize: 20)),
                ),
              ),
            );
          },
        );
      case 2: // Red - Cat
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              // Creates a pulsing effect.
              scale: 1 + sin(animation.value * pi) * 0.4,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Colors.red, Colors.orange]),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🐱', style: TextStyle(fontSize: 20)),
                ),
              ),
            );
          },
        );
      case 3: // Green - Frog
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.translate(
              // Creates a hopping effect.
              offset: Offset(0, -sin(animation.value * pi) * 20),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Colors.green, Colors.lime]),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🐸', style: TextStyle(fontSize: 20)),
                ),
              ),
            );
          },
        );
      default:
        return Container();
    }
  }
}
