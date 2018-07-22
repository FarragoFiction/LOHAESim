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


    FruitDoll eye = new FruitDoll()..body.imgNumber = 24;
    //if dirty redraw tree. dirty if my current stage is diff than the last stage i rendered as
    bool get  dirty => oldStage != stage;


    Future<CanvasElement> get canvas async {
        if(_canvas == null || dirty) {
            //print ("drawing dirty tree");
            _canvas = new CanvasElement(width: doll.width, height: doll.height);
            await DollRenderer.drawDoll(_canvas, doll);
            oldStage = stage;
        }
        return _canvas;
    }

    Tree(TreeDoll this.doll, int this.x, int this.y);

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
            treeCanvas, x, y, doll.width / 2,
            doll.width / 2);
    }

}