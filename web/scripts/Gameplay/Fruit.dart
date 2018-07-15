import 'Inventoryable.dart';
import 'dart:async';
import 'dart:html';
import 'package:DollLibCorrect/DollRenderer.dart';
import 'package:TextEngine/TextEngine.dart';

class Fruit extends Object with Inventoryable {
    //not necessarily a fruit doll
    Doll doll;
    List<Doll> parents = new List<Doll>();

    CanvasElement _canvas;
    //if dirty redraw tree.
    bool dirty = true;
    TextEngine textEngine;

    Future<CanvasElement> get canvas async {
        if(_canvas == null || dirty) {
            _canvas = new CanvasElement(width: doll.width, height: doll.height);
            await DollRenderer.drawDoll(_canvas, doll);
        }
        return _canvas;
    }

    Fruit(Doll this.doll) {
        name = doll.dollName;
    }

    Future<DivElement> generateHorizontalScrollOfParents() async {
        //have parents show up in horizontal scrolling thing, return it so you can do whatever with it
        DivElement parentDivContainer = new DivElement();
        parentDivContainer.classes.add("parentHorizontalScroll");
        for(Doll parent in parents) {
            CanvasElement parentDiv = new CanvasElement(width: 113, height: 113);
            parentDiv.classes.add("parentBox");
            CanvasElement parentCanvas = await parent.getNewCanvas();
            Renderer.drawToFitCentered(parentDiv, parentCanvas);
            parentDivContainer.append(parentDiv);
        }
        return parentDivContainer;
    }

    Future<Null> setCanvasForStore() async{
        CanvasElement tmpCanvas = await canvas;
        Renderer.drawToFitCentered(itemCanvas, tmpCanvas);
        await setDescription();
    }

    Future<Null> setDescription() async {
        if(textEngine == null) {
            textEngine = new TextEngine();
            await textEngine.loadList("fruitDescriptions");
            textEngine.setSeed(doll.seed);
        }

       description = "${textEngine.phrase("FruitDescriptions")}";
        cost = doll.rand.nextIntRange(13, 113);
    }



}