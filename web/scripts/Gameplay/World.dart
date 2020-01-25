import 'package:CommonLib/Random.dart';
import 'package:LoaderLib/Loader.dart';
import 'package:RenderingLib/RendereringLib.dart';

import 'CollectableSecret.dart';
import 'Inventory.dart';
import 'Inventoryable/Ax.dart';
import 'Inventoryable/Bodypillow.dart';
import 'Inventoryable/Essence.dart';
import 'Inventoryable/Flashlight.dart';
import 'Inventoryable/Fruit.dart';
import 'Inventoryable/HelpingHand.dart';
import 'Inventoryable/Inventoryable.dart';
import 'Inventoryable/Record.dart';
import 'Inventoryable/YellowYard.dart';
import 'MusicSave.dart';
import 'OnScreenText.dart';
import 'Player.dart';
import 'Tree.dart';
import 'UnderWorld.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:CommonLib/Utility.dart';
import 'package:CommonLib/Compression.dart';
import "package:DollLibCorrect/DollRenderer.dart";
import "package:CommonLib/NavBar.dart";
//yggdrasil
class World {
    String gigglesnort = "";
    static World _instance;
    static World get instance {
        if(_instance == null) {
            new World();
        }
        return _instance;
    }
    static String labelPattern = ":___ ";
    static String SAVEKEY = "yggdrasilSAVEDATA";
    static String SHAREDKEY = "SHARED_DATA";
    MusicSave musicSave = new MusicSave();
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
    bool plotAlreadyPoppedUp = true;

    bool get bossDefeated => underWorld.nidhogg.dead || underWorld.nidhogg.purified;

    //HEALTH OF THE WORLD DETERMINES THE STATE OF THE TREE
    int health = 0;

    Record currentMusic;

    CustomCursor  cursor;
    //don't step on your own toes. need for cursor shit
    bool currentlyRendering = false;
    DateTime lastRender;
    //essentially the frame rate
    static int fps = 30;
    int get minTimeBetweenRenders => (1000/fps).round();
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

    Element fundsElement;
    Element fruitStatsElement;

    AudioElement backgroundMusic = querySelector("#bgAudio");
    AudioElement soundEffects = new AudioElement();
    SourceElement mp3 = querySelector("#mp3");
    SourceElement ogg = querySelector("#ogg");

    //dollstring, archived pairs, useful for record keeping and the like. doesn't have parents (since its meant to be the
    //archetypal fruit, not a specific one
    Map<String,ArchivedFruit> pastFruit = new Map<String, ArchivedFruit>();
    List<String> secretsForCalm = new List<String>();


    //don't redraw overworld unless you really have to
    bool overWorldDirty = true;

    //so i don't remove it mid render or some stupid shit
    List<Tree> treesToRemove = new List<Tree>();
    List<Tree> treesToAdd = new List<Tree>();

    bool get fraymotifActive {
        return underWorld.nidhogg.canDamage(currentMusic);
    }


    World([bool pleaseLoad = true]) {
        _instance = this;
        underWorld = new UnderWorld(this);
        currentMusic = new FlowOn(this);
        if(pleaseLoad) load();
        consortPrint("thwap!! thwap!! welcome to the Land of Horticulture and Essence!! or was it something else?? i guess it doesn't matter!!");
        owoPrint("New Friend! Let's explore these roots together!");
        window.onClick.listen((Event e) {
            backgroundMusic.play();
        });
    }

    void updateFunds(int amountToChange, [bool waitToSave]) {
        underWorld.player.funds += amountToChange;
        syncFunds();
        if(!waitToSave) save("funds updated");
    }

    //you guys do NOT know how good this feels to type
    void unlockAchievement(String name) {
        HttpRequest.getString("http://localhost:215/$name").then((String data) {
            consortPrint("thwap!! what is an 'achievement'?? can you eat it?? does it taste better if its a '$name'??");
        }).catchError((String error) {
            owoPrint("Oh no New Friend! You aren't on steam (or maybe there is a bug?) You can't GET achievements. Not even $name");
        });
    }



