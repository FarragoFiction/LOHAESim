import 'Tree.dart';
import 'dart:async';
import 'dart:html';
import "package:DollLibCorrect/DollRenderer.dart";
//yggdrasil
class World {
    int width = 800;
    int height = 1600;
    String bgLocation = "images/BGs/AlternianCliff.png";

    List<Tree> trees = new List<Tree>();

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
        container.classes.add("worldBase");
        parentContainer.append(container);
        //TODO init sample tree
        trees.add(new Tree(new TreeDoll(), 0, 300));
        trees.add(new Tree(new TreeDoll(), 150, 300));
        trees.add(new Tree(new TreeDoll(), 300, 300));
        trees.add(new Tree(new TreeDoll(), 450, 300));
        trees.add(new Tree(new TreeDoll(), 600, 300));
        trees.add(new Tree(new TreeDoll(), 750, 300));


    }



    Future<Null> initCanvasAndBuffer() async {
        //graphic of branches holding it up, yggdrasil style
        onScreen = new CanvasElement(width: width, height:height);
        onScreen.classes.add("frameLayer");
        onScreen.id  = "worldCanvas";
        container.append(onScreen);
        bg = await Loader.getResource(bgLocation);
        branches = await Loader.getResource("images/BGs/frame.png");
        branches.classes.add("frameLayer");
        //TODO procedurally decide which goes on screen.
        container.append(branches);
        leaves = await Loader.getResource("images/BGs/frameLeaves.png");
        container.append(leaves);

        leaves.classes.add("frameLayer");
        flowers = await Loader.getResource("images/BGs/frameFlowers.png");
        flowers.classes.add("frameLayer");
        container.append(flowers);

        fruit = await Loader.getResource("images/BGs/frameFruit.png");
        fruit.classes.add("frameLayer");
        eyes = await Loader.getResource("images/BGs/frameEyes.png");
        eyes.classes.add("frameLayer");
        //container.append(eyes);
        buffer = new CanvasElement(width: width, height: height);
    }

    Future<Null> render() async {
        if(buffer == null) await initCanvasAndBuffer();
        buffer.context2D.fillStyle = "#5d3726";
        buffer.context2D.fillRect(0, 0, buffer.width, buffer.height);
        buffer.context2D.drawImage(bg,0,0);

        for(Tree tree in trees) {
            CanvasElement treeCanvas = await tree.canvas;
            buffer.context2D.drawImageScaled(treeCanvas, tree.x, tree.y, tree.doll.width/2, tree.doll.width/2);
        }

        onScreen.context2D.drawImage(buffer, 0,0);

    }


}