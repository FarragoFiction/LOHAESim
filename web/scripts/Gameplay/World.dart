import 'Tree.dart';
import 'UnderWorld.dart';
import 'dart:async';
import 'dart:html';
import "package:DollLibCorrect/DollRenderer.dart";
//yggdrasil
class World {
    int width = 800;
    int height = 1600;
    String bgLocation = "images/BGs/AlternianCliff.png";

    static final int LEAFLEVEL = 13;
    static final int FLOWERLEVEL = 26;
    static final int FRUITLEVEL = 13*3;
    static final int TENTACLELEVEL = -13;
    static final int EYELEVEL = -26;

    //HEALTH OF THE WORLD DETERMINES THE STATE OF THE TREE
    int health = 0;

    List<Tree> trees = new List<Tree>();

    UnderWorld underWorld = new UnderWorld();

    Element container;
    CanvasElement buffer;
    CanvasElement onScreen;
    ImageElement bg;
    ImageElement branches;
    ImageElement leaves;
    ImageElement flowers;
    ImageElement fruit;
    ImageElement eyes;
    ImageElement tentacles;

    //don't redraw overworld unless you really have to
    bool overWorldDirty = true;


    World(Element parentContainer) {
        container = new DivElement();
        container.classes.add("worldBase");
        parentContainer.append(container);
        //testTrees();


    }

    void testTrees() {
        trees.add(new Tree(new TreeDoll()..barren =true, 150, 300));
        trees.add(new Tree(new TreeDoll()..barren =true, 300, 300));
        trees.add(new Tree(new TreeDoll()..barren =true, 450, 300));
        trees.add(new Tree(new TreeDoll()..barren =true, 600, 300));
    }



    Future<Null> initCanvasAndBuffer() async {
        //graphic of branches holding it up, yggdrasil style
        onScreen = new CanvasElement(width: width, height:height);
        onScreen.context2D.font = "72px Papyrus";
        onScreen.context2D.fillStyle = "#ffffff";
        onScreen.context2D.fillText("LOADING",width/4,height/10);
        onScreen.classes.add("frameLayer");
        onScreen.id  = "worldCanvas";
        container.append(onScreen);
        bg = await Loader.getResource(bgLocation);
        branches = await Loader.getResource("images/BGs/frame.png");
        branches.classes.add("frameLayer");
        branches.style.display = "none";
        container.append(branches);

        tentacles = await Loader.getResource("images/BGs/frameTentacle.png");
        tentacles.classes.add("frameLayer");
        tentacles.style.display = "none";
        container.append(tentacles);


        leaves = await Loader.getResource("images/BGs/frameLeaves.png");
        container.append(leaves);
        leaves.style.display = "none";
        leaves.classes.add("frameLayer");

        flowers = await Loader.getResource("images/BGs/frameFlowers.png");
        flowers.classes.add("frameLayer");
        flowers.style.display = "none";
        container.append(flowers);

        fruit = await Loader.getResource("images/BGs/frameFruit.png");
        fruit.classes.add("frameLayer");
        fruit.style.display = "none";
        container.append(fruit);

        eyes = await Loader.getResource("images/BGs/frameEyes.png");
        eyes.classes.add("frameLayer");
        eyes.style.display = "none";
        container.append(eyes);
        buffer = new CanvasElement(width: width, height: height);
        showAndHideYgdrssylLayers();
    }

    void showAndHideYgdrssylLayers() {
        if(health >= TENTACLELEVEL) {
            branches.style.display = "block";
            tentacles.style.display = "none";
            document.body.style.backgroundColor = "#002d4a";
        }else {
            branches.style.display = "none";
            tentacles.style.display = "block";
            document.body.style.backgroundColor = "black";
        }

        if(health >=LEAFLEVEL) {
            leaves.style.display = "block";
        }else {
            leaves.style.display = "none";
        }

        if(health >=FRUITLEVEL) {
            fruit.style.display = "block";
        }else {
            fruit.style.display = "none";
        }

        if(health >=FLOWERLEVEL && health < FRUITLEVEL) {
            flowers.style.display = "block";
        }else {
            flowers.style.display = "none";
        }

        if(health <=EYELEVEL) {
            eyes.style.display = "block";
        }else {
            eyes.style.display = "none";
        }
    }

    Future<Null> render() async {
        if(buffer == null) await initCanvasAndBuffer();
        if(overWorldDirty) {
            Renderer.clearCanvas(buffer);
            buffer.context2D.fillStyle = "#5d3726";
            buffer.context2D.fillRect(0, 0, buffer.width, buffer.height);
            buffer.context2D.drawImage(bg, 0, 0);

            for (Tree tree in trees) {
                CanvasElement treeCanvas = await tree.canvas;
                buffer.context2D.drawImageScaled(
                    treeCanvas, tree.x, tree.y, tree.doll.width / 2,
                    tree.doll.width / 2);
            }
            overWorldDirty = false; //not dirty anymore, am drawing.
        }

        await underWorld.render(buffer);


        onScreen.context2D.drawImage(buffer, 0,0);

    }


}