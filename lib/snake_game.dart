import 'dart:async';
import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snake_game/components/apple.dart';
import 'package:snake_game/components/background.dart';
import 'package:snake_game/components/snake.dart';

class SnakeGame extends FlameGame
    with
        HorizontalDragDetector,
        VerticalDragDetector,
        KeyboardEvents,
        TapDetector {
  SnakeGame({required this.gridSize, required this.speed});

  final int gridSize; // Constant grid size
  final int speed;
  late double cellSize; // Cell size dynamically calculated based on screen size
  late Offset boardOffset; // Offset to center the board on screen

  BackgroundGrid background = BackgroundGrid();
  Snake snake = Snake();
  Apple apple = Apple();

  int score = 0;
  bool gameOver = false;

  int elapsedTime = 0;
  double timeAccumulator = 0.0;
  Timer? _gameTimer; // Game timer

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Initialize Snake and Apple
    add(background);
    add(apple);
    add(snake);

    // Start the game loop with a fixed interval
    _startGameLoop();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Use the smaller dimension of the screen to calculate the cell size
    double availableSpace = min(size.x, size.y);

    // Calculate the cell size to fit the grid
    cellSize = availableSpace / gridSize;

    // Center the grid in both portrait and landscape modes
    boardOffset = Offset(
      (size.x - gridSize * cellSize) / 2, // Horizontal centering
      (size.y - gridSize * cellSize) / 2, // Vertical centering
    );

    // Pass updated cell size, grid size, and offset to components
    background.onResize(cellSize, gridSize, boardOffset);
    snake.onResize(cellSize, gridSize, boardOffset);
    apple.onResize(cellSize, gridSize, boardOffset);
  }

  void _startGameLoop() {
    _gameTimer?.cancel(); // Cancel existing timer if any

    // Start the game loop, update every second
    _gameTimer = Timer.periodic(Duration(milliseconds: speed), (timer) {
      if (!gameOver) {
        updateGame();
      }
    });
  }

  void updateGame() {
    // Update time and game state
    elapsedTime++;
    if (snake.collidesWithSelf() || snake.collidesWithWalls(gridSize)) {
      gameOver = true;
      _gameTimer?.cancel(); // Stop the game timer
    }

    snake.move();
    if (snake.headPosition == apple.position) {
      score++;
      snake.grow();
      apple.explode();
      apple.spawn();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _drawScore(canvas);
    if (gameOver) {
      _drawGameOver(canvas);
    }
  }

  void _drawScore(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Score: $score    Time: ${(elapsedTime / 5).floor()}s',
        style: TextStyle(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(size.x / 2 - textPainter.width / 2,
            boardOffset.dy - textPainter.height));
  }

  void _drawGameOver(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Game Over\nScore: $score\nTap to Restart',
        style: TextStyle(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(size.x / 2 - textPainter.width / 2,
            size.y / 2 - textPainter.height / 2));
  }

  @override
  void onTap() {
    if (gameOver) {
      resetGame();
    }
  }

  void resetGame() {
    gameOver = false;
    score = 0;
    elapsedTime = 0;
    snake.reset();
    apple.spawn();
    _startGameLoop();
  }

  // Handle direction changes based on swipe or keyboard input
  void onDirectionChange(Vector2 newDirection) {
    snake.changeDirection(newDirection);
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      onDirectionChange(Vector2(0, -1));
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      onDirectionChange(Vector2(0, 1));
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      onDirectionChange(Vector2(-1, 0));
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      onDirectionChange(Vector2(1, 0));
    }
    return KeyEventResult.handled;
  }

  @override
  void onVerticalDragUpdate(DragUpdateInfo info) {
    if (info.raw.delta.dy < 0) {
      onDirectionChange(Vector2(0, -1)); // Swipe up
    } else if (info.raw.delta.dy > 0) {
      onDirectionChange(Vector2(0, 1)); // Swipe down
    }
  }

  @override
  void onHorizontalDragUpdate(DragUpdateInfo info) {
    if (info.raw.delta.dx < 0) {
      onDirectionChange(Vector2(-1, 0)); // Swipe left
    } else if (info.raw.delta.dx > 0) {
      onDirectionChange(Vector2(1, 0)); // Swipe right
    }
  }
}
