import 'Inventoryable/Fruit.dart';
import 'Inventoryable/Inventoryable.dart';
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
    String ominousMusic = "Music/Flow_on_Distorted_up";
    String happyMusic = "Music/Flow_on_2";

    static final int LEAFLEVEL = 13;
    static final int FLOWERLEVEL = 26;
    static final int FRUITLEVEL = 13*3;
    static final int MAXHEALTH = 13*4;
    static final int TENTACLELEVEL = -13;
    static final int EYELEVEL = -26;

    //HEALTH OF THE WORLD DETERMINES THE STATE OF THE TREE
    int health = 0;

    CustomCursor  cursor;
    //don't step on your own toes. need for cursor shit
    bool currentlyRendering = false;
    DateTime lastRender;
    //essentially the frame rate
    static int fps = 30;
    int minTimeBetweenRenders = (1000/fps).round();
    Inventoryable get activeItem => underWorld.player.inventory.activeItem;

    List<Tree> trees = new List<Tree>();

    UnderWorld underWorld;

    Element sky = querySelector("#sky");
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

    AudioElement backgroundMusic = querySelector("#bgAudio");
    SourceElement mp3 = querySelector("#mp3");
    SourceElement ogg = querySelector("#ogg");


    //don't redraw overworld unless you really have to
    bool overWorldDirty = true;


    World() {
        underWorld = new UnderWorld(this);

        //testTrees();
    }

    //it's a sub part of inventory now, don't do it's own thing
    Future<Null> setupElements(Element parentContainer) async {
        //want inventory on left, world on right
        await underWorld.player.drawInventory(parentContainer);
        container = underWorld.player.inventory.rightElement;
        //parentContainer.append(container);
    }

    void testTrees() {
        trees.add(new Tree(new TreeDoll(), 150, 300));
        trees.add(new Tree(new TreeDoll(), 300, 300));
        trees.add(new Tree(new TreeDoll(), 450, 300));
        trees.add(new Tree(new TreeDoll(), 600, 300));
    }



    Future<Null> initCanvasAndBuffer() async {
        //graphic of branches holding it up, yggdrasil style
        onScreen = new CanvasElement(width: width, height:height);

        onScreen.onMouseDown.listen((MouseEvent event) {
            processClickAtCursor();
        });

        onScreen.onMouseMove.listen((MouseEvent event)
        {
            if(activeItem != null) {
                //print("there is an active item so that should be my cursor");
                CanvasElement itemCanvas = activeItem.itemCanvas;
                Rectangle rect = onScreen.getBoundingClientRect();
                Point point = new Point(event.client.x-rect.left, event.client.y-rect.top);
                cursor = new CustomCursor(itemCanvas, point);
                overWorldDirty = true;
                render();
            }else {
                cursor = null;
            }
        });
        onScreen.context2D.font = "72px Papyrus";
        onScreen.context2D.fillStyle = "#ffffff";
        onScreen.context2D.fillText("LOADING",width/4,height/10);
        onScreen.classes.add("frameLayer");
        onScreen.style.pointerEvents = "auto";
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

    void changeMusic(String newMusicLocation) {
        int time = backgroundMusic.currentTime;
        //print("current music is ${backgroundMusic.src} time is $time");
        //backgroundMusic.src = "${newMusicLocation}.ogg";
        String old = mp3.src;
        //for some reason it is an absolute path even if i set it to relative
        old = old.split("/").last;
        String newString = "${newMusicLocation.split("/").last}.mp3";
        if(old == newString) {
            return; //nothing changed
        }
       // print("old music is ${old} and new music is $newString and I think they are different");

        mp3.src = "$newMusicLocation.mp3";
        mp3.type = "audio/mpeg";

        ogg.src = "$newMusicLocation.mp3";
        ogg.type = "audio/ogg";

        backgroundMusic.currentTime = time;
        backgroundMusic.play();

    }

    void showAndHideYgdrssylLayers() {
        if(health >= TENTACLELEVEL) {
            branches.style.display = "block";
            tentacles.style.display = "none";
            document.body.style.background = "linear-gradient(to bottom, #002d4a 0%,#002d4a 848px,#5d3726 848px,#5d3726 848px,#5d3726 100%); /* W3C */";
            changeMusic(happyMusic);
            document.title = "Land of Horticulture and Essence";
        }else {
            branches.style.display = "none";
            tentacles.style.display = "block";
            document.body.style.background = "linear-gradient(to bottom, #black 0%,black 848px,#5d3726 848px,#5d3726 848px,#5d3726 100%); /* W3C */";
            changeMusic(ominousMusic);
            document.title = "Land of Horrorticulture and Essence";
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

    bool canRender() {
        if(lastRender == null) return true;
        DateTime now = new DateTime.now();
        Duration diff = now.difference(lastRender);
        print("it's been ${diff.inMilliseconds} since last render, is that more than ${minTimeBetweenRenders}?");
        if(diff.inMilliseconds > minTimeBetweenRenders) {
            print("yes");
            return true;
        }
        return false;
    }

    void processClickAtCursor() {
        if(activeItem is Fruit) {
            plantATreeAtPoint(activeItem, cursor.position);
        }else {
            print("I don't know what to do with this!");
            //TODO handle ax
        }
    }

    void plantATreeAtPoint(Fruit fruit, Point point) {
        //just a logical result of the trees this fruit came from
        Doll treeDoll = Doll.breedDolls(fruit.parents);
        //ground level
        int y = 300;
        if(treeDoll is TreeDoll) {
            Tree tree = new Tree(treeDoll, point.x, y);
            trees.add(tree);
            overWorldDirty = true;
            cursor = null;
            underWorld.player.inventory.removeItem(fruit);
            render();
        }
    }


    Future<Null> render() async {
        if(buffer == null) await initCanvasAndBuffer();
        if(currentlyRendering || !canRender()) return;
        if(overWorldDirty) {
            currentlyRendering = true;
            print("rendering");
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

        if(cursor != null) {
            await cursor.render(buffer);
        }


        onScreen.context2D.drawImage(buffer, 0,0);
        lastRender = new DateTime.now();
        currentlyRendering = false;
    }


}

class CustomCursor {
    Point position;
    CanvasElement image;

    CustomCursor(CanvasElement this.image, Point this.position);

    Future<Null> render(CanvasElement canvas) async {
        print("rendering a cursor to ${position.x}, ${position.y}");
        canvas.context2D.drawImage(image, position.x, position.y);
    }
}