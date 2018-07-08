import '../Gameplay/World.dart';
import 'dart:html';
import "../Utility/TODOs.dart";

Element output = querySelector('#output');
World ygdrassil = new World(output);
void main() {
    TODOs.drawTodos(output);
    ygdrassil.render();
}
