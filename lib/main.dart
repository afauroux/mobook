import 'package:flutter/material.dart';
import 'package:tts/tts.dart' as tts;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Mo's Books",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Menu Principal'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> options = [
    "Biblihothèque",
    "Reprendre la lecture en cours",
    "quel heure est-t-il?"
  ];
  int current = 0;

  void speak(String msg) async {
    tts.Tts.speak(msg);
    print(msg);
  }

  @override
  void initState() {
    super.initState();
    tts.Tts.setLanguage('fr-FR');
    speak("Menu Principal");
  }

  void _leftButtonPressed() async {
    setState(() {
      current++;
      current = current % options.length;
      speak(options[current]);
    });
  }

  void _rightButtonPressed() async {
    setState(() {
      current--;
      current = current % options.length;
      speak(options[current]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: <Widget>[
            Container(
                color: Colors.black,
                padding: EdgeInsets.all(20),
                child: Text(options[current])),
            Expanded(
                child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                    child: GestureDetector(
                        onTap: _leftButtonPressed,
                        child: Container(
                            alignment: Alignment(0, 0),
                            color: Colors.blue,
                            child: Text('Gauche')))),
                Expanded(
                    child: GestureDetector(
                        onTap: _rightButtonPressed,
                        child: Container(
                            alignment: Alignment(0, 0),
                            color: Colors.red,
                            child: Text('Droite')))),
              ],
            ))
          ],
        ));
  }
}
