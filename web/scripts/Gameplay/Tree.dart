import 'Inventoryable/Fruit.dart';
import 'World.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:CommonLib/NavBar.dart';
import 'package:DollLibCorrect/DollRenderer.dart';
import 'package:CommonLib/Utility.dart';
import "dart:math" as Math;

class Tree {
    static String labelPattern = ":___ ";

    static int SAPPLING = 0;
    static int LEAVES = 1;
    static int FLOWERS = 2;
    static int FRUIT = 3;
    static int RIPEFRUIT = 4;
    static int CORRUPT = -1;
    double saplingScale = 0.25;
    double adultScale = 0.5;
    int ticksBetweenPulse = 5;
    int numTicksSinceLastPulse = 0;
    DateTime plantTime;
    //cached, but procedural so don't need to save
    int _msPerStage = -1;

    int get msPerStage {
        if(_msPerStage < 0) {
            Colour color = doll.associatedColor;
            int minutesMax = 5;
            int minutesMin = 1;
            if(getParameterByName("haxMode") == "on") {
                minutesMax = 5;
                minutesMin = 1;
            }

            int base = minutesMax * 60*1000; //30 minutes

            //darker colors grow slower
            //brightness is a number between 0 and 1. 1 is very bright, 0 is very dark
            double modifier = color.value* (minutesMax-minutesMin)*60*1000;
            //very bright colors take five minutes, very dark ones take 30 minutes per stage
            _msPerStage = (base - modifier).floor();

        }
        if(world != null && world.bossFight) {
            return 10000; //nidhogg is life gone wild
        }
        return _msPerStage;
    }

    double fruitScale = 1.0;
    int fruitScaleDirection = 1; //is it going bigger or smaller in the pulse

    String get name{
        if(doll.fruitTemplate != null) {
            return "${doll.fruitTemplate.dollName} Tree";
        }
        return "Random Tree";

    }

    TreeDoll doll;
    num get topLeftY => bottomCenterY-(doll.height * scale);
    num get topLeftX => bottomCenterX-(doll.width * scale)/4;
    num bottomCenterX = 0;
    num bottomCenterY = 0;
    CanvasElement _canvas;
    //for uncorrupting, if you figure out how to
    String cachedTreeDoll;
    //if old stage and new stage don't match, auto dirty
    int oldStage = null;
    int stage = null;

    double get scale {
        if(stage == SAPPLING) return saplingScale;
        return adultScale;
    }

    World world;

    CanvasElement _saplingCanvas;
    CanvasElement _treeCanvas;
    CanvasElement _hangableCanvas;


    FruitDoll eye = new FruitDoll()..body.imgNumber = 24;
    bool reallyDirty = true; //render first time
    bool branchesDirty = true;
    bool hangablesDirty = true;
    bool leavesDirty = true;

    //if dirty redraw tree. dirty if my current stage is diff than the last stage i rendered as
    bool get  dirty => oldStage != stage || reallyDirty;


    Future<CanvasElement> get canvas async {
        if(_canvas == null || dirty) {
            //print ("drawing dirty tree");
            _canvas = new CanvasElement(width: doll.width, height: doll.height);
            await DollRenderer.drawDoll(_canvas, doll);
            oldStage = stage;
            reallyDirty = false;
        }
        return _canvas;
    }

    Future<CanvasElement> get saplingCanvas async {
        if(_saplingCanvas == null || dirty || branchesDirty) {
            //print ("drawing dirty tree");
            _saplingCanvas = await doll.renderJustBranches();
            oldStage = stage;
            reallyDirty = false;
            branchesDirty = false;
        }
        return _saplingCanvas;
    }

    Future<CanvasElement> get treeCanvas async {
        if(_treeCanvas == null || dirty || branchesDirty || leavesDirty) {
            //print ("drawing dirty tree");
            _treeCanvas = await doll.renderJustLeavesAndBranches();
            oldStage = stage;
            reallyDirty = false;
            branchesDirty = false;
            leavesDirty = false;
        }
        return _treeCanvas;
    }

    Future<CanvasElement> get hangableCanvas async {
        if(_hangableCanvas == null || dirty || hangablesDirty) {
            //print ("drawing ${doll.hangables.length} dirty hangables, _hangable canvas is $_hangableCanvas, dirty is $dirty and hangables dirty is $hangablesDirty");
            _hangableCanvas = await doll.renderJustHangables();
            oldStage = stage;
            reallyDirty = false;
            hangablesDirty = false;
        }
        return _hangableCanvas;
    }



