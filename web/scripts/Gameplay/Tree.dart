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
    static int CORRUPT = -1;

    TreeDoll doll;
    int x;
    int y;
    CanvasElement _canvas;
    //for uncorrupting, if you figure out how to
    String cachedTreeDoll;
    //if old stage and new stage don't match, auto dirty
    int oldStage = FRUIT;
    int stage = SAPPLING;
    double scale = 0.5;
    World world;

    CanvasElement _saplingCanvas;
    CanvasElement _treeCanvas;
    CanvasElement _hangableCanvas;


    FruitDoll eye = new FruitDoll()..body.imgNumber = 24;
    bool reallyDirty;
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
            //print ("drawing dirty tree");
            _hangableCanvas = await doll.renderJustHangables();
            oldStage = stage;
            reallyDirty = false;
        }
        return _hangableCanvas;
    }



    Tree(World this.world,TreeDoll this.doll, int this.x, int this.y);

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
       // print("you clicked inside me!");
        //next convert this point to be relative to my upper left
        //if i'm at 330 and the point is 400, then i should make it be 70. point - me
        //need to divide by scale to undo the multiplying i'm doing to render. maybe?
        //if i'm half as big and at 330, and the click is at 345, then the click needs to be at 30. yes.
        int convertedX = ((point.x - x)/scale).round();
        int convertedY = ((point.y - y)/scale).round();
        Point convertedPoint = new Point(convertedX, convertedY);
        for(PositionedDollLayer layer in doll.hangables) {
           // print("is the point in $layer?, point is $point and layer is at ${layer.x}, ${layer.y}");
            if(layer.pointInsideMe(convertedPoint)) return layer;
        }

    }

    bool pointInsideMe(Point point) {
        Rectangle rect = new Rectangle(x, y, doll.width*scale, doll.height*scale);
        return rect.containsPoint(point);
    }

    //usually called by enough time passing
    void grow() {
        oldStage = stage;
        stage ++;
        if(stage >= FRUIT) stage = FRUIT;
    }



    Future<CanvasElement> getCanvasBasedOnStage() async {
        if(stage == SAPPLING) {
            return await saplingCanvas;
        }else if(stage == LEAVES) {
            return await treeCanvas;
        }else if(stage == FLOWERS) {
            CanvasElement treeC = await treeCanvas;
            doll.flowerTime = true;
            CanvasElement flowC = await hangableCanvas;
            treeC.context2D.imageSmoothingEnabled = false;
            treeC.context2D.drawImageScaled(flowC, 0,0, doll.width, doll.height);
            return treeC;
        }else if(stage == FRUIT) {
            if(doll.fruitTime = false) {
                doll.fruitTime = true;
                doll.transformHangablesInto(); //auto does fruit
            }
            CanvasElement treeC = await treeCanvas;
            CanvasElement flowC = await hangableCanvas;
            treeC.context2D.imageSmoothingEnabled = false;
            //right now this will just wildly change every tick, just doing to test
            double scale = doll.rand.nextDouble()+0.5;
            treeC.context2D.drawImageScaled(flowC, 0,0, doll.width*scale, doll.height*scale);
            return treeC;
        }else if (stage == CORRUPT) {
            if(doll.fruitTime = false) {
                doll.fruitTime = true;
                doll.transformHangablesInto(); //auto does fruit which is eyes right now
            }
            CanvasElement treeC = await treeCanvas;
            CanvasElement flowC = await hangableCanvas;
            treeC.context2D.imageSmoothingEnabled = false;
            //right now this will just wildly change every tick, just doing to test
            double scale = doll.rand.nextDouble()+0.5;
            treeC.context2D.drawImageScaled(flowC, 0,0, doll.width*scale, doll.height*scale);
            return treeC;
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
        buffer.context2D.drawImageScaled(
            treeCanvas, x, y, (doll.width * 0.5).round(),
            (doll.width * 0.5).round());
    }

}