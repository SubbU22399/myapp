import 'path_generator.dart';

// The size of the game board grid.
const int gridSize = 7;
// The home positions for each player.
const List<List<int>> homes = [
  [6, 3], // Blue - Bird
  [0, 3], // Red - Cat
];
// The safe zones on the game board.
const List<List<int>> safeZones = [
  [1, 1],
  [1, 5],
  [5, 1],
  [5, 5],
  [2, 3],
  [3, 2],
  [3, 3],
  [4, 3],
  [3, 4],
];
// The position of the central flag.
const List<int> flag = [3, 3];

// The spiral paths for each player to follow.
final List<List<List<int>>> spiralPaths = _generatePaths();

// The positions of the pieces when they are out of play.
const List<List<List<int>>> outOfPlayPositions = [
  // Blue (bottom)
  [
    [7, 0],
    [7, 1],
    [7, 2],
    [7, 3],
  ],
  // Red (top)
  [
    [-1, 0],
    [-1, 1],
    [-1, 2],
    [-1, 3],
  ],
];

// Generates the spiral paths for all players.
List<List<List<int>>> _generatePaths() {
  final basePath = generateSpiralPath(gridSize);
  return List.generate(homes.length, (i) {
    final start = homes[i];
    final startIndex = basePath.indexWhere(
      (p) => p[0] == start[0] && p[1] == start[1],
    );
    return [
      ...basePath.sublist(startIndex),
      ...basePath.sublist(0, startIndex),
    ];
  });
}