    Tree(World this.world,TreeDoll this.doll, int this.bottomCenterX, int this.bottomCenterY);

    String toDataString() {
        try {
            String ret = toJSON().toString();
            return "$name$labelPattern${BASE64URL.encode(ret.codeUnits)}";
        }catch(e) {
            print(e);
           print("Error Saving Data. Are there any special characters in there? ${toJSON()} $e");
        }
    }

    JSONObject toJSON() {
        JSONObject json = new JSONObject();
        json["dollString"] = doll.toDataBytesX();
        json["bottomCenterX"] = "$bottomCenterX";
        json["bottomCenterY"] = "$bottomCenterY";
        if(plantTime == null) plantTime = new DateTime.now();
        json["plantTime"] = "${plantTime.millisecondsSinceEpoch}";

        return json;
    }

    void copyFromDataString(String dataString) {
        //print("dataString is $dataString");
        List<String> parts = dataString.split("$labelPattern");
        //print("parts are $parts");
        if(parts.length > 1) {
            dataString = parts[1];
        }

        String rawJson = new String.fromCharCodes(BASE64URL.decode(dataString));
        JSONObject json = new JSONObject.fromJSONString(rawJson);
        copyFromJSON(json);
    }

    void copyFromJSON(JSONObject json) {
        try {
            doll = Doll.loadSpecificDoll(json["dollString"]);
        }catch(e, trace) {
            print("couldn't load doll from string ${json["dollString"]}, $e, $trace ");
        }
        bottomCenterX = num.parse(json["bottomCenterX"]);
        bottomCenterY = num.parse(json["bottomCenterY"]);
        if(json["plantTime"] != null) {
            String plantString = json["plantTime"];
            plantTime = new DateTime.fromMillisecondsSinceEpoch(int.parse(plantString));

        }
    }

    void produceFruitOmni(List<Tree> parents) {
        //print("producing fruit with parents $parents");
        List<PositionedDollLayer> hangables = new List.from(doll.hangables);
        for(PositionedDollLayer fruitLayer in hangables) {
            Fruit fruitItem = new Fruit(world, fruitLayer.doll.clone());
            if (fruitItem.doll is FruitDoll) {
                (fruitItem.doll as FruitDoll).setName();
                //print("producing fruit with seed ${fruitItem.doll.seed} and name ${fruitItem.doll.dollName}");
            }
            fruitItem.parents =
            new List.from(parents.map((Tree tree) => tree.doll));
            world.underWorld.player.inventory.add(fruitItem);
            // print("before picking fruit the tree had ${tree.doll.renderingOrderLayers.length} layers");
            doll.dataOrderLayers.remove(fruitLayer);
            doll.renderingOrderLayers.remove(fruitLayer);
            // print("after picking fruit the tree had ${tree.doll.renderingOrderLayers.length} layers");
            hangablesDirty = true; //render plz
        }
    }

    void produceFruit(PositionedDollLayer fruitLayer, List<Tree> parents) {
        //print("producing fruit with parents $parents");
        Fruit fruitItem = new Fruit(world,fruitLayer.doll.clone());
        if(fruitItem.doll is FruitDoll) {
            (fruitItem.doll as FruitDoll).setName();
            //print("producing fruit with seed ${fruitItem.doll.seed} and name ${fruitItem.doll.dollName}");
        }
        fruitItem.parents = new List.from(parents.map((Tree tree)=> tree.doll));
        world.underWorld.player.inventory.add(fruitItem);
        // print("before picking fruit the tree had ${tree.doll.renderingOrderLayers.length} layers");
        doll.dataOrderLayers.remove(fruitLayer);
        doll.renderingOrderLayers.remove(fruitLayer);
        // print("after picking fruit the tree had ${tree.doll.renderingOrderLayers.length} layers");
        hangablesDirty = true; //render plz
    }

