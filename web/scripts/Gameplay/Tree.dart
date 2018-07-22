import 'Inventoryable/Fruit.dart';
import 'World.dart';
import 'dart:async';
import 'dart:html';
import 'package:DollLibCorrect/DollRenderer.dart';

class Tree {
    static int SAPPLING = 0;
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
    int stage = FRUIT;
    double scale = 0.5;
    World world;


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

    Tree(World this.world,TreeDoll this.doll, int this.x, int this.y);

    void produceFruit(PositionedDollLayer fruitLayer, List<Tree> parents) {
        print("producing fruit with parents $parents");
        Fruit fruitItem = new Fruit(fruitLayer.doll.clone());
        if(fruitItem.doll is FruitDoll)(fruitItem.doll as FruitDoll).setName();
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

    void syncDollToStage() {
        if(stage == SAPPLING) {
            doll.flowerTime = false;
            doll.fruitTime = false;
        }else if(stage == FLOWERS) {
            doll.fruitTime = false;
            doll.flowerTime = true;
        }else if(stage == FRUIT) {
            doll.fruitTime = true;
            doll.flowerTime = false;
        }else if (stage == CORRUPT) {
            doll.fruitTime = true;
            doll.flowerTime = false;
        }
    }


    //nothing to see here, move along
    void corrupt() {
        if(stage == CORRUPT) return;
        oldStage = stage;
        stage = CORRUPT;
        //caches everything, palette, fruit, whether it's fruiting, whole thing
        cachedTreeDoll = doll.toDataBytesX();


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
        doll = Doll.loadSpecificDoll(cachedTreeDoll);
        stage = oldStage;
        oldStage = CORRUPT;
    }




    Future<Null> render(CanvasElement buffer) async {
        syncDollToStage();
        CanvasElement treeCanvas = await canvas;
        buffer.context2D.drawImageScaled(
            treeCanvas, x, y, (doll.width * 0.5).round(),
            (doll.width * 0.5).round());
    }

}