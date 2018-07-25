import 'Inventoryable/Ax.dart';
import 'Inventoryable/Flashlight.dart';
import 'Inventoryable/Fruit.dart';
import 'Inventoryable/HelpingHand.dart';
import 'Inventoryable/Inventoryable.dart';
import 'Inventoryable/Record.dart';
import 'Inventoryable/YellowYard.dart';
import 'OnScreenText.dart';
import 'Player.dart';
import 'Tree.dart';
import 'UnderWorld.dart';
import 'dart:async';
import 'dart:html';
import "package:DollLibCorrect/DollRenderer.dart";
import "package:CommonLib/NavBar.dart";
//yggdrasil
class World {
    int width = 800;
    int height = 1600;
    String bgLocation = "images/BGs/AlternianCliff.png";
    String bgLocationCorrupt = "images/BGs/AlternianCliffCorrupt.png";
    String ominousMusic = "Music/Flow_on_Distorted_up";
    String happyMusic = "Music/Flow_on_2";

    static final int LEAFLEVEL = 13;
    static final int FLOWERLEVEL = 26;
    static final int FRUITLEVEL = 13*3;
    static final int MAXHEALTH = 13*4;
    static final int TENTACLELEVEL = -13;
    static final int EYELEVEL = -26;
    bool bossFightJustStarted = false;


    bool bossFight = false;

    //HEALTH OF THE WORLD DETERMINES THE STATE OF THE TREE
    int health = 0;

    Record currentMusic;

    CustomCursor  cursor;
    //don't step on your own toes. need for cursor shit
    bool currentlyRendering = false;
    DateTime lastRender;
    //essentially the frame rate
    static int fps = 45;
    int minTimeBetweenRenders = (1000/fps).round();
    Inventoryable get activeItem => underWorld.player.inventory.activeItem;

    List<Tree> trees = new List<Tree>();
    //flower and fruit both , even if in reality what matters is when both are flowering
    //this is a shortcut because fruit parentage is decided when you pick it, at least for now
    List<Tree> get floweringTrees =>trees.where((Tree t) => t.stage >= Tree.FLOWERS);

    int maxTrees = 8;
    List<OnScreenText> texts = new List<OnScreenText>();
    List<OnScreenText> textsToAdd = new List<OnScreenText>();

    UnderWorld underWorld;

    Element sky = querySelector("#sky");
    Element container;
    CanvasElement buffer;
    CanvasElement onScreen;
    ImageElement bg;
    ImageElement bgCorrupt;
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

    //so i don't remove it mid render or some stupid shit
    List<Tree> treesToRemove = new List<Tree>();
    List<Tree> treesToAdd = new List<Tree>();

    bool get fraymotifActive {
        return underWorld.nidhogg.canDamage(currentMusic);
    }


    World() {
        underWorld = new UnderWorld(this);
        currentMusic = new FlowOn(this);
        testTrees();
        consortPrint("thwap!! thwap!! welcome to the Land of Horticulture and Essence!! or was it something else?? i guess it doesn't matter!!");
        owoPrint("New Friend! Let's explore these roots together!");
    }

    //it's a sub part of inventory now, don't do it's own thing
    Future<Null> setupElements(Element parentContainer) async {
        //want inventory on left, world on right
        await underWorld.player.drawInventory(parentContainer);
        container = underWorld.player.inventory.rightElement;
    }

    void testTrees() {
        Tree tree = new Tree(this,new TreeDoll(), 50, 550);
        tree.stage = Tree.SAPPLING;
        trees.add(tree);
        tree = new Tree(this,new TreeDoll(), 200, 550);
        tree.stage = Tree.LEAVES;
        trees.add(tree);

        tree = new Tree(this,new TreeDoll(), 350, 550);
        tree.stage = Tree.FLOWERS;
        trees.add(tree);

        tree = new Tree(this,new TreeDoll(), 500, 550);
        tree.stage = Tree.FRUIT;
        trees.add(tree);

        tree = new Tree(this,new TreeDoll(), 600, 550);
        tree.stage = Tree.RIPEFRUIT;
        trees.add(tree);
    }



