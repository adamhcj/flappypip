import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' hide TextStyle;


class MyGame extends FlameGame with SingleGameInstance, HasTappables, HasCollisionDetection{
  MyPlayer player = MyPlayer();
  double gravity = 4;
  late TextComponent musicText;

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

    add(musicText);

    await FlameAudio.audioCache.load('diamondpokecenter.wav');
    await FlameAudio.audioCache.load('diamondroute101.wav');
    await FlameAudio.audioCache.load('diamondstart.wav');
    await FlameAudio.audioCache.load('pip.wav');


    // screen coordinates
    player.position = Vector2(50, 50); // Vector2(0.0, 0.0) by default, can also be set in the constructor
    // player.angle = ... // 0 by default, can also be set in the constructor
    add(player); // Adds the component

    musicBtn musicbtn = musicBtn();
    musicbtn.position = Vector2(size[0] - musicbtn.width, 0);
    musicBtn.musicText = musicText;
    add(musicbtn);

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
      player.position.y += player.velocity.y * dt;
    } else {
      player.velocity.y += gravity;
      player.position.y += player.velocity.y * dt;
    }

  }

}

class MyPlayer extends SpriteComponent with Tappable{
  Vector2 velocity = Vector2(0, 0);
  double dt = 1;

  MyPlayer() : super(size: Vector2.all(128));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('pip.jpg');
  }

  @override
  bool onTapDown(TapDownInfo info) {
    print('Tapped!');
    FlameAudio.play('pip.wav');
    velocity.y = -2 / dt;
    return true;
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