    PositionedDollLayer fruitPicked(Point point) {
        //first, is this point inside of me?
        if(!pointInsideMe(point)) return null;
        //print("you clicked inside me a tree}!");
        //next convert this point to be relative to my upper left
        //if i'm at 330 and the point is 400, then i should make it be 70. point - me
        //need to divide by scale to undo the multiplying i'm doing to render. maybe?
        //if i'm half as big and at 330, and the click is at 345, then the click needs to be at 30. yes.
        int convertedX = ((point.x - topLeftX)/scale).round();
        int convertedY = ((point.y - topLeftY)/scale).round();
        Point convertedPoint = new Point(convertedX, convertedY);
        //print("converted point is $convertedPoint");
        for(PositionedDollLayer layer in doll.hangables) {
           //print("is the point in $layer?, converted point is $convertedPoint and layer is at ${layer.x}, ${layer.y}");
            if(layer.pointInsideMe(convertedPoint)) return layer;
            //print("wasn't $layer");
        }

    }

    bool pointInsideMe(Point point) {
        Rectangle rect = new Rectangle(topLeftX, topLeftY, doll.width*scale, doll.height*scale);
       // print("did you click in tree? point is $point and I am $rect, scale was $scale and my stage is $stage");
        return rect.containsPoint(point);
    }

    //yellow yard hax, wont effect if you load, whatever
    void grow() {
        //pretend you were planted one stage extra ago
        plantTime= plantTime.subtract(new Duration(milliseconds: msPerStage));
        world.save();
    }


    Future<CanvasElement> getRipeFruitCanvas() async {
        if(oldStage < RIPEFRUIT) {
             print("making ripe fruit should only happen once per tree");
            doll.fruitTime = true;
            if(doll.hangables.isEmpty) {
                print("creating ripe fruit in the first place");
                await doll.createFruit();
            }else {
                print("transforming whatever is there into ripe fruit");
                doll.transformHangablesInto(); //auto does fruit
            }
            //print("made hangables ${doll.hangables}");
            hangablesDirty = true;
        }
        CanvasElement blank = doll.blankCanvas;
        CanvasElement treeC = await treeCanvas;
        //CanvasElement flowC = await hangableCanvas;
        blank.context2D.imageSmoothingEnabled = false;
        blank.context2D.drawImage(treeC, 0,0);
        //pulse the fruit to show you should click it
        setFruitScale(0.05);
        hangablesDirty = true;
        //renders things with a stable center
        for(SpriteLayer layer in doll.hangables) {
            if(layer is PositionedDollLayer) {
                //saving might be expensive
                //blank.context2D.save();
                num x = layer.x + layer.width/2;
                num y = layer.y + layer.height/2;
                blank.context2D.translate(x, y);
                blank.context2D.translate(-layer.width/2, -layer.height/2);
                CanvasElement dollCanvas = await layer.doll.getNewCanvas();
                //rotation not worht it rn
                //blank.context2D.rotate(fruitScaleDirection* fruitScale);

                blank.context2D.drawImageScaled(dollCanvas, 0, 0, layer.width*fruitScale, layer.height*fruitScale);
                //save / restore is apparently expensive so try this instead.
                blank.context2D.setTransform(1,0,0,1,0,0);
                //blank.context2D.rotate(0);
            }
        }
        //this would render it all as a single plane, but looks bad for pulsing
        //blank.context2D.drawImageScaled(flowC, 0,0, doll.width*fruitScale, doll.height*fruitScale);
        return blank;
    }

    //unripe fruits don't draw attention to themselves (but you can still click them)
    Future<CanvasElement> getFruitCanvas() async {
        if(oldStage < FRUIT) {
            print("making fruit should only happen once per tree");
            doll.fruitTime = true;
            if(doll.hangables.isEmpty) {
                print("making fruit from scratch");
                await doll.createFruit();
            }else {
                print("turning existing hangables into fruit");
                doll.transformHangablesInto(); //auto does fruit
            }
            //print("made hangables ${doll.hangables}");
            hangablesDirty = true;
        }
        CanvasElement blank = doll.blankCanvas;
        CanvasElement treeC = await treeCanvas;
        CanvasElement flowC = await hangableCanvas;
        blank.context2D.imageSmoothingEnabled = false;
        blank.context2D.drawImage(treeC, 0,0);
        blank.context2D.drawImageScaled(flowC, 0,0, doll.width, doll.height);
        return blank;
    }

