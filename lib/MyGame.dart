import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart';

class MyGame extends FlameGame with SingleGameInstance, HasTappables, HasCollisionDetection{
  MyPlayer player = MyPlayer();
  double gravity = 4;

  @override
  Color backgroundColor() => const Color(0x5900D9FF);

  @override
  Future<void> onLoad() async {




    // screen coordinates
    player.position = Vector2(50, 50); // Vector2(0.0, 0.0) by default, can also be set in the constructor
    // player.angle = ... // 0 by default, can also be set in the constructor
    add(player); // Adds the component

    musicBtn musicbtn = musicBtn();
    musicbtn.position = Vector2(size[0] - musicbtn.width, 0);
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

  musicBtn() : super(size: Vector2.all(128));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('pip.jpg');
  }

  @override
  bool onTapDown(TapDownInfo info) {
    print('Tapped!');
    FlameAudio.bgm.play('diamondpokecenter.wav');
    return true;
  }


}


class MyComponent extends PositionComponent with TapCallbacks {
  MyComponent() : super(size: Vector2(80, 60));

  @override
  void onLongTapDown(TapDownEvent event) {
    // Do something in response to a tap
    print('Tapped!');
  }

}