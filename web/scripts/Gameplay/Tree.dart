import 'Inventoryable/Fruit.dart';
import 'World.dart';
import 'dart:async';
import 'dart:html';
import 'package:DollLibCorrect/DollRenderer.dart';

class Tree {
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

    double fruitScale = 1.0;
    int fruitScaleDirection = 1; //is it going bigger or smaller in the pulse

    TreeDoll doll;
    num get topLeftY => bottomCenterY-(doll.height * scale);
    num get topLeftX => bottomCenterX-(doll.width * scale)/4;
    int bottomCenterX;
    int bottomCenterY;
    CanvasElement _canvas;
    //for uncorrupting, if you figure out how to
    String cachedTreeDoll;
    //if old stage and new stage don't match, auto dirty
    int oldStage = SAPPLING;
    int stage = SAPPLING;

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
        if(_saplingCanvas == null || dirty) {
            //print ("drawing dirty tree");
            _saplingCanvas = await doll.renderJustBranches();
            oldStage = stage;
            reallyDirty = false;
        }
        return _saplingCanvas;
    }

    Future<CanvasElement> get treeCanvas async {
        if(_treeCanvas == null || dirty) {
            //print ("drawing dirty tree");
            _treeCanvas = await doll.renderJustLeavesAndBranches();
            oldStage = stage;
            reallyDirty = false;
        }
        return _treeCanvas;
    }

    Future<CanvasElement> get hangableCanvas async {
        if(_hangableCanvas == null || dirty) {
            print ("drawing dirty hangables");
            _hangableCanvas = await doll.renderJustHangables();
            oldStage = stage;
            reallyDirty = false;
        }
        return _hangableCanvas;
    }



    Tree(World this.world,TreeDoll this.doll, int this.bottomCenterX, int this.bottomCenterY);

    void produceFruit(PositionedDollLayer fruitLayer, List<Tree> parents) {
        //print("producing fruit with parents $parents");
        Fruit fruitItem = new Fruit(fruitLayer.doll.clone());
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
        reallyDirty = true; //render plz
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

    //usually called by enough time passing
    void grow() {
        oldStage = stage;
        stage ++;
        if(stage >= FRUIT) stage = FRUIT;
    }


    //TODO instead of getting the whole canvas, process each fruit individually, and rotate/scale individually
    Future<CanvasElement> getRipeFruitCanvas() async {
        CanvasElement blank = doll.blankCanvas;
        CanvasElement treeC = await treeCanvas;
        CanvasElement flowC = await hangableCanvas;
        blank.context2D.imageSmoothingEnabled = false;
        blank.context2D.drawImage(treeC, 0,0);
        //pulse the fruit to show you should click it
        double scale = doll.rand.nextDouble()/10;
        setFruitScale(scale);
        blank.context2D.drawImageScaled(flowC, 0,0, doll.width*fruitScale, doll.height*fruitScale);
        return blank;
    }

    //unripe fruits don't draw attention to themselves (but you can still click them)
    Future<CanvasElement> getFruitCanvas() async {
        if(oldStage != FRUIT) {
            print("making fruit should only happen once per tree");
            doll.fruitTime = true;
            if(doll.hangables.isEmpty) {
                await doll.createFruit();
            }else {
                doll.transformHangablesInto(); //auto does fruit
            }
            print("made hangables ${doll.hangables}");
            reallyDirty = true;
        }
        CanvasElement blank = doll.blankCanvas;
        CanvasElement treeC = await treeCanvas;
        CanvasElement flowC = await hangableCanvas;
        blank.context2D.imageSmoothingEnabled = false;
        blank.context2D.drawImage(treeC, 0,0);
        treeC.context2D.drawImageScaled(flowC, 0,0, doll.width, doll.height);
        return blank;
    }



    Future<CanvasElement> getCanvasBasedOnStage() async {
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
            return await getCorruptCanvas();
        }
    }

    Future<CanvasElement> getCorruptCanvas() async {
      if(doll.fruitTime = false) {
          doll.fruitTime = true;
          doll.transformHangablesInto(); //auto does fruit which is eyes right now
      }
      CanvasElement blank = doll.blankCanvas;
      CanvasElement treeC = await treeCanvas;
      CanvasElement flowC = await hangableCanvas;
      treeC.context2D.imageSmoothingEnabled = false;
      blank.context2D.drawImage(treeC, 0,0);
      //pulse the fruit to show you should click it
      double scale = doll.rand.nextDouble()/10;
      setFruitScale(scale);
      blank.context2D.drawImageScaled(flowC, 0,0, doll.width*fruitScale, doll.height*fruitScale);
      return treeC;
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

        double buffer = 0.001;
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
    }

    void uncorrupt() {
        print("trying to restore from uncorrupt doll $cachedTreeDoll");
        doll = Doll.loadSpecificDoll(cachedTreeDoll);
        stage = oldStage;
        oldStage = CORRUPT;
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