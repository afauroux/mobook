import 'package:flutter/material.dart';
import 'package:tts/tts.dart' as tts;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:yaml/yaml.dart';
import 'dart:collection';

Future<String> loadBibli() async {
  return await rootBundle.loadString('scripts/bibli.yaml');
}

void speak(String msg) async {
  print(msg);
  tts.Tts.speak(msg);
}

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
  double screenWidth;
  String title;
  Navigator navigator;
  int current = 0;
  List<String> options = [];

  void _leftButtonPressed() {
    setState(() {
      navigator.prev();
    });
  }

  void _rightButtonPressed() {
    setState(() {
      navigator.next();
    });
  }

  void sayTime() async {
    var n = DateTime.now();

    String time =
        'Il est ${n.hour} heures et ${n.minute} minutes; et nous sommes le ${n.day}, ${n.month}, ${n.year}';
    speak(time);
  }

  void _returnPressed() {
    navigator.back();
  }

  void _okPressed() {
    if (navigator.currentOption == "quel heure est-t-il?") {
      sayTime();
    }
    navigator.go();
  }

  void setCurrent(int v) {
    setState(() {
      current = v;
    });
  }

  void setOptions(List<String> opt) {
    setState(() {
      options = opt;
    });
  }

  @override
  void initState() {
    super.initState();
    //options = menuOptions;
    tts.Tts.setLanguage('fr-FR').then((value) {
      speak("Menu Principal");
      //speak(
      //    "Bonjours Colette, Ceci est une bibliothèque intelligente. Elle permet de facilement écouter des livres audio.");
    });

    navigator = Navigator(setOptions, setCurrent);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    title = widget.title;
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                flex: 2,
                child: GestureDetector(
                    onTap: _okPressed,
                    child: Container(
                        color: Colors.green,
                        child:
                            FittedBox(child: Text(navigator.currentOption))))),
            Expanded(
                flex: 4,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                        child: GestureDetector(
                            onTap: _leftButtonPressed,
                            child: Container(
                                color: Colors.blue,
                                child:
                                    FittedBox(child: Icon(Icons.arrow_back))))),
                    Expanded(
                        child: GestureDetector(
                            onTap: _rightButtonPressed,
                            child: Container(
                                color: Colors.yellow,
                                child: FittedBox(
                                    child: Icon(Icons.arrow_forward))))),
                  ],
                )),
            Expanded(
                flex: 1,
                child: GestureDetector(
                    onTap: _returnPressed,
                    child: Container(
                        color: Colors.red,
                        width: 1000.0,
                        child: FittedBox(
                            fit: BoxFit.fitHeight, child: Text('Retour'))))),
          ],
        ));
  }
}

class Navigator {
  dynamic bibli;
  final Queue path = Queue();
  dynamic currentSection;
  List<String> _options = [];
  int _current = 0;
  dynamic setOption; //option state setter
  dynamic setCurrent; //option state setter

  Navigator(dynamic setOption, dynamic setCurrent) {
    _loadBibli();
  }

  void _loadBibli() async {
    loadBibli().then((value) {
      bibli = loadYaml(value);
      currentSection = bibli;
      print('bibli loaded');
      _loadOptions();
    });
  }

  List<String> get options {
    return _options;
  }

  int get current {
    return this._current;
  }

  String get currentOption {
    return _current < _options.length ? _options[_current] : "aucune options";
  }

  void go() {
    //go to the current option
  }
  void back() {
    //comme back one step
  }

  void next() {
    _current++;
    _current = _current % options.length;
    setCurrent(this.current);
    speak(this.currentOption);
  }

  void prev() {
    _current--;
    if (_current < 0) _current = 0;
    _current = _current % options.length;
    setCurrent(this.current);
    speak(this.currentOption);
  }

  void _loadOptions() {
    // getting the list of options
    var prevOptions = _options;
    _options = [];
    if (currentSection is YamlList) {
      for (dynamic s in currentSection) {
        if (s is String) {
          _options.add(s);
        } else if (s is YamlMap) {
          _options.add(s.keys.first);
        }
      }
    } else if (currentSection is YamlMap) {
      for (String s in currentSection.keys) {
        print(s);
        _options.add(s);
      }
    } else {
      _options = prevOptions;
    }
    setOption(this.options);
  }

  // void _returnPrevSection() {
  //   if (path.length <= 1) return;
  //   var section = bibli;
  //   path.removeLast();
  //   for (var p in path) {
  //     section = section[p];
  //   }
  //   currentSection = section;
  // }

  // void _loadClickedSection() async {
  //   // Storing the selected option
  //   if (currentSection is YamlList) {
  //     path.addLast(current);
  //   } else if (currentSection is YamlMap) {
  //     path.addLast(options[current]);
  //   }
  //   currentSection = currentSection[path.last];
  // }
}
