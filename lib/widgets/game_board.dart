import 'package:flutter/material.dart';
import '../models/player.dart';
import '../utils/constants.dart';
import 'animal_piece.dart';

// A widget that represents the main game board.
class GameBoard extends StatelessWidget {
  // The list of players in the game.
  final List<Player> players;
  // The index of the current player.
  final int currentPlayer;
  // The animation for the animal pieces.
  final Animation<double> pieceAnimation;
  // A callback function that is called when a piece is tapped.
  final Function(int, int) onPieceTapped;

  const GameBoard({
    super.key,
    required this.players,
    required this.currentPlayer,
    required this.pieceAnimation,
    required this.onPieceTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Use AspectRatio to maintain the game board's square shape while fitting it into the available space.
    return AspectRatio(
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
          int x = index ~/ gridSize;
          int y = index % gridSize;
          // Determines if the current cell is a home, safe zone, or flag.
          bool isHome = homes.any((h) => h[0] == x && h[1] == y);
          bool isSafe = safeZones.any((s) => s[0] == x && s[1] == y);
          bool isFlag = x == flag[0] && y == flag[1];

          // Finds if there is a player piece in the current cell.
          int? playerIndex;
          int? pieceIndex;
          for (int p = 0; p < players.length; p++) {
            int idx = players[p].pieces.indexWhere((pos) => pos[0] == x && pos[1] == y);
            if (idx != -1) {
              playerIndex = p;
              pieceIndex = idx;
              break;
            }
          }

          return GestureDetector(
            onTap: () {
              // Calls the onPieceTapped callback if a piece is tapped.
              if (playerIndex != null && pieceIndex != null) {
                onPieceTapped(playerIndex, pieceIndex);
              }
            },
            // Styles the cell based on its type.
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isHome
                    ? players.firstWhere((p) => p.homeIndex == homes.indexWhere((h) => h[0] == x && h[1] == y)).color.withOpacity(0.3)
                    : isSafe
                        ? Colors.yellow.withOpacity(0.4)
                        : isFlag
                            ? Colors.purple.withOpacity(0.9)
                            : Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isFlag ? Colors.yellow : Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
                boxShadow: isFlag || isSafe
                    ? [
                        BoxShadow(
                          color: isFlag ? Colors.purple.withOpacity(0.5) : Colors.yellow.withOpacity(0.3),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                // Displays the animal piece if there is one in the cell.
                child: playerIndex != null
                    ? AnimalPiece(
                        homeIndex: players[playerIndex].homeIndex,
                        animation: pieceAnimation,
                      )
                    // Displays an icon for safe zones and the flag.
                    : Text(
                        isSafe
                            ? '✨'
                            : isFlag
                                ? '🌍'
                                : '',
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
