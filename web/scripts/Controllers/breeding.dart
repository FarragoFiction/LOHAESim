import '../Gameplay/OnScreenText.dart';
import '../Gameplay/Player.dart';
import '../Gameplay/World.dart';
import 'dart:async';
import 'dart:html';
import "../Utility/TODOs.dart";
import "package:RenderingLib/src/loader/loader.dart" as OldRenderer;


Element output = querySelector('#output');
World ygdrassil = new World();
List<int> keycodes = new List<int>();
Future<Null> main() async {
    await OldRenderer.Loader.preloadManifest();
    ygdrassil.health = 26;
    await ygdrassil.setupElements(output);
    testActiveItem();
    ygdrassil.renderLoop();
    hookUpTestControls();
    ygdrassil.backgroundMusic.play(); //get around auto play not working in some browsers
    print(ygdrassil.toDataString());
    ygdrassil.save();
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


