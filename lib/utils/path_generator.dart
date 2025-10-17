
/// Generates the spiral path for the game board.
List<List<int>> generateSpiralPath(int gridSize) {
  final path = <List<int>>[];
  var x = 0, y = 0;
  var dx = 1, dy = 0;
  var i = 0;
  final totalCells = gridSize * gridSize;

  while (i < totalCells) {
    path.add([x + gridSize ~/ 2, y + gridSize ~/ 2]);
    i++;

    if (x == y || (x < 0 && x == -y) || (x > 0 && x == 1 - y)) {
      final temp = dx;
      dx = -dy;
      dy = temp;
    }

    x += dx;
    y += dy;
  }

  return path;
}
