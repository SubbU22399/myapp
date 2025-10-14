import 'package:flutter/material.dart';
import '../models/player.dart';
import 'animal_piece.dart';

class StackedPieces extends StatelessWidget {
  final List<Map<String, int>> pieces;
  final List<Player> players;
  final Animation<double> pieceAnimation;

  const StackedPieces({
    super.key,
    required this.pieces,
    required this.players,
    required this.pieceAnimation,
  });

  @override
  Widget build(BuildContext context) {
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
