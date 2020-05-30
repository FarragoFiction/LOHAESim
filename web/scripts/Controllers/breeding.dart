import 'dart:async';
import 'dart:html';

import 'package:CommonLib/NavBar.dart';
import 'package:DollLibCorrect/DollRenderer.dart';

import '../Gameplay/Player.dart';
import '../Gameplay/World.dart';

Element output = querySelector('#output');
World ygdrassil;
Set<int> keycodes = <int>{};
Future<void> main() async {
    await Doll.loadFileData();
    querySelector("body").style.height = "2500px";
    await loadNavbar();
    ygdrassil = new World();
    ygdrassil.health = 26;
    ygdrassil.makeFundsElement(querySelector("#navbar"));
    await ygdrassil.setupElements(output);
    ygdrassil.renderLoop();
    if(getParameterByName("haxMode") == "on" || getParameterByName("yearnedFor") == "Node" ) {
        hookUpTestControls();
    }
    ygdrassil.save("From initial load");
    //TODOs.drawTodos(output);
}

void testActiveItem() {
    ygdrassil.underWorld.player.inventory.activeItem = ygdrassil.underWorld.player.inventory.first;
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

}


void movePlayer() {
    Player player = ygdrassil.underWorld.player;
    bool render = false;
    for(int keyCode in keycodes) {
        //wasd
        if (keyCode == 65) {
            player.left();
            render = true;
        }
        if (keyCode == 68) {
            player.right();
            render = true;

        }
        if (keyCode == 87) {
            player.up();
            render = true;

        }
        if (keyCode == 83) {
            player.down();
            render = true;

        }
    }
    if(render) ygdrassil.render();

}


