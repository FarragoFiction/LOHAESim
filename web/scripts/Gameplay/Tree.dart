import 'dart:async';
import 'dart:html';
import 'package:DollLibCorrect/DollRenderer.dart';

class Tree {
    TreeDoll doll;
    int x;
    int y;
    CanvasElement _canvas;
    //if dirty redraw tree.
    bool dirty = true;

    Future<CanvasElement> get canvas async {
        if(_canvas == null || dirty) {
            _canvas = new CanvasElement(width: doll.width, height: doll.height);
            await DollRenderer.drawDoll(_canvas, doll);
        }
        return _canvas;
    }



    Tree(TreeDoll this.doll, int this.x, int this.y);



}