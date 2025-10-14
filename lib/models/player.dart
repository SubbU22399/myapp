import 'package:flutter/material.dart';

// Represents a player in the game.
class Player {
  // The color associated with the player.
  final Color color;
  // The name of the player.
  final String name;
  // The current positions of the player's pieces.
  List<List<int>> pieces;
  // The index of the player's home base.
  final int homeIndex;
  // The number of pieces that have reached the flag.
  int finished;
  // The number of cosmic boosts the player has.
  int cosmicBoosts;
  // The player's score.
  int score;

  Player({
    required this.color,
    required this.name,
    required this.pieces,
    required this.homeIndex,
    this.finished = 0,
    this.cosmicBoosts = 3,
    this.score = 0,
  });
}
