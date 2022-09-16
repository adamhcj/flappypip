import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

import 'package:flappypip/MyGame.dart';

void main() {
  final game = MyGame();
  runApp(GameWidget(game: game));
}