    Future<Null> initCanvasAndBuffer() async {
        //graphic of branches holding it up, yggdrasil style
        onScreen = new CanvasElement(width: width, height:height);

        onScreen.onMouseDown.listen((MouseEvent event) {
            processClickAtCursor();
        });

        onScreen.onMouseMove.listen((MouseEvent event)
        {
            if(activeItem == null)underWorld.player.inventory.helpingHand();

            if(activeItem != null) {
                //print("there is an active item so that should be my cursor");
                CanvasElement itemCanvas = activeItem.itemCanvas;
                Rectangle rect = onScreen.getBoundingClientRect();
                Point point = new Point(event.client.x-rect.left, event.client.y-rect.top);
                cursor = new CustomCursor(itemCanvas, point);
                if(activeItem is HelpingHand) cursor.mode = CustomCursor.BOTTOMRIGHT;
                overWorldDirty = true;
                //render(); render loop does this now
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
        bgCorrupt = await Loader.getResource(bgLocationCorrupt);
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

    void changeMusic(String newMusicLocation, bool sync) {
        //print("changing music to $newMusicLocation");
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

        ogg.src = "$newMusicLocation.ogg";
        ogg.type = "audio/ogg";
        //print("can i play mp3? ${backgroundMusic.canPlayType("audio/mpeg")} can i play ogg? ${backgroundMusic.canPlayType("audio/ogg")} ");

        if(backgroundMusic.canPlayType("audio/mpeg").isNotEmpty) backgroundMusic.src = "Music/${newMusicLocation}.mp3";
        if(backgroundMusic.canPlayType("audio/ogg").isNotEmpty) backgroundMusic.src = "Music/${newMusicLocation}.ogg";

        if(sync)backgroundMusic.currentTime = time;

        if(fraymotifActive && bossFight) {
            backgroundMusic.currentTime = 20;
        }
        consortPrint("you know they say the Prince could Play the Vines. I wonder if it would sound like this??");

        //print("actually playing new music $newMusicLocation");
        backgroundMusic.play();

    }

    //wait what do you mean there are boss fights in this zen tree game???
    void activateBossFight() {
        bossFightJustStarted = true;
        consortPrint("oh god why did you do this?? NIDHOGG IS AWAKE!! there's a reason we kept gnawing away the trees!! they give him life!!");
        bossFight = true;
        //show 'then perish'
        ImageElement thenPerish = new ImageElement(src: "images/BGs/thenperish.png");
        thenPerish.classes.add("thenPerish");
        container.append(thenPerish);
        thenPerish.onClick.listen((Event e) {
            thenPerish.remove();
        });

        for(Tree tree in trees) {
            tree.corrupt();
        }
        overWorldDirty = true;
        render();
    }



    void nidhoggSleeps() {
        owoPrint("Oh, whew!!! New Friend, Nidhogg sleeps again. We better be careful not to wake him!!!");
        bossFight = false;
        underWorld.player.topLeftX = underWorld.width;
        underWorld.player.topLeftY = 0;
        overWorldDirty = true;
        render();
    }

    void nidhoggPurified() {
        owoPrint("!!! New Friend!!! You did it!!! You purified that meany Nidhogg!!!");
        bossFight = false;
        overWorldDirty = true;
        print("about to be uncorrupting trees");
        for(Tree tree in trees) {
            tree.uncorrupt();
        }
        underWorld.player.inventory.unlockHidden();
        print("about to render");
        render();
        print("purify render is done");
    }


    void nidhoggDies() {
        owoPrint("New Friend!!! You did it!!! Nidhogg is defeated!!! You were so smart to try the Fraymotif!!!");
        consortPrint("thwap!! now we can grow our trees in piece, thwap!!");
        bossFight = false;
        overWorldDirty = true;
        for(Tree tree in trees) {
            tree.uncorrupt();
        }

        underWorld.player.inventory.unlockHidden();
        render();
    }


    void showAndHideYgdrssylLayers() {
        if(health <= TENTACLELEVEL || bossFight) {
            if(bossFightJustStarted)consortPrint("Oh god oh god oh god what do we do!!??");
            branches.style.display = "none";
            tentacles.style.display = "block";
            document.body.style.background = "linear-gradient(to bottom, #black 0%,black 848px,#5d3726 848px,#5d3726 848px,#5d3726 100%); /* W3C */";
            changeMusic(currentMusic.creepy, true);
            document.title = "Land of Horrorticulture and Essence";
        }else {
            branches.style.display = "block";
            tentacles.style.display = "none";
            document.body.style.background = "linear-gradient(to bottom, #002d4a 0%,#002d4a 848px,#5d3726 848px,#5d3726 848px,#5d3726 100%); /* W3C */";
            changeMusic(currentMusic.happy, true);
            document.title = "Land of Horticulture and Essence";
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
       // print("it's been ${diff.inMilliseconds} since last render, is that more than ${minTimeBetweenRenders}?");
        if(diff.inMilliseconds > minTimeBetweenRenders) {
            //print("yes");
            return true;
        }
        return false;
    }


    void processClickAtCursor() {
        underWorld.nidhogg.checkPurity(activeItem, cursor.position);
        if(activeItem is Fruit) {
            plantATreeAtPoint(activeItem, cursor.position);
            underWorld.player.inventory.removeItem(activeItem);
        }else if(activeItem is Record) {
            currentMusic = activeItem;
            changeMusic((activeItem as Record).songName, false);
        }else if(activeItem is Ax) {
            removeTreePopup();
        }else if(activeItem is Flashlight) {
            activateFlashlight();
        }else if(activeItem is HelpingHand) {
            pickFruit();
        }else if(activeItem is YellowYard) {
            cycleTreePopup();
        }else {
            consortPrint("i don't know what to do with this!! thwap!! thwap!!");
        }
    }


    //despap citato is a good bean
    void pickFruit() {
        //print("trying to pick fruit");
        //tell all trees to process this. first tree to return a fruit ends things.
        for(Tree tree in trees) {
            //print("is it $tree I'm looking for? stage is ${tree.stage}");
            //don't pick flowers or whatever
            if(tree.stage >= Tree.FRUIT) {
                print("${tree.stage} is past fruit");
                PositionedDollLayer fruitLayer = tree.fruitPicked(cursor.position);
                if (fruitLayer != null) {
                     //print("i found a fruit, it's name is ${fruitLayer.doll.dollName}, it's seed is ${fruitLayer.doll.seed}");
                    tree.produceFruit(fruitLayer, floweringTrees);
                    //if that was your last fruit, you're slated for removal.
                    if (!tree.doll.hasHangablesAlready()) treesToRemove.add(tree);
                }
            }
        }
    }

    void activateFlashlight() {
        owoPrint("Oh! I can see! What's this?");
        underWorld.player.hasActiveFlashlight = true;
        render();
    }

    void cycleTreePopup() {
        consortPrint("thwap!! thwap!! Grow that tree!");
        DivElement axContainer = new DivElement();
        axContainer.classes.add("parentHorizontalScroll");
        axContainer.classes.add("popupParents");
        axContainer.id = "yellowContainer";
        List<CanvasElement> pendingCanvases = new List<CanvasElement>();
        for(Tree tree in trees) {
            CanvasElement parentDiv = new CanvasElement(width: 80, height: 80);
            parentDiv.classes.add("parentBox");
            pendingCanvases.add(parentDiv);
        }

        underWorld.player.inventory.popup.displayElement(axContainer, "Super charge a Tree's Life?");
        finishDrawingTreesYellow(pendingCanvases, axContainer);

    }

    void removeTreePopup() {
        consortPrint("thwap!! thwap!! Gnaw that tree!");
        DivElement axContainer = new DivElement();
        axContainer.classes.add("parentHorizontalScroll");
        axContainer.classes.add("popupParents");
        axContainer.id = "axContainer";
        List<CanvasElement> pendingCanvases = new List<CanvasElement>();
        for(Tree tree in trees) {
            CanvasElement parentDiv = new CanvasElement(width: 80, height: 80);
            parentDiv.classes.add("parentBox");
            pendingCanvases.add(parentDiv);
        }

        underWorld.player.inventory.popup.displayElement(axContainer, "Chop Down a Tree???");
        finishDrawingTrees(pendingCanvases, axContainer);

    }

    Future<Null> finishDrawingTrees(List<CanvasElement> pendingCanvases, Element parentDivContainer) async {
        for(Tree tree in trees) {
            CanvasElement parentDiv = pendingCanvases[trees.indexOf(tree)];
            parentDiv.style.border = "1px solid black";
            CanvasElement parentCanvas = await tree.canvas;
            Renderer.drawToFitCentered(parentDiv, parentCanvas);
            parentDivContainer.append(parentDiv);
            parentDiv.onMouseEnter.listen((Event e)
            {
                parentDiv.style.backgroundColor = "purple";
            });

            parentDiv.onMouseLeave.listen((Event e)
            {
                parentDiv.style.backgroundColor = "transparent";
            });

            parentDiv.onMouseUp.listen((Event e)
            {
                parentDiv.remove();
                treesToRemove.add(tree);
                unmoveOwO(tree.doll);
                render(true);
            });
        }

    }

    Future<Null> finishDrawingTreesYellow(List<CanvasElement> pendingCanvases, Element parentDivContainer) async {
        for(Tree tree in trees) {
            CanvasElement parentDiv = pendingCanvases[trees.indexOf(tree)];
            parentDiv.style.border = "1px solid black";
            CanvasElement parentCanvas = await tree.canvas;
            Renderer.drawToFitCentered(parentDiv, parentCanvas);
            parentDivContainer.append(parentDiv);
            parentDiv.onMouseEnter.listen((Event e)
            {
                parentDiv.style.backgroundColor = "yellow";
            });

            parentDiv.onMouseLeave.listen((Event e)
            {
                parentDiv.style.backgroundColor = "transparent";
            });

            parentDiv.onMouseUp.listen((Event e)
            {
                tree.grow();
                render(true);
            });
        }

    }

    void removeTrees() {
        for(Tree tree in treesToRemove) {
            trees.remove(tree);
            overWorldDirty = true; //since i removed a tree, need to update graphics
        }
        treesToRemove.clear();
        if(bossFight && trees.isEmpty) {
            nidhoggSleeps();
        }
    }

    void addTrees() {
        for(Tree tree in treesToAdd) {
            trees.add(tree);
            overWorldDirty = true; //since i removed a tree, need to update graphics
        }
        treesToAdd.clear();
    }

    void plantATreeAtPoint(Fruit fruit, Point point) {
        if(bossFight) {
            consortPrint("no the denizen is awake these trees are BAD!!");
        }else {
            consortPrint(
                "thwap!! are you sure it's a good idea to plant all these trees?? The Denizen might wake up... he's SCARY!!");
        }
        //just a logical result of the trees this fruit came from
        Doll treeDoll = Doll.breedDolls(fruit.parents);
        //ground level
        //bottom center
        int y = 550;
        int x = point.x;

        if(getParameterByName("haxMode") == "on") {
            y = point.y - treeDoll.height/2; //plant base where you click
        }
        if(treeDoll is TreeDoll) {
            Tree tree = new Tree(this,treeDoll, x, y);
            treesToAdd.add(tree);
            overWorldDirty = true;
            cursor = null;
            moveOwO(treeDoll);
            if(bossFight) tree.corrupt();
            render();
        }
    }

    //???
    void moveOwO(TreeDoll tree) {
        if(tree.form is BushForm) {
            underWorld.player.down();
        }else if (tree.form is LeftForm) {
            underWorld.player.left();
        }else if (tree.form is RightFrom) {
            underWorld.player.right();
        }else if (tree.form is TreeForm) {//tree form has to be at bottom because it's the parent class
            underWorld.player.up();
        }
    }

    //for when you need to undo your movement, ax no questions
    void unmoveOwO(TreeDoll tree) {
        if(tree.form is BushForm) {
            underWorld.player.up();
        }else if (tree.form is RightFrom) {
            underWorld.player.left();
        }else if (tree.form is LeftForm) {
            underWorld.player.right();
        }else if (tree.form is TreeForm) {//tree form has to be at bottom because it's the parent class
            underWorld.player.down();
        }
    }

    void addTexts() {
        for(OnScreenText text in textsToAdd) {
            texts.add(text);
        }
        textsToAdd.clear();
    }

    void doText() {
        List<OnScreenText> toRemove = new List<OnScreenText>();
        addTexts();
        for(OnScreenText text in texts) {
            text.render(buffer);
            //if the fraymotif is active, interupt what you were saying and be in pain instead
            if(fraymotifActive && text is NidhoggText && !(text is NidhoggPain)){
                toRemove.add(text);
            }else if(underWorld.nidhogg.purified && text is NidhoggText && !(text is NidhoggPride)){
                toRemove.add(text);
            }else if(text.finished ) {
                toRemove.add(text);
            }else if((!bossFight && (text is HPNotification || text is NidhoggText && !(text is NidhoggPride)))) {
                //if nidhogg isn't on screen, interupt what you were saying, unless purified
                toRemove.add(text);
            }
        }

        for(OnScreenText text in toRemove) {
            texts.remove(text);
        }
    }

    Future<Null> doTrees() async {
        for (Tree tree in trees) {
            await tree.render(buffer);
        }
    }

    Future<Null> renderLoop()async {
        await render(true);
        //if it needs to interupt it will, but no faster than min Time
        //TODO turn this back on
        new Timer(new Duration(milliseconds: minTimeBetweenRenders), () => renderLoop());

    }


    Future<Null> render([bool force]) async {
        removeTrees(); //even if you don't render, do this shit.
        addTrees();
        if(buffer == null) await initCanvasAndBuffer();
        if(!force && (currentlyRendering || !canRender())) return;
        if(overWorldDirty || force) {
            currentlyRendering = true;
            //print("rendering");
            //Renderer.clearCanvas(buffer);
            buffer.context2D.fillStyle = "#5d3726";
            //makes sure the part between roots and ground is clear
            buffer.context2D.fillRect(0, 0, buffer.width, buffer.height);
            if(!bossFight) {
                buffer.context2D.drawImage(bg, 0, 0);
            }else {
                buffer.context2D.drawImage(bgCorrupt, 0, 0);
            }

            overWorldDirty = false; //not dirty anymore, am drawing.
        }


        await underWorld.render(buffer);

        //for reasons, make sure trees are over even dirt
        await doTrees();

        doText();
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
    static int MIDDLE = 0;
    static int TOPLEFT = -1;
    static int BOTTOMRIGHT = 1;

    int mode = MIDDLE;

    CustomCursor(CanvasElement this.image, Point this.position);

    Future<Null> render(CanvasElement canvas) async {
        //print("rendering a cursor to ${position.x}, ${position.y}");
        num x = position.x;
        num y = position.y;
        if(mode == BOTTOMRIGHT) {
            x = position.x - image.width;
            y = position.y - image.height;
        }else if(mode == MIDDLE) {
            x = position.x - image.width/2;
            y = position.y - image.height/2;
        }
        canvas.context2D.drawImage(image, x, y);
    }
}