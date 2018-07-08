import 'dart:html';
import "../Utility/TODOs.dart";

Element output = querySelector('#output');
void main() {
    TODOs.drawTodos(output);
}
