
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
    return LayoutBuilder(builder: (context, constraints) {
      double size = min(constraints.maxWidth, constraints.maxHeight);

      // If the available space is unconstrained or too small, provide a sensible default size.
      if (size.isInfinite || size < 40) {
        size = 60.0;
      }
      // We also cap the maximum size to prevent it from being too large on wide screens.
      size = min(size, 80.0);

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
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Add perspective to the transformation.
              ..rotateX(animation.value * pi) // Rotate around the X-axis.
              ..rotateY(animation.value * pi / 2) // Rotate around the Y-axis.
              ..rotateZ(animation.value * pi / 4), // Rotate around the Z-axis.
            alignment: Alignment.center,
            // The visual representation of the dice.
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                // Add a gradient for a more realistic look.
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.grey.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                // Add a border to the dice.
                border: Border.all(color: Colors.black, width: size * 0.025),
                // Round the corners of the dice.
                borderRadius: BorderRadius.circular(size * 0.2),
                // Add a shadow for a 3D effect.
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: size * 0.13,
                    offset: Offset(size * 0.07, size * 0.07),
                  ),
                ],
              ),
              // Center the dice roll number.
              child: Center(
                child: _DiceFace(rollValue, size: size * 0.8),
              ),
            ),
          );
        },
      );
    });
  }
}

class _DiceFace extends StatelessWidget {
  final int value;
  final double size;

  const _DiceFace(this.value, {required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: switch (value) {
        1 => _DiceDot(count: 1, size: size),
        2 => _DiceDot(count: 2, size: size),
        3 => _DiceDot(count: 3, size: size),
        4 => _DiceDot(count: 4, size: size),
        5 => _DiceDot(count: 5, size: size),
        6 => _DiceDot(count: 6, size: size),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _DiceDot extends StatelessWidget {
  final int count;
  final double size;

  const _DiceDot({required this.count, required this.size});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: size * 0.1,
      crossAxisSpacing: size * 0.1,
      children: List.generate(9, (index) {
        return _buildDot(index);
      }),
    );
  }

  Widget _buildDot(int index) {
    final bool isVisible;
    switch (count) {
      case 1:
        isVisible = index == 4;
        break;
      case 2:
        isVisible = index == 0 || index == 8;
        break;
      case 3:
        isVisible = index == 0 || index == 4 || index == 8;
        break;
      case 4:
        isVisible = index == 0 || index == 2 || index == 6 || index == 8;
        break;
      case 5:
        isVisible =
            index == 0 || index == 2 || index == 4 || index == 6 || index == 8;
        break;
      case 6:
        isVisible =
            index == 0 || index == 2 || index == 3 || index == 5 || index == 6 || index == 8;
        break;
      default:
        isVisible = false;
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isVisible ? Colors.black : Colors.transparent,
      ),
    );
  }
}
