import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:snake_game/snake_game.dart';

class GameScreen extends StatelessWidget {
  final int boardSize;
  final int speed;

  GameScreen({Key? key, required this.boardSize, required this.speed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        leading: CloseButton(),
      ),
      body: GameWidget(game: SnakeGame(gridSize: boardSize, speed: speed)),
    );
  }
}
