import 'dart:convert';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flappypip/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' hide TextStyle;

import 'firebase_options.dart';


class MyGame extends FlameGame with SingleGameInstance, HasTappables, HasCollisionDetection {


  late var ref;
  MyPlayer player = MyPlayer();
  Wall wall1 = Wall();
  int score = 0;
  String highScoreText = "Highscores!! : \n\n";


  double gravity = 1000;
  late TextComponent musicText;
  late TextComponent scoreText;
  late TextComponent highScores;

  List<String> scores = [];
  List<String> names = [];

  final style = TextStyle(color: BasicPalette.white.color);
  final regular = TextPaint(style: TextStyle(color: BasicPalette.red.color, fontSize: 20));


  @override
  Color backgroundColor() => const Color(0x5900D9FF);

  updatehighScore() async {
    ref = FirebaseDatabase.instance.ref("highscore");
    highScoreText = "Highscores!! : \n\n";
    scores = [];
    names = [];
    for (var i = 1; i <= 10; i++) {
      final score = await ref.child(i.toString()+"/score").get();
      final name = await ref.child(i.toString()+"/name").get();

      scores.add(score.value.toString());
      names.add(name.value.toString());
      highScoreText += i.toString() + ".) " + name.value.toString() + " : " + score.value.toString() + "\n";
      print(i.toString());
      print(highScoreText);
    }
    highScores.text = highScoreText;
    return;
  }

  @override
  Future<void> onLoad() async {

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    ref = FirebaseDatabase.instance.ref("highscore");




    // // updating score
    // await ref.update({
    //   "1": {
    //     "name": "changedpiplup",
    //     "score": 100,
    //   },
    // });

    // // initial database population
    // await ref.set({
    //   "1": {
    //     "name": "piplup",
    //     "score": 0
    //   },
    //   "2": {
    //     "name": "pikachu",
    //     "score": 0
    //   },
    //   "3": {
    //     "name": "piplup",
    //     "score": 0,
    //   },
    //   "4": {
    //     "name": "piplup",
    //     "score": 0,
    //   },
    //   "5": {
    //     "name": "piplup",
    //     "score": 0,
    //   },
    //   "6": {
    //     "name": "piplup",
    //     "score": 0,
    //   },
    //   "7": {
    //     "name": "piplup",
    //     "score": 0,
    //   },
    //   "8": {
    //     "name": "piplup",
    //     "score": 0,
    //   },
    //   "9": {
    //     "name": "piplup",
    //     "score": 0,
    //   },
    //   "10": {
    //     "name": "piplup",
    //     "score": 0,
    //   },
    // });

    final snapshot = await ref.get();
    if (snapshot.exists) {
      print(snapshot.value);
    } else {
      print('No data available.');
    }


    for (var i = 1; i <= 10; i++) {
      final score = await ref.child(i.toString()+"/score").get();
      final name = await ref.child(i.toString()+"/name").get();

      scores.add(score.value.toString());
      names.add(name.value.toString());
      highScoreText += i.toString() + ".) " + name.value.toString() + " : " + score.value.toString() + "\n";
    }

    addScore(int highscore) async {

      List<String> scores = [];
      List<String> names = [];
      for (var i = 1; i <= 10; i++) {
        final score = await ref.child(i.toString()+"/score").get();
        final name = await ref.child(i.toString()+"/name").get();

        scores.add(score.value.toString());
        names.add(name.value.toString());
        highScoreText += i.toString() + ".) " + name.value.toString() + " : " + score.value.toString() + "\n";
      }

      int counter = 1;
      for (String score in scores) {
        if (highscore > int.parse(score)) {
          ref.child(counter.toString()).update({
            "name": "newname",
            "score": highscore,
          });

          for (int i = counter+1; i <= 10; i++) {
            ref.child((i).toString()).update({
              "name": names[i-1],
              "score": scores[i-1],
            });
          }

          break;

        }
        counter++;
      }
    }

    highScores = TextComponent(text: highScoreText, textRenderer: regular);
    highScores.x = size[0] / 2;
    highScores.y = size[1] / 2;
    highScores.anchor = Anchor.center;

    add(highScores);





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

    if (player.position.y > size[1] - player.height) {
      if (player.velocity.y > 0) {
        player.velocity.y = 0;
      }
      player.position.y += player.velocity.y * dt;
      // score -= 1;


      // paused = true;
      // overlays.add('PauseMenu');
      scoreText.text = 'Score: $score';
    } else {
      player.velocity.y += gravity * dt;
      player.position.y += player.velocity.y * dt;
    }

    if (wall1.position.x < -600) {
      wall1.position.x = size[0];
      int myint = (size.y * 0.3).toInt();
      wall1.position.y =  -100 - Random().nextInt(myint).toDouble();
      score++;
      scoreText.text = 'Score: $score';
    } else {
      wall1.position.x -= 250 * dt;

    }


  }

}

class MyPlayer extends SpriteComponent with Tappable, HasGameRef<MyGame>, CollisionCallbacks {
  Vector2 velocity = Vector2(0, 0);
  late ShapeHitbox hitbox;


  MyPlayer() : super(
      size: Vector2.all(128),
  );


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
    gameRef.score -= 1;
    gameRef.scoreText.text = 'Score: ${gameRef.score}';


    // gameRef.paused = true;
  }

  @override
  bool onTapDown(TapDownInfo info) {
    print('Tapped!');
    FlameAudio.play('pip.wav', volume: .25);
    velocity.y = -500;
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
        FlameAudio.bgm.play('diamondpokecenter.wav', volume: .25);
        musicText.text = 'Current Music: diamondpokecenter.wav\n\nNext Music: diamondroute101.wav\nTap the music button to change to next music';
        break;
      case 1:
        FlameAudio.bgm.play('diamondroute101.wav', volume: .25);
        musicText.text = 'Current Music: diamondroute101.wav\n\nNext Music: diamondstart.wav\nTap the music button to change to next music';
        break;
      case 2:
        FlameAudio.bgm.play('diamondstart.wav', volume: .25);
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