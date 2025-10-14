import 'package:flutter/material.dart';

/// A widget that represents an animal piece on the game board.
class AnimalPiece extends StatelessWidget {
  // The index of the player's home base.
  final int homeIndex;
  // A boolean to indicate if the piece is selectable.
  final bool isSelectable;

  const AnimalPiece({
    super.key,
    required this.homeIndex,
    this.isSelectable = false, // Default to not selectable
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

    return Container(
      decoration: isSelectable
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.8),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            )
          : null,
      child: Icon(
        animalIcons[homeIndex],
        color: animalColors[homeIndex],
        size: 30,
      ),
    );
  }
}