    void syncFunds() {
        int currentFruit = underWorld.player.numberFruit;
        int maxFruit = Inventory.FRUITLIMIT;
        String fruitText = "$currentFruit out of max $maxFruit fruit in Stack.";

        if(currentFruit >= maxFruit) {
            fruitText = "$fruitText Stack Overflow. Brightly colored fruits are rolling around everywhere. You are too distracted to pick more fruit. ";
        }else if(currentFruit > maxFruit - maxFruit/5) {
            fruitText = "$fruitText You should sell fruit to the Bard soon. Don't want a Stack Overflow, now do you?";
        }


        fundsElement.text = "Funds: \$${underWorld.player.funds}, ${fruitText},  Essences: ${underWorld.player.numberEssences}/13 $gigglesnort";
    }

    void save(String reason) {
        //print("saving... because $reason");
        if(backgroundMusic != null) musicSave.paused = backgroundMusic.paused;
        if(backgroundMusic != null) musicSave.volume = (backgroundMusic.volume*100).round();
        window.localStorage[SAVEKEY] = toDataString().toString();
        window.localStorage[SHAREDKEY] = sharedToDataString().toString();
    }

    void plotPopup() {
        jrPrint("Your name is Zawhei Bacama and it is time to grow trees. You know how important it is to perform your duties. You have waited your entire life to do this. Some of your friends don't understand this. But that's okay, they will soon see.");
        Element popup = new DivElement()..classes.add("plotPopup");
        container.append(popup);

        Element header = new DivElement()..text = "Welcome to the Land of Horticulture And Essence";
        header.classes.add("popupHeader");
        popup.append(header);

        Element textBody= new DivElement();
        popup.append(textBody);
        textBody.classes.add("popupBody");
        textBody.text = "Your name is Zawhei Bacama and it is time to grow trees. You have waited your entire life to do this. Some of your friends don't understand this. But that's okay, they will soon see.";
        popup.onClick.listen((Event e) {
            popup.remove();
        });
    }


    void load() {
        if(window.localStorage.containsKey(SAVEKEY)){
            String data = window.localStorage[SAVEKEY];
            copyFromDataString(data);
        }else {
            plotAlreadyPoppedUp = false;
            underWorld.player.initialInventory();
            initTrees();
        }
        if(window.localStorage.containsKey(SHAREDKEY)) {
            copySharedFromDataString(window.localStorage[SHAREDKEY]);
        }
        //print("loading...${underWorld.player.funds}} caegers");
        syncMusicToSave();
        fps = musicSave.fps;
        //not just the first time in case something goes wrong
        unlockAchievement("LOHAE");
    }

    void syncMusicToSave() {
        currentMusic = Record.getRecordFromName(musicSave.currentSong);
        if(backgroundMusic != null)backgroundMusic.volume = musicSave.volume/100;
        if(backgroundMusic != null)changeMusic(musicSave.currentSong,false); //won't do fraymotif stuff, but I am okay with this. reuse it dunkass
        if(musicSave.paused) {
            if(backgroundMusic != null)backgroundMusic.pause();
        }else {
            if(backgroundMusic != null)backgroundMusic.play(); //make sure its going (might not if it was the default song)
        }
    }

    String toDataString() {
        try {
            String ret = toJSON().toString();
            return "Ygdrassil$labelPattern${LZString.compressToEncodedURIComponent(ret)}";
        }catch(e) {
            print(e);
            print("Error Saving Data. Are there any special characters in there? ${toJSON()} $e");
        }
    }

