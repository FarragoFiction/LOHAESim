import '../Gameplay/OnScreenText.dart';
import '../Gameplay/Player.dart';
import '../Gameplay/World.dart';
import 'dart:async';
import 'dart:html';
import "../Utility/TODOs.dart";
import 'package:CommonLib/NavBar.dart';
import 'package:LoaderLib/Loader.dart';


Element output = querySelector('#output');
Element content = new DivElement()..classes.add("store");
World ygdrassil = World.instance;
List<int> keycodes = new List<int>();
Future<Null> main() async {
    output.append(content);
    initCanvasAndBuffer();

}

//ignore the other parts of what the world would do
Future<Null> initCanvasAndBuffer() async {


    ygdrassil.bg = await Loader.getResource("images/BGs/AlternianCliff.png");
    ygdrassil.bgCorrupt = await Loader.getResource("images/BGs/AlternianCliffCorrupt.png");
    ygdrassil.branches = await Loader.getResource("images/BGs/frame.png");
    ygdrassil.branches.classes.add("frameLayer");
    ygdrassil.branches.style.display = "none";
    content.append(ygdrassil.branches);

    DivElement title = new DivElement()..classes.add("titleScreen");
    title.text = "The Land of Horticulture and Essence";
    content.style.width + "${ygdrassil.branches.width}px";
    content.style.height + "${ygdrassil.branches.height}px";
    content.append(title);

    window.onClick.listen((Event e){
        window.location.href = "index.html";
    });

    ygdrassil.tentacles = await Loader.getResource("images/BGs/frameTentacle.png");
    ygdrassil.tentacles.classes.add("frameLayer");
    ygdrassil.tentacles.style.display = "none";
    content.append(ygdrassil.tentacles);


    ygdrassil.leaves = await Loader.getResource("images/BGs/frameLeaves.png");
    content.append(ygdrassil.leaves);
    ygdrassil.leaves.style.display = "none";
    ygdrassil.leaves.classes.add("frameLayer");

    ygdrassil.flowers = await Loader.getResource("images/BGs/frameFlowers.png");
    ygdrassil.flowers.classes.add("frameLayer");
    ygdrassil.flowers.style.display = "none";
    content.append(ygdrassil.flowers);

    ygdrassil.fruit = await Loader.getResource("images/BGs/frameFruit.png");
    ygdrassil.fruit.classes.add("frameLayer");
    ygdrassil.fruit.style.display = "none";
    content.append(ygdrassil.fruit);

    ygdrassil.eyes = await Loader.getResource("images/BGs/frameEyes.png");
    ygdrassil.eyes.classes.add("frameLayer");
    ygdrassil.eyes.style.display = "none";
    content.append(ygdrassil.eyes);
    ygdrassil.health = 26;
    ygdrassil.showAndHideYgdrssylLayers();
    ygdrassil.backgroundMusic.play();
}