    void setStage() {
        if(plantTime == null) {
            print("found a null plant time");
            plantTime = new DateTime.now();
        }
        Duration diff = new DateTime.now().difference(plantTime);
        int age = diff.inMilliseconds;
        oldStage = stage;
        //if i am an hour and five minutes old and there is 30 minute sper stage, i would be at stage 2.
        //if i am 25 minutes old and there is 30 minutes per stage, i would be at stage 0.
        stage = (age/msPerStage).floor();

        if(stage >= RIPEFRUIT) {
            stage = RIPEFRUIT;
        }
        //get it one more time
        if(oldStage == null) oldStage = stage;
        if(oldStage != stage){
            //https://freesound.org/people/adcbicycle/sounds/13951/
            world.playSoundEffect("13951__adcbicycle__23");
            world.save();
        }

    }


    Future<CanvasElement> getCanvasBasedOnStage() async {
        setStage();
        if(stage == SAPPLING) {
            return await saplingCanvas;
        }else if(stage == LEAVES) {
            return await treeCanvas;
        }else if(stage == FLOWERS) {
            return await getFlowerCanvas();
        }else if(stage == FRUIT) {
           return await getFruitCanvas();
        }else if(stage == RIPEFRUIT) {
            return await getRipeFruitCanvas();
        }else if (stage == CORRUPT) {
            return await getRipeFruitCanvas();
        }
    }


    Future<CanvasElement> getFlowerCanvas() async {
      CanvasElement treeC = await treeCanvas;
      doll.flowerTime = true;
      CanvasElement flowC = await hangableCanvas;
      treeC.context2D.imageSmoothingEnabled = false;
      treeC.context2D.drawImageScaled(flowC, 0,0, doll.width, doll.height);
      return treeC;
    }

    void setFruitScale(double scale) {
        if(numTicksSinceLastPulse >= ticksBetweenPulse) {
            fruitScale += scale * fruitScaleDirection;
            numTicksSinceLastPulse = 0;
        }
        numTicksSinceLastPulse ++;

        double buffer = 0.1;
      if(fruitScale > 1+buffer) {
          fruitScale = 1+buffer;
          fruitScaleDirection = fruitScaleDirection * -1;
      }else if(fruitScale<1-buffer) {
          fruitScale = 1-buffer;
          fruitScaleDirection = fruitScaleDirection * -1;
      }
    }


    //nothing to see here, move along
    void corrupt() {
        if(stage == CORRUPT) return;

        //caches everything, palette, fruit, whether it's fruiting, whole thing
        cachedTreeDoll = doll.toDataBytesX();

        oldStage = stage;
        stage = CORRUPT;
        doll.palette = ReferenceColours.CORRUPT;
        doll.fruitTemplate = eye;

        doll.fruitTime = true;
        for(SpriteLayer leaf in doll.clusters) {
            if(leaf is PositionedDollLayer) {
                leaf.doll.palette = ReferenceColours.CORRUPT;
            }
        }

        for(SpriteLayer fruit in doll.hangables) {
            if(fruit is PositionedDollLayer) {
                if(fruit.doll is FlowerDoll) {
                    (fruit.doll as FlowerDoll).body.imgNumber = eye.body.imgNumber;
                }else if (fruit.doll is FruitDoll) {
                    (fruit.doll as FruitDoll).body.imgNumber = eye.body.imgNumber;
                }
            }
        }
        hangablesDirty = true;
        branchesDirty = true;
        leavesDirty  = true;
    }

    void uncorrupt() {
        //print("trying to restore from uncorrupt doll $cachedTreeDoll");
        if(cachedTreeDoll != null) {
            doll = Doll.loadSpecificDoll(cachedTreeDoll);
        }
        stage = oldStage;
        oldStage = CORRUPT;
        hangablesDirty = true;
        branchesDirty = true;
        leavesDirty  = true;
    }




    Future<Null> render(CanvasElement buffer) async {
        CanvasElement treeCanvas = await getCanvasBasedOnStage();
        treeCanvas.context2D.imageSmoothingEnabled = false;
        //y position should be bottom, not top. so if i want it at 100, and my height is 500, then i need to do what?
        //i would need to put it at 100-500.
        //and it should be centered, because that's roughly where the trunk is going to be


        buffer.context2D.drawImageScaled(
            treeCanvas, topLeftX, topLeftY, (doll.width * scale).round(),
            (doll.width * scale).round());
    }

}