    JSONObject toJSON() {
        JSONObject json = new JSONObject();
        json["bossFight"] = bossFight.toString();
        json["plotAlreadyPoppedUp"] = plotAlreadyPoppedUp.toString();

        json["player"] = underWorld.player.toJSON().toString();
        json["musicSave"] = musicSave.toJSON().toString();
        json["nidhogg"] = underWorld.nidhogg.toJSON().toString();
        List<JSONObject> treeArray = new List<JSONObject>();
        for(Tree tree in trees) {
            treeArray.add(tree.toJSON());
        }
        json["trees"] = treeArray.toString();

        List<JSONObject> fruitArray = new List<JSONObject>();
        for(ArchivedFruit fruit in pastFruit.values) {
            fruitArray.add(fruit.toJSON());
        }
        json["pastFruit"] = fruitArray.toString();
        return json;
    }

    void copyFromDataString(String dataString) {
        List<String> parts = dataString.split("$labelPattern");
        //print("parts are $parts");
        if(parts.length > 1) {
            dataString = parts[1];
        }

        //default assume data is compressed, okay?
        try {
            String rawJSON = LZString.decompressFromEncodedURIComponent(dataString);
            JSONObject json = new JSONObject.fromJSONString(rawJSON);
            copyFromJSON(json);
        }catch(e, trace) {
            print("error loading data, assuming legacy uncompressed (oh hi there beta tester, thanks for your hard work :) :) :) ), error was $e $trace");
            String rawJson = new String.fromCharCodes(base64Url.decode(dataString));
            JSONObject json = new JSONObject.fromJSONString(rawJson);
            copyFromJSON(json);
        }
    }

    void copyFromJSON(JSONObject json) {
        DateTime startTime = new DateTime.now();
        bossFight = json["bossFight"] ==true.toString();;
        //so it not existing means "show popup"
        plotAlreadyPoppedUp = json["plotAlreadyPoppedUp"] ==true.toString();;

        underWorld.player.copyFromJSON(new JSONObject.fromJSONString(json["player"]));
        if(json["nidhogg"] != null) {
            underWorld.nidhogg.copyFromJSON(new JSONObject.fromJSONString(json["nidhogg"]));
        }

        if(json["musicSave"] != null) {
            musicSave.copyFromJSON(new JSONObject.fromJSONString(json["musicSave"]));
        }

        new TimeProfiler("Loading Player", startTime);
        startTime = new DateTime.now();
        String idontevenKnow = json["trees"];
        loadTreesFromJSON(idontevenKnow);
        new TimeProfiler("Loading Trees", startTime);
        startTime = new DateTime.now();
        String idontevenKnow2 = json["pastFruit"];
        loadPastFruitFromJSON(idontevenKnow2);
        new TimeProfiler("Loading Archived Fruit", startTime);
    }


    JSONObject sharedToJSON() {
        JSONObject json = new JSONObject();
        json["SHARED_FUNDS"] = "${underWorld.player.funds}";
        json["CALM_SECRETS"] = secretsForCalm.join(",");
        return json;
    }

    String sharedToDataString() {
        try {
            String ret = sharedToJSON().toString();
            //print("the json string for shared data was $ret");
            //NOT compressed, for ease of accessing shared data
            return "${base64Url.encode(ret.codeUnits)}";
        }catch(e) {
            print(e);
            print("Error Saving Data. Are there any special characters in there? ${sharedToJSON()} $e");
        }
    }

    void copySharedFromDataString(String dataString) {
        //print("dataString is $dataString");
        String rawJson = new String.fromCharCodes(base64Url.decode(dataString));
        //print("rawJSON is $rawJson");
        JSONObject json = new JSONObject.fromJSONString(rawJson);
        //print("json is $json");
        copySharedFromJSON(json);
        underWorld.player.inventory.syncToSharedCalm();
    }

    void copySharedFromJSON(JSONObject json) {
        secretsForCalm = json["CALM_SECRETS"].split(",").where((s) => s.isNotEmpty).toList();
        underWorld.player.funds = int.parse(json["SHARED_FUNDS"]);

    }

