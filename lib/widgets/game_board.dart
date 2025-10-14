import 'package:flutter/material.dart';
import '../models/player.dart';
import '../utils/constants.dart';
import 'game_cell.dart';

/// A widget that represents the main game board.
class GameBoard extends StatelessWidget {
  // The list of players in the game.
  final List<Player> players;
  // The index of the current player.
  final int currentPlayerIndex;
  // The current roll of the dice.
  final int diceRoll;
  // A callback function that is called when a piece is tapped.
  final Function(int, int) onPieceTapped;

  const GameBoard({
    super.key,
    required this.players,
    required this.currentPlayerIndex,
    required this.diceRoll,
    required this.onPieceTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Use FractionallySizedBox to constrain the game board's size.
    return FractionallySizedBox(
      widthFactor: 0.5,
      child: AspectRatio(
        aspectRatio: 1,
        // Creates a grid view for the game board.
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,
            childAspectRatio: 1,
          ),
          itemCount: gridSize * gridSize,
          itemBuilder: (context, index) {
            final x = index ~/ gridSize;
            final y = index % gridSize;

            return GameCell(
              x: x,
              y: y,
              players: players,
              currentPlayerIndex: currentPlayerIndex,
              diceRoll: diceRoll,
              onPieceTapped: onPieceTapped,
            );
          },
        ),
      ),
    );
  }
}
