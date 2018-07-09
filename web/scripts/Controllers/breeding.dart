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
    ygdrassil.testTrees();
    ygdrassil.render();
    hookUpTestControls();
}

void hookUpTestControls() {
    window.onKeyDown.listen((KeyboardEvent e) {
        keycodes.add(e.keyCode);
        movePlayer();
    });

    window.onKeyUp.listen((KeyboardEvent e) {
        keycodes.remove(e.keyCode);
        movePlayer();
    });
    InputElement rangeElement = new InputElement()..type = "range"..max = "${13*4}"..min="${-13*3}"..value = "${ygdrassil.health}";
    rangeElement.style.display = "block";
    output.append(rangeElement);

    rangeElement.onChange.listen((Event e) {
        ygdrassil.health = int.parse(rangeElement.value);
        ygdrassil.showAndHideYgdrssylLayers();
    });
}


void movePlayer() {
    Player player = ygdrassil.underWorld.player;
    for(int keyCode in keycodes) {
        //wasd
        if (keyCode == 65) player.left();
        if (keyCode == 68) player.right();
        if (keyCode == 87) player.up();
        if (keyCode == 83) player.down();
    }
    ygdrassil.render();
}


