import 'dart:async';
import 'dart:html';
import "../Utility/TODOs.dart";

import 'package:CommonLib/NavBar.dart';

Element output = querySelector('#output');
Future<Null> main() async {
    await loadNavbar();
    TODOs.drawTodos(output);
}
