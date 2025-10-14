import 'package:flutter/material.dart';

/// A widget that represents an animal piece on the game board.
class AnimalPiece extends StatelessWidget {
  // The index of the player's home base.
  final int homeIndex;
  // The animation for the piece.
  final Animation<double> animation;

  const AnimalPiece({
    super.key,
    required this.homeIndex,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    // A list of icons for the animal pieces.
    const List<IconData> animalIcons = [
      Icons.pets, // Bird for Blue
      Icons.audiotrack, // Cat for Red
    ];

    // A list of colors for the animal pieces.
    const List<Color> animalColors = [
      Colors.blue,
      Colors.red,
    ];

    return ScaleTransition(
      scale: animation,
      child: Icon(
        animalIcons[homeIndex],
        color: animalColors[homeIndex],
        size: 30,
      ),
    );
  }
}
