import 'package:flutter/material.dart';
import '../models/player.dart';
import '../utils/constants.dart';
import 'stacked_pieces.dart';

class GameCell extends StatelessWidget {
  final int x;
  final int y;
  final List<Player> players;
  final Animation<double> pieceAnimation;
  final Function(int, int) onPieceTapped;

  const GameCell({
    super.key,
    required this.x,
    required this.y,
    required this.players,
    required this.pieceAnimation,
    required this.onPieceTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isHome = homes.any((h) => h[0] == x && h[1] == y);
    final isSafe = safeZones.any((s) => s[0] == x && s[1] == y);
    final isFlag = x == flag[0] && y == flag[1];

    final piecesInCell = <Map<String, int>>[];
    for (var p = 0; p < players.length; p++) {
      for (var pieceIndex = 0; pieceIndex < players[p].pieces.length; pieceIndex++) {
        if (players[p].pieces[pieceIndex][0] == x &&
            players[p].pieces[pieceIndex][1] == y) {
          piecesInCell.add({
            'playerIndex': p,
            'pieceIndex': pieceIndex,
          });
        }
      }
    }

    return GestureDetector(
      onTap: () {
        if (piecesInCell.isNotEmpty) {
          onPieceTapped(
            piecesInCell[0]['playerIndex']!,
            piecesInCell[0]['pieceIndex']!,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _getCellColor(isHome, isSafe, isFlag),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isFlag ? Colors.yellow : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: isFlag || isSafe
              ? [
                  BoxShadow(
                    color: isFlag
                        ? Colors.purple.withOpacity(0.5)
                        : Colors.yellow.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: piecesInCell.isNotEmpty
              ? StackedPieces(
                  pieces: piecesInCell,
                  players: players,
                  pieceAnimation: pieceAnimation,
                )
              : Text(
                  isSafe
                      ? '✨'
                      : isFlag
                          ? '🌍'
                          : '',
                  style: const TextStyle(fontSize: 20),
                ),
        ),
      ),
    );
  }

  Color _getCellColor(bool isHome, bool isSafe, bool isFlag) {
    if (isHome) {
      final homeIndex = homes.indexWhere((h) => h[0] == x && h[1] == y);
      final activePlayer = players.firstWhere(
        (p) => p.homeIndex == homeIndex,
        orElse: () =>
            const Player(color: Colors.transparent, name: '', pieces: [], homeIndex: -1),
      );
      return activePlayer.color.withOpacity(0.3);
    }
    if (isSafe) return Colors.yellow.withOpacity(0.4);
    if (isFlag) return Colors.purple.withOpacity(0.9);
    return Colors.black.withOpacity(0.2);
  }
}
