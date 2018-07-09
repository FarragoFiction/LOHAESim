import '../Gameplay/World.dart';
import 'dart:html';
import "../Utility/TODOs.dart";

Element output = querySelector('#output');
World ygdrassil = new World(output);
void main() {
    TODOs.drawTodos(output);
    ygdrassil.health = 26;
    //ygdrassil.testTrees();
    ygdrassil.render();
}


void hookUpTestControls() {

}


