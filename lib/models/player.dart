import 'package:flutter/material.dart';

/// Represents an immutable player in the game.
@immutable
class Player {
  // The color associated with the player.
  final Color color;
  // The name of the player.
  final String name;
  // The current positions of the player's pieces.
  final List<List<int>> pieces;
  // The index of the player's home base.
  final int homeIndex;
  // The number of pieces that have reached the flag.
  final int finished;
  // The number of cosmic boosts the player has.
  final int cosmicBoosts;
  // The player's score.
  final int score;

  const Player({
    required this.color,
    required this.name,
    required this.pieces,
    required this.homeIndex,
    this.finished = 0,
    this.cosmicBoosts = 3,
    this.score = 0,
  });

  /// Returns a new [Player] instance with the given fields updated.
  Player copyWith({
    Color? color,
    String? name,
    List<List<int>>? pieces,
    int? homeIndex,
    int? finished,
    int? cosmicBoosts,
    int? score,
  }) {
    return Player(
      color: color ?? this.color,
      name: name ?? this.name,
      pieces: pieces ?? this.pieces,
      homeIndex: homeIndex ?? this.homeIndex,
      finished: finished ?? this.finished,
      cosmicBoosts: cosmicBoosts ?? this.cosmicBoosts,
      score: score ?? this.score,
    );
  }
}
