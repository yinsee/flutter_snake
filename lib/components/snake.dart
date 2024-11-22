import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class SnakeEye extends PositionComponent {
  Vector2 relativeOffset = Vector2.zero();
  double radius = 0;

  @override
  void render(Canvas canvas) {
    final paint1 = Paint()..color = Colors.white;
    final paint2 = Paint()..color = Colors.black;
    canvas.drawCircle(
      Offset(radius / 2, radius / 2), // Center within the component bounds
      radius,
      paint1,
    );
    canvas.drawCircle(
      Offset(radius / 2, radius / 2), // Center within the component bounds
      radius / 2,
      paint2,
    );
  }

  void onResize(relativeOffset, cellSize) {
    this.relativeOffset = relativeOffset;
    radius = cellSize * 0.3;
  }

  void updatePosition(Vector2 headPosition, Offset boardOffset) {
    position = Vector2(
      boardOffset.dx + headPosition.x + relativeOffset.x,
      boardOffset.dy + headPosition.y + relativeOffset.y,
    );
  }
}

class Snake extends Component {
  double cellSize = 0;
  int gridSize = 0;
  Offset boardOffset = Offset.zero;

  List<Vector2> body = [];
  Vector2 direction = Vector2(1, 0); // Initial direction (right)
  int maxLength = 0;

  SnakeEye leftEye = SnakeEye();
  SnakeEye rightEye = SnakeEye();

  @override
  Future<void> onLoad() async {
    // Add eyes as children of the Snake component
    add(leftEye);
    add(rightEye);

    reset();
  }

  void onResize(double cellSize, int gridSize, Offset boardOffset) {
    this.cellSize = cellSize;
    this.gridSize = gridSize;
    this.boardOffset =
        boardOffset; // Resize and reposition eyes based on new cell size and board offset
    leftEye.onResize(Vector2(-cellSize * 0.2, -cellSize * 0.2), cellSize);
    rightEye.onResize(Vector2(cellSize * 0.2, -cellSize * 0.2), cellSize);
  }

  void reset() {
    body = [
      Vector2(gridSize / 2 + 1, gridSize / 2),
      Vector2(gridSize / 2, gridSize / 2),
      Vector2(gridSize / 2 - 1, gridSize / 2)
    ];
    maxLength = body.length;
    direction = Vector2(1, 0);
  }

  void changeDirection(Vector2 newDirection) {
    if ((newDirection.x != -direction.x) || (newDirection.y != -direction.y)) {
      direction = newDirection;
    }
  }

  void grow() {
    // Add a new segment at the last position in the body
    maxLength++;
  }

  void move() {
    // Move the snake's head in the current direction
    final newHead = body.first + direction;

    // Insert new head at the front of the body
    body.insert(0, newHead);

    // If snake has grown, we don't remove the last segment, otherwise, remove the last segment
    if (body.length > maxLength) {
      body.removeLast();
    }
  }

  bool collidesWithSelf() {
    return body.skip(1).contains(body.first);
  }

  bool collidesWithWalls(int gridSize) {
    final head = body.first;
    return head.x < 0 || head.x >= gridSize || head.y < 0 || head.y >= gridSize;
  }

  Vector2 get headPosition => body.first;

  @override
  void update(double dt) {
    // Update eye positions based on the direction and head position
    final headPosition = body.first * cellSize;

    // Adjust the eye offsets based on direction
    final eyeOffsetFactor = cellSize * 0.3;
    Offset eyeOffsetX = Offset(direction.y * eyeOffsetFactor, 0);
    Offset eyeOffsetY = Offset(0, direction.x * eyeOffsetFactor);

    leftEye.updatePosition(
      headPosition,
      boardOffset + eyeOffsetX - eyeOffsetY,
    );
    rightEye.updatePosition(
      headPosition,
      boardOffset + eyeOffsetX + eyeOffsetY,
    );
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.green;
    for (var segment in body) {
      final rect = Rect.fromLTWH(
        boardOffset.dx + segment.x * cellSize - 1,
        boardOffset.dy + segment.y * cellSize - 1,
        cellSize + 2,
        cellSize + 2,
      );
      canvas.drawRect(rect, paint);
    }
  }
}
