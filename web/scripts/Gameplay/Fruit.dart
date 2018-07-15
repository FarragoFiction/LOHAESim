import 'Inventoryable.dart';
import 'dart:async';
import 'dart:html';
import 'package:DollLibCorrect/DollRenderer.dart';

class Fruit extends Object with Inventoryable {
    //not necessarily a fruit doll
    Doll doll;

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

    Fruit(Doll this.doll) {
        name = doll.dollName;
        description = randomDescription();
    }

    Future<Null> setCanvasForStore() async{
        CanvasElement tmpCanvas = await canvas;
        Renderer.drawToFitCentered(itemCanvas, tmpCanvas);
    }

    String randomDescription() {
        Random rand = doll.rand;
        return "TODO: JR needs to use PL's thingy for this okay?";
    }
}