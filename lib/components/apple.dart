import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class Apple extends Component {
  double cellSize = 0;
  int gridSize = 1;
  Offset boardOffset = Offset.zero;
  Vector2 position = Vector2.zero();

  @override
  Future<void> onLoad() async {
    spawn(); // Initialize the apple position
  }

  void onResize(double cellSize, int gridSize, Offset boardOffset) {
    this.cellSize = cellSize;
    this.gridSize = gridSize;
    this.boardOffset = boardOffset;
  }

  void spawn() {
    position = Vector2(Random().nextInt(gridSize).toDouble(),
        Random().nextInt(gridSize).toDouble());
  }

  // @override
  // void render(Canvas canvas) {
  //   final paint = Paint()..color = Colors.red;
  //   final rect = Rect.fromLTWH(
  //     boardOffset.dx + position.x * cellSize - 1,
  //     boardOffset.dy + position.y * cellSize - 1,
  //     cellSize + 2,
  //     cellSize + 2,
  //   );
  //   canvas.drawRect(rect, paint);
  // }
  @override
  void render(Canvas canvas) {
    final Paint applePaint = Paint()..color = Colors.red;
    final Paint stemPaint = Paint()..color = Colors.brown;
    final Paint leafPaint = Paint()..color = Colors.green;

    final ox = boardOffset.dx + position.x * cellSize;
    final oy = boardOffset.dy + position.y * cellSize;

    // Draw the apple's circular body
    canvas.drawCircle(
      Offset(
          ox + cellSize / 2, oy + cellSize / 2), // Center the apple in the cell
      cellSize * 0.4, // Radius of the apple body
      applePaint,
    );

    // Draw the apple's stem
    canvas.drawRect(
      Rect.fromLTWH(
        ox + cellSize * 0.45, // Center the stem on the apple
        oy + cellSize * 0.1, // Position it slightly above the apple body
        cellSize * 0.1, // Width of the stem
        cellSize * 0.3, // Height of the stem
      ),
      stemPaint,
    );

    // Draw the apple's leaf
    canvas.save();
    canvas.translate(
        ox + cellSize * 0.6, oy + cellSize * 0.1); // Position near stem
    canvas.rotate(-0.5); // Rotate leaf to angle it naturally
    canvas.drawOval(
      Rect.fromLTWH(
        0, 0,
        cellSize * 0.15, // Width of the leaf
        cellSize * 0.3, // Height of the leaf
      ),
      leafPaint,
    );
    canvas.restore();
  }

  // Trigger the explosion particle effect
  Random rnd = Random();
  Vector2 randomVector2() => (Vector2.random(rnd) - Vector2.random(rnd)) * 200;

  void explode() {
    add(
      ParticleSystemComponent(
        position: Vector2(
          boardOffset.dx + position.x * cellSize,
          boardOffset.dy + position.y * cellSize,
        ),
        particle: Particle.generate(
          count: 10,
          lifespan: 5,
          applyLifespanToChildren: true,
          generator: (i) => AcceleratedParticle(
            acceleration: randomVector2(),
            child:
                CircleParticle(paint: Paint()..color = Colors.red, radius: 5),
          ),
        ),
      ),
    );
    // Add the particle effect to the game
  }
}
