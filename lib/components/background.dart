import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BackgroundGrid extends Component {
  double cellSize = 0;
  int gridSize = 0;
  Offset boardOffset = Offset.zero;

  void onResize(double cellSize, int gridSize, Offset boardOffset) {
    this.cellSize = cellSize;
    this.gridSize = gridSize;
    this.boardOffset = boardOffset;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint();

    // Loop through each tile in the grid and alternate colors for the checkerboard effect
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        // Alternate colors for a shaded effect
        paint.color =
            (row + col) % 2 == 0 ? Colors.blueGrey[700]! : Colors.grey[800]!;

        // Calculate position of the tile
        final rect = Rect.fromLTWH(
          boardOffset.dx + col * cellSize,
          boardOffset.dy + row * cellSize,
          cellSize - 1,
          cellSize - 1,
        );

        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  void update(double dt) {
    // No update logic needed for the static background
  }
}
