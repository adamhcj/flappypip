import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart';

class MyGame extends FlameGame with SingleGameInstance, HasTappableComponents{
  @override
  Color backgroundColor() => const Color(0x5900D9FF);

  @override
  Future<void> onLoad() async {

    FlameAudio.bgm.play('diamondpokecenter.wav');

    final player = MyPlayer();

    // screen coordinates
    player.position = Vector2(50, 50); // Vector2(0.0, 0.0) by default, can also be set in the constructor
    // player.angle = ... // 0 by default, can also be set in the constructor
    add(player); // Adds the component

    MyComponent myComponent = MyComponent();
    add(myComponent);

  }

}

class MyPlayer extends SpriteComponent with TapCallbacks{
  MyPlayer() : super(size: Vector2.all(128));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('pip.jpg');
  }

  @override
  void onTapUp(TapUpEvent event) {
    // Do something in response to a tap
    print('Tapped!');
    FlameAudio.play('pip.wav');

  }

}


class MyComponent extends PositionComponent with TapCallbacks {
  MyComponent() : super(size: Vector2(80, 60));

  @override
  void onTapDown(TapDownEvent event) {
    // Do something in response to a tap
    print('Tapped!');
  }

}