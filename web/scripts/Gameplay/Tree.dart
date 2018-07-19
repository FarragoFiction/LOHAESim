import 'dart:async';
import 'dart:html';
import 'package:DollLibCorrect/DollRenderer.dart';

class Tree {
    TreeDoll doll;
    int x;
    int y;
    CanvasElement _canvas;
    //for uncorrupting, if you figure out how to
    String cachedTreeDoll;


    FruitDoll eye = new FruitDoll()..body.imgNumber = 24;
    //if dirty redraw tree.
    bool dirty = true;

    bool isCorrupt = false;

    Future<CanvasElement> get canvas async {
        if(_canvas == null || dirty) {
            print ("drawing dirty tree");
            _canvas = new CanvasElement(width: doll.width, height: doll.height);
            await DollRenderer.drawDoll(_canvas, doll);
            dirty = false;
        }
        return _canvas;
    }

    Tree(TreeDoll this.doll, int this.x, int this.y);


    //nothing to see here, move along
    void corrupt() {
        if(isCorrupt) return
        print("corrupting $doll");
        isCorrupt = true;
        dirty = true;
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
        dirty = true;
        doll = Doll.loadSpecificDoll(cachedTreeDoll);
    }




    Future<Null> render(CanvasElement buffer) async {
        CanvasElement treeCanvas = await canvas;
        buffer.context2D.drawImageScaled(
            treeCanvas, x, y, doll.width / 2,
            doll.width / 2);
    }

}