    void loadTreesFromJSON(String idontevenKnow) {
        if(idontevenKnow == null) return;
        List<dynamic> what = jsonDecode(idontevenKnow);
        //print("what json is $what");
        for(dynamic d in what) {
            //print("dynamic json thing is  $d");
            JSONObject j = new JSONObject();
            j.json = d;
            //shit, okay i need to know what kind of object it is
            trees.add(new Tree(this, new TreeDoll(), 0,0)..copyFromJSON(j));
        }
    }

    void loadPastFruitFromJSON(String idontevenKnow) {
        if(idontevenKnow == null) return;
        List<dynamic> what = jsonDecode(idontevenKnow);
        //print("what json is $what");
        for(dynamic d in what) {
            //print("dynamic json thing is  $d");
            JSONObject j = new JSONObject();
            j.json = d;
            //shit, okay i need to know what kind of object it is
            ArchivedFruit fruit = (new ArchivedFruit(new FruitDoll())..copyFromJSON(j));
            pastFruit["${fruit.doll.seed}"] = fruit;
        }
    }

    //it's a sub part of inventory now, don't do it's own thing
    Future<Null> setupElements(Element parentContainer) async {
        //want inventory on left, world on right
        await underWorld.player.drawInventory(parentContainer);
        container = underWorld.player.inventory.rightElement;
        //only if theres shit on screen
        if(!plotAlreadyPoppedUp) {
            plotPopup();
            plotAlreadyPoppedUp = true;
        }

    }

    void makeFundsElement(Element parent) {
        fundsElement = new DivElement()..classes.add("funds");
        parent.append(fundsElement);
        syncFunds();
    }



    void initTrees() {
        Tree tree1 = new Tree(this,new TreeDoll(), 200, 550);
        trees.add(tree1);

        Tree tree2 = new Tree(this,new TreeDoll(), 500, 550);
        trees.add(tree2);

        tree1.grow(Tree.FLOWERS);
        tree2.grow(Tree.RIPEFRUIT);
    }



