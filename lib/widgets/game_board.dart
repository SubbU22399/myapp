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
    // Use FractionallySizedBox to constrain the game board's size.
    return FractionallySizedBox(
      widthFactor: 0.9,
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
            int x = index ~/ gridSize;
            int y = index % gridSize;
            // Determines if the current cell is a home, safe zone, or flag.
            bool isHome = homes.any((h) => h[0] == x && h[1] == y);
            bool isSafe = safeZones.any((s) => s[0] == x && s[1] == y);
            bool isFlag = x == flag[0] && y == flag[1];

            // Finds all player pieces in the current cell.
            List<Map<String, int>> piecesInCell = [];
            for (int p = 0; p < players.length; p++) {
              for (int pieceIndex = 0; pieceIndex < players[p].pieces.length; pieceIndex++) {
                if (players[p].pieces[pieceIndex][0] == x && players[p].pieces[pieceIndex][1] == y) {
                  piecesInCell.add({'playerIndex': p, 'pieceIndex': pieceIndex});
                }
              }
            }
            
            Color getCellColor() {
              if (isHome) {
                int homeIndex = homes.indexWhere((h) => h[0] == x && h[1] == y);
                var activePlayersWithHome = players.where((p) => p.homeIndex == homeIndex);
                if (activePlayersWithHome.isNotEmpty) {
                  return activePlayersWithHome.first.color.withOpacity(0.3);
                }
                return Colors.black.withOpacity(0.2); // Inactive home color
              }
              if (isSafe) return Colors.yellow.withOpacity(0.4);
              if (isFlag) return Colors.purple.withOpacity(0.9);
              return Colors.black.withOpacity(0.2);
            }

            return GestureDetector(
              onTap: () {
                // Calls the onPieceTapped callback if a piece is tapped.
                if (piecesInCell.isNotEmpty) {
                  // If there are multiple pieces, you might want to let the user select one.
                  // For simplicity, we'll just use the first one.
                  onPieceTapped(piecesInCell[0]['playerIndex']!, piecesInCell[0]['pieceIndex']!);
                }
              },
              // Styles the cell based on its type.
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: getCellColor(),
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
                  // Displays the animal pieces if there are any in the cell.
                  child: piecesInCell.isNotEmpty
                      ? _buildStackedPieces(piecesInCell)
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
      ),
    );
  }

  Widget _buildStackedPieces(List<Map<String, int>> pieces) {
    if (pieces.isEmpty) return const SizedBox.shrink();
    if (pieces.length == 1) {
      return AnimalPiece(
        homeIndex: players[pieces[0]['playerIndex']!].homeIndex,
        animation: pieceAnimation,
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: List.generate(pieces.length, (i) {
        return Positioned(
          top: i * 5.0,
          left: i * 5.0,
          child: SizedBox(
            width: 30,
            height: 30,
            child: AnimalPiece(
              homeIndex: players[pieces[i]['playerIndex']!].homeIndex,
              animation: pieceAnimation,
            ),
          ),
        );
      }),
    );
  }
}