import '../Gameplay/Player.dart';
import '../Gameplay/World.dart';
import 'dart:html';
import "../Utility/TODOs.dart";

Element output = querySelector('#output');
World ygdrassil = new World(output);
List<int> keycodes = new List<int>();
void main() {
    TODOs.drawTodos(output);
    ygdrassil.health = 26;

}



