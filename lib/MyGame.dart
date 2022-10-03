import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' hide TextStyle;


class MyGame extends FlameGame with SingleGameInstance, HasTappables, HasCollisionDetection {
  MyPlayer player = MyPlayer();
  Wall wall1 = Wall();
  int score = 0;

  double gravity = 10;
  late TextComponent musicText;
  late TextComponent scoreText;

  final style = TextStyle(color: BasicPalette.white.color);
  final regular = TextPaint(style: TextStyle(color: BasicPalette.red.color, fontSize: 20));


  @override
  Color backgroundColor() => const Color(0x5900D9FF);

  @override
  Future<void> onLoad() async {

    TextComponent musicText = TextComponent(text: 'Tap the music button (on top right)', textRenderer: regular);
    musicText.x = size[0] / 2;
    musicText.y = 64.0;
    musicText.anchor = Anchor.center;

    scoreText = TextComponent(text: 'Score: $score', textRenderer: regular);

    add(musicText);
    add(scoreText);

    await FlameAudio.audioCache.load('diamondpokecenter.wav');
    await FlameAudio.audioCache.load('diamondroute101.wav');
    await FlameAudio.audioCache.load('diamondstart.wav');
    await FlameAudio.audioCache.load('pip.wav');


    // screen coordinates
    player.position = Vector2(50, 50); // Vector2(0.0, 0.0) by default, can also be set in the constructor
    // player.angle = ... // 0 by default, can also be set in the constructor
    add(player); // Adds the component

    musicBtn musicbtn = musicBtn();
    musicbtn.width = 64;
    musicbtn.height = 64;
    musicbtn.position = Vector2(size[0] - musicbtn.width, 70);

    musicBtn.musicText = musicText;
    add(musicbtn);


    wall1.position = Vector2(450, -100);
    // wall1.topWall.size = Vector2(size[0] / 10, size[1]/2);
    // wall1.botWall.size = Vector2(size[0] / 10, size[1]/2);
    wall1.gap = 700;
    add(wall1);

    // MyComponent myComponent = MyComponent();
    // add(myComponent);

  }

  @override
  void update(double dt) {
    super.update(dt);
    player.dt = dt;
    if (player.position.y > size[1] - player.height) {
      if (player.velocity.y > 0) {
        player.velocity.y = 0;
      }
      player.position.y += player.velocity.y * 0.008;
      score = 0;
      scoreText.text = 'Score: $score';
    } else {
      player.velocity.y += gravity;
      player.position.y += player.velocity.y * 0.008;
    }

    if (wall1.position.x < -600) {
      wall1.position.x = size[0];
      int myint = (size.y * 0.3).toInt();
      wall1.position.y =  -100 - Random().nextInt(myint).toDouble();
      score++;
      scoreText.text = 'Score: $score';
    } else {
      wall1.position.x -= 200 * 0.008;

    }


  }

}

class MyPlayer extends SpriteComponent with Tappable, HasGameRef<MyGame>, CollisionCallbacks {
  Vector2 velocity = Vector2(0, 0);
  double dt = 1;
  late ShapeHitbox hitbox;


  MyPlayer() : super(
      size: Vector2.all(128),
  );

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('pip.jpg');
    hitbox = RectangleHitbox();
    hitbox.paint = Paint()..color = Color(0x99FF0000);
    hitbox.renderShape = true;
    add(hitbox);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints,
      PositionComponent other,
      ) {
    super.onCollisionStart(intersectionPoints, other);

    print('collision');
    gameRef.score = 0;
    gameRef.scoreText.text = 'Score: ${gameRef.score}';
  }

  @override
  bool onTapDown(TapDownInfo info) {
    print('Tapped!');
    AudioPlayer().play(AssetSource('audio/pip.wav'));
    velocity.y = -3.5 / 0.008;
    return true;
  }


}

class TopWall extends SpriteComponent with HasGameRef<MyGame>, CollisionCallbacks{
  TopWall() : super(size: Vector2(50, 450));
  late ShapeHitbox hitbox;

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('pip.jpg');
    hitbox = RectangleHitbox();
    hitbox.paint = Paint()..color = Color(0x99FF0000);
    hitbox.renderShape = true;
    add(hitbox);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints,
      PositionComponent other,
      ) {
    super.onCollisionStart(intersectionPoints, other);

    print('collision');

  }
}


class BotWall extends SpriteComponent with CollisionCallbacks{
  BotWall() : super(size: Vector2(50, 450));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('pip.jpg');
  }
}

class Wall extends PositionComponent {
  Vector2 velocity = Vector2(0, 0);
  double dt = 1;

  double topY = -50;
  double botY = 500;
  double gap = 0;
  TopWall topWall = TopWall();
  TopWall botWall = TopWall();

  Wall() : super();

  @override
  Future<void>? onLoad() {
    topWall.position = Vector2(position.x, topY);
    botWall.position = Vector2(position.x, topY + gap);
    add(topWall);
    add(botWall);
  }



}

class musicBtn extends SpriteComponent with Tappable{
  int counter = 0;
  static late TextComponent musicText;

  musicBtn() : super(size: Vector2.all(128));


  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('pip.jpg');
  }

  @override
  bool onTapDown(TapDownInfo info) {
    print('Tapped!');

    switch (counter) {
      case 0:
        FlameAudio.bgm.play('diamondpokecenter.wav');
        musicText.text = 'Current Music: diamondpokecenter.wav\n\nNext Music: diamondroute101.wav\nTap the music button to change to next music';
        break;
      case 1:
        FlameAudio.bgm.play('diamondroute101.wav');
        musicText.text = 'Current Music: diamondroute101.wav\n\nNext Music: diamondstart.wav\nTap the music button to change to next music';
        break;
      case 2:
        FlameAudio.bgm.play('diamondstart.wav');
        musicText.text = 'Current Music: diamondstart.wav\n\nNext Music: Silence\nTap the music button to change to next music';
        break;
      case 3:
        FlameAudio.bgm.stop();
        musicText.text = 'Current Music: Silence\n\nNext Music: diamondpokecenter.wav\nTap the music button to change to next music';
        counter = -1;
        break;
    }

    counter++;
    return true;
  }


}

//insert text at the top





class MyComponent extends PositionComponent with TapCallbacks {
  MyComponent() : super(size: Vector2(80, 60));

  @override
  void onLongTapDown(TapDownEvent event) {
    // Do something in response to a tap
    print('Tapped!');
  }

}