    Future<Null> initCanvasAndBuffer() async {
        //graphic of branches holding it up, yggdrasil style
        onScreen = new CanvasElement(width: width, height:height);
        onScreen.style.cursor = "none";

        onScreen.onMouseDown.listen((MouseEvent event) {
            processClickAtCursor(event);
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

    void playSoundEffect(String locationWithoutExtension) {
        if(soundEffects.canPlayType("audio/mpeg").isNotEmpty) soundEffects.src = "SoundFX/${locationWithoutExtension}.mp3";
        if(soundEffects.canPlayType("audio/ogg").isNotEmpty) soundEffects.src = "SoundFX/${locationWithoutExtension}.ogg";
        soundEffects.play();

    }

    bool musicAlreadyPlaying(String newMusicLocation) {
        String old = mp3.src;
        //for some reason it is an absolute path even if i set it to relative
        old = old.split("/").last;
        String newString = "${newMusicLocation.split("/").last}.mp3";
        if(old == newString) {
            return true; //nothing changed
        }
        return false;
    }


    void changeMusic(String newMusicLocation, bool sync) {
        //print("changing music to $newMusicLocation");
        int time = backgroundMusic.currentTime;
        //print("current music is ${backgroundMusic.src} time is $time");
        //backgroundMusic.src = "${newMusicLocation}.ogg";
        if(musicAlreadyPlaying(newMusicLocation)) return;
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
        musicSave.currentSong = newMusicLocation;
        save("changing music");
    }

    //wait what do you mean there are boss fights in this zen tree game???
    void activateBossFight() {
        unlockAchievement("Woke_Nidhogg");
        bossFightJustStarted = true;
        consortPrint("oh god why did you do this?? NIDHOGG IS AWAKE!! there's a reason we kept gnawing away the trees!! they give him life!!");
        consortPrint("oh right i remember now, LOHAE is also the land of HORRORTICULTURE and ESSENCE. how could i forget that?");
        if(getParameterByName("haxMode") == "on") {
            jrPrint("Oh hey there, I see you haxxing my codes. Any ideas about what you should be doing with the power to plant trees anywhere??? In this trying time. Against the Denizen of Life???");
        }
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
        unlockAchievement("purified_nidhogg");
        bossFight = false;
        overWorldDirty = true;
        print("about to be uncorrupting trees");
        for(Tree tree in trees) {
            tree.uncorrupt();
        }
        underWorld.player.inventory.unlockHidden();
        render();
    }


    void nidhoggDies() {
        owoPrint("New Friend!!! You did it!!! Nidhogg is defeated!!! You were so smart to try the Fraymotif!!!");
        consortPrint("thwap!! now we can grow our trees in peace, thwap!!");
        unlockAchievement("Killed_Nidhogg");
        bossFight = false;
        overWorldDirty = true;
        for(Tree tree in trees) {
            tree.uncorrupt();
        }

        underWorld.player.inventory.unlockHidden();
        render();
        save("Nidhogg died");
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


    void processClickAtCursor(MouseEvent event) {
        underWorld.nidhogg.checkPurity(activeItem, cursor.position);
        if(activeItem is Fruit) {
            if(trees.length <= maxTrees) {
                plantATreeAtPoint(activeItem, cursor.position);
                underWorld.player.inventory.removeItem(activeItem);
                save("i planted a tree");
            }else {
                window.alert("Patience, you have too many trees right now.");
            }
        }else if(activeItem is Essence) {
            plantAWigglerAtPoint(activeItem, cursor.position);
            //guess who is alive again. it's nidhogg. nidhogg is alive again
            if(!underWorld.nidhogg.purified) {
                owoPrint("Uh. New Friend? I think Nidhogg just respawned... ");
                consortPrint("thawp!! oh no!! its the Lifey Thing!!");
            }

            underWorld.nidhogg.hp = 4037;
            underWorld.player.inventory.removeItem(activeItem);
            save("planted an essence");
        }else if(activeItem is Record) {
            if(musicAlreadyPlaying((activeItem as Record).songName)){
                window.alert("You're already playing this song!!!");
            }else{
                currentMusic = activeItem;
                changeMusic((activeItem as Record).songName, false);
            }
        }else if(activeItem is Ax) {
            removeTreePopup();
            event.stopPropagation(); //don't give it to other things
        }else if(activeItem is Flashlight) {
            activateFlashlight();
        }else if(activeItem is HelpingHandPlusUltra) {
            pickFruit(true);
            save("picked all fruit but again");
        }else if(activeItem is HelpingHandCorrupt) {
            omniFruit();
            save("picked all fruit");
        }else if(activeItem is HelpingHand) {
            pickFruit();
            save("picked fruit");
        }else if(activeItem is YellowYard) {
            cycleTreePopup();
            event.stopPropagation(); //don't give it to other things
        }else if(activeItem is BodyPillow) {
            cycleNidhogg();
            event.stopPropagation(); //don't give it to other things
        }else {
            consortPrint("i don't know what to do with this!! thwap!! thwap!!");
        }
    }

    void cycleNidhogg() {
        print("active item is $activeItem with img loc of ${(activeItem as CollectableSecret).imgLoc}");
        if(underWorld.nidhogg.purified) {
            underWorld.nidhogg.corrupt();
            save("pillow");
        }else {
            underWorld.nidhogg.purify();
            save("pillow");

        }

    }


    //despap citato is a good bean
    void pickFruit([bool omni = false]) {
        //print("trying to pick fruit");
        //tell all trees to process this. first tree to return a fruit ends things.
        underWorld.player.reactToPap(cursor.position);
        if(underWorld.player.fruitOverflow) {
            window.alert("Fruit Overflow: You are too busy picking up all your damn fruit to pick more. Better sell some to the Bard.");
            return;
        }
        for(Tree tree in trees) {
            //print("is it $tree I'm looking for? stage is ${tree.stage}");
            //don't pick flowers or whatever
            if(tree.stage >= Tree.FRUIT) {
               // print("${tree.stage} is past fruit");
                PositionedDollLayer fruitLayer = tree.fruitPicked(cursor.position);
                if (fruitLayer != null) {
                     //print("i found a fruit, it's name is ${fruitLayer.doll.dollName}, it's seed is ${fruitLayer.doll.seed}");
                    if(omni) {
                        //consortPrint("thwap!! uh. that. sure is. an interesting. technique for fruit picking you have there??");
                        tree.produceFruitOmni(floweringTrees);
                    }else {
                        tree.produceFruit(fruitLayer, floweringTrees);
                    }
                    //https://freesound.org/people/morganpurkis/sounds/396012/
                    playSoundEffect("396012__morganpurkis__rustling-grass-3");
                    //if that was your last fruit, you're slated for removal.
                    if (!tree.doll.hasHangablesAlready()) treesToRemove.add(tree);
                }
            }
        }
        syncFunds();
    }

    //despap citato is a good bean. even if corrupt.
    //no wonder where you click, harvest all fruit
    void omniFruit() {
        //print("trying to pick fruit");
        //tell all trees to process this. first tree to return a fruit ends things.
        if(underWorld.player.fruitOverflow) {
            window.alert("Fruit Overflow: You are too busy picking up all your damn fruit to pick more. Better sell some to the Bard.");
            return;
        }
        for(Tree tree in trees) {
            //print("is it $tree I'm looking for? stage is ${tree.stage}");
            //don't pick flowers or whatever
            if(tree.stage >= Tree.FRUIT) {
                consortPrint("thwap!! uh. that. sure is. an interesting. technique for fruit picking you have there??");
                tree.produceFruitOmni(floweringTrees);
                //https://freesound.org/people/morganpurkis/sounds/396012/
                playSoundEffect("396012__morganpurkis__rustling-grass-3");
                //if that was your last fruit, you're slated for removal.
                if (!tree.doll.hasHangablesAlready()) treesToRemove.add(tree);
            }
        }
        syncFunds();
    }

    void activateFlashlight() {
        owoPrint("Oh! I can see! What's this?");
        underWorld.player.hasActiveFlashlight = true;
        render();
    }

    void cycleTreePopup() {
        consortPrint("thwap!! thwap!! Grow that tree!");
        DivElement axContainer = new DivElement();
        if(trees.length < 7) axContainer.style.overflowX = "hidden";
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
        DivElement axContainer = new DivElement();
        axContainer.classes.add("popupParents");
        axContainer.id = "axContainer";
        if(trees.length < 7) axContainer.style.overflowX = "hidden";

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

            //right now i can't click a tree in the popup and also have popups consitently
            parentDiv.onMouseDown.listen((Event e)
            {
                consortPrint("thwap!! thwap!! Gnaw that tree!");
                parentDiv.remove();
                treesToRemove.add(tree);
                unmoveOwO(tree.doll);
                render(true);
                e.stopPropagation(); //don't give it to other things

                //if i remove all trees, then remove popup
                if(treesToRemove.length == trees.length) {
                    underWorld.player.inventory.popup.dismiss();
                }
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

            parentDiv.onMouseDown.listen((Event e)
            {
                tree.grow();
                render(true);
                e.stopPropagation(); //don't give it to other things

            });
        }

    }

    void removeTrees() {
        for(Tree tree in treesToRemove) {
            trees.remove(tree);
            overWorldDirty = true; //since i removed a tree, need to update graphics
        }
        if(treesToRemove.isNotEmpty) save("removed trees");

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
        if(treesToAdd.isNotEmpty) save("added tree");

        treesToAdd.clear();
    }

    void plantATreeAtPoint(Fruit fruit, Point point) {
        fruit.debugParents();
        if(bossFight) {
            consortPrint("no the denizen is awake these trees are BAD!!");
        }else if(!underWorld.nidhogg.dead && !underWorld.nidhogg.purified) {
            consortPrint(
                "thwap!! are you sure it's a good idea to plant all these trees?? The Denizen might wake up... he's SCARY!!");
        }else {
            consortPrint("thwap!! thwap!! we can plant as many trees as we want now that NIDHOGG isnt sleeping anymore");
        }
        //just a logical result of the trees this fruit came from
        Doll treeDoll = Doll.breedDolls(fruit.parents);
        //ground level
        //bottom center
        int y = 550;
        int x = point.x;
        int buffer = 100;
        if(x <buffer) x = buffer;
        if(x > width-buffer) x = width-buffer;

        if(getParameterByName("haxMode") == "on") {
            y = point.y; //plant base where you click
        }
        if(treeDoll is TreeDoll) {
            Tree tree = new Tree(this,treeDoll, x, y);
            //print("the bred doll has a fruit template of ${tree.doll.fruitTemplate}");
            treesToAdd.add(tree);
            overWorldDirty = true;
            cursor = null;
            moveOwO(treeDoll);
            if(bossFight) tree.corrupt();
            render();
        }
    }

    void plantAWigglerAtPoint(Essence essence, Point point) {
        owoPrint("Oh! New Friend! I didn't know you were an AUXILIATRIX!!");
        unlockAchievement("myserty");
        //just a logical result of the trees this fruit came from
        TreeDoll treeDoll = new TreeDoll();
        treeDoll.copyPalette(essence.palette);
        HomestuckGrubDoll grub = new HomestuckGrubDoll();
        //no faces
        grub.mouth.imgNumber = 0;
        grub.leftEye.imgNumber = 0;
        grub.rightEye.imgNumber = 0;
        Random rand = new Random();
        rand.nextInt(); //init
        //now that you can swap between purified and corrupt no more random
        if(underWorld.nidhogg.purified) {
            grub.copyPalette(ReferenceColours.PURIFIED);
        }else {
            grub.copyPalette(ReferenceColours.CORRUPT);
        }
        //grubs are corrupt, except they are the same cast as the essence
        grub.palette.add(HomestuckPalette.ASPECT_LIGHT, treeDoll.palette[HomestuckPalette.ASPECT_LIGHT], true);
        grub.palette.add(HomestuckPalette.ASPECT_DARK, treeDoll.palette[HomestuckPalette.ASPECT_DARK], true);
        treeDoll.fruitTemplate = grub;
        //ground level
        //bottom center
        int y = 550;
        int x = point.x;

        if(getParameterByName("haxMode") == "on") {
            y = point.y; //plant base where you click
        }
        if(treeDoll is TreeDoll) {
            Tree tree = new Tree(this,treeDoll, x, y);
            tree.grow(4); //insta fully grown
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
        //make sure it's the right time
        try {
            await window.animationFrame;
            await render(true);
            //if it needs to interupt it will, but no faster than min Time
            //TODO turn this back on
        }catch(e, trace) {
            print("there was an error rendering and i don't know why. $e $trace");
        }
        new Timer(new Duration(milliseconds: minTimeBetweenRenders), () => renderLoop());

    }


    Future<Null> render([bool force]) async {
        removeTrees(); //even if you don't render, do this shit.
        addTrees();
        if(buffer == null) await initCanvasAndBuffer();
        if(!force && (currentlyRendering || !canRender())) return;
        if(overWorldDirty || force) {
            currentlyRendering = true;
            //print("rendering at $fps fps or $minTimeBetweenRenders min time between renders");
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

class TimeProfiler {
    String label;
    DateTime start;
    DateTime end;

    TimeProfiler(String this.label, DateTime this.start) {
        end = new DateTime.now();
        Duration diff = end.difference(start);
        print("$label stopped after ${diff.inMilliseconds} ms.");
    }
}