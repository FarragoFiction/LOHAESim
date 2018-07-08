import 'dart:async';
import 'dart:html';
import "package:DollLibCorrect/DollRenderer.dart";
//yggdrasil
class World {
    int width = 800;
    int height = 1000;
    String bgLocation = "images/BGs/AlternianCliffs.png";

    List<TreeDoll> trees = new List<TreeDoll>();

    Element container;
    CanvasElement buffer;
    CanvasElement onScreen;
    ImageElement bg;
    ImageElement branches;
    ImageElement leaves;
    ImageElement flowers;
    ImageElement fruit;
    ImageElement eyes;

    World(Element parentContainer) {
        container = new DivElement();
        parentContainer.append(container);
    }



    Future<Null> initCanvasAndBuffer() async {
        //graphic of branches holding it up, yggdrasil style
        onScreen = new CanvasElement(width: width, height:height);
        container.append(onScreen);
        bg = await Loader.getResource(bgLocation);
        branches = await Loader.getResource("images/BGs/frame.png");
        container.append(branches);
        leaves = await Loader.getResource("images/BGs/frameLeaves.png");
        flowers = await Loader.getResource("images/BGs/frameFlowers.png");
        fruit = await Loader.getResource("images/BGs/frameFruit.png");
        eyes = await Loader.getResource("images/BGs/frameEyes.png");
        buffer = new CanvasElement(width: width, height: height);
    }

    Future<Null> render() async {
        if(buffer == null) await initCanvasAndBuffer();
        buffer.context2D.drawImage(bg,0,0);
    }


}