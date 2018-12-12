import 'package:html/dom.dart';
import 'package:html/dom_parsing.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/parser_console.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async' show Future;

void main2() async {
  //print(await HttpRequest.request('https://swapi.co/api/people/1'));

  var document = parser
      .parse('<body>Hello world! <a href="www.html5rocks.com">HTML5 rocks!');
  print(document.outerHtml);
}

Future<String> loadPages() async {
  return await rootBundle.loadString('scripts/bibli.yaml');
}

Future<http.Response> fetchPost() {
  return http.get(
      'http://www.litteratureaudio.com/classement-de-nos-livres-audio-gratuits-les-plus-apprecies');
}

void main() async {
  String pages = await loadPages();
  print(pages);
  // http.Response response = await fetchPost();
  // if (response.statusCode == 200) {
  //   // If server returns an OK response, go on
  //   Document doc = parser.parse(response.body);
  //   List<Element> elem = doc.getElementsByClassName('entrybody2');
  //   List<Element> links = elem.first.querySelectorAll('a');
  //   for (var l in links) {
  //     var att = l.attributes;
  //     String bookpage = att['href'];
  //     String title = att['title'];
  //     print(bookpage + '----' + title);
  //     break;
  //   }
  // } else {
  //   // If that response was not OK, throw an error.
  //   throw Exception('Failed to load post');
  // }
}
