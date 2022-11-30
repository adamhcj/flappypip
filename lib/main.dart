import 'package:firebase_core/firebase_core.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flappypip/MyGame.dart';

import 'firebase_options.dart';




void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final game = MyGame();

  Padding sendScore = Padding(
    padding: const EdgeInsets.all(100.0),
    child: Opacity(
      opacity: 0.5,
      child: Container(
        child: MyApp(game: game),
        height: 100,
      ),
    ),
  );

  Stack mainStack = Stack(
      children: [
        GameWidget(
          game: game,
          overlayBuilderMap: {
            'PauseMenu': (BuildContext context, MyGame game) {
              return Center(
                child: Container(
                  child: Text('Game Over!\nKey in name and send score (for highscores), refresh to see leaderboard',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 30,
                      backgroundColor: Colors.black26,
                    ),
                  ),
                ),
              );

            }
          },
        ),
      ]
  );



    MaterialApp mainMaterial = MaterialApp(
      home:
      Scaffold(
          body: mainStack
      ),
    );


    runApp(
        mainMaterial
    );
    mainStack.children.add(sendScore);
}




class MyApp extends StatelessWidget {
  final MyGame game;
  const MyApp({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Form Styling Demo';
    return MaterialApp(
      home: Scaffold(
        body: MyCustomForm(game: game),
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  final MyGame game;
  const MyCustomForm({super.key, required this.game});

  @override
  State<MyCustomForm> createState() => _MyCustomFormState(game);
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _MyCustomFormState extends State<MyCustomForm> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();
  final MyGame game;
  _MyCustomFormState(this.game);

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    myController.text = "Enter name here";
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: myController,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // When the user presses the button, show an alert dialog containing
        // the text that the user has entered into the text field.
        onPressed: () async {
          final ref = game.ref;

          addScore(String newname, int highscore) async {

            List<String> scores = [];
            List<String> names = [];
            for (var i = 1; i <= 10; i++) {
              final score = await ref.child(i.toString()+"/score").get();
              final name = await ref.child(i.toString()+"/name").get();

              scores.add(score.value.toString());
              names.add(name.value.toString());
            }

            int counter = 1;
            for (String score in scores) {
              if (highscore > int.parse(score)) {
                ref.child(counter.toString()).update({
                  "name": newname,
                  "score": highscore,
                });

                for (int i = counter+1; i <= 10; i++) {
                  ref.child((i).toString()).update({
                    "name": names[i-1],
                    "score": scores[i-1],
                  });
                }

                return counter;

              }
              counter++;
            }
          }
          await addScore(myController.text, game.score);
          await game.updatehighScore();
          showDialog(
            context: context,
            builder: (context) {

              int oldScore = game.score;
              game.score = 0;

              return AlertDialog(
                // Retrieve the text the that user has entered by using the
                // TextEditingController.
                content: Text( "Submitted to hiscores:\n" + myController.text + " : " + oldScore.toString()),
              );
            },
          );
        },
        tooltip: 'Send Score!',
        child: const Icon(Icons.add),
      ),
    );
  }
}