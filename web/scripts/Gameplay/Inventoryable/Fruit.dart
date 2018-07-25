import '../Inventoryable/Inventoryable.dart';
import 'dart:async';
import 'dart:html';
import 'package:CommonLib/Utility.dart';
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
        type = "Fruit";

    }

    //only item type that has a doll
    @override
    JSONObject toJSON() {
        JSONObject json = super.toJSON();
        json["dollString"] = doll.toString();
        List<String> parentArray = new List<String>();
        for(Doll parent in parents) {
            parentArray.add(parent.toDataBytesX());
        }
        json["parents"] = parentArray.toString();

        return json;
    }

    @override
    void copyFromJSON(JSONObject json) {
        super.copyFromJSON(json);
        String idontevenKnow = json["parents"];
        loadParentsFromJSON(idontevenKnow);

    }

    void loadParentsFromJSON(String idontevenKnow) {
        if(idontevenKnow == null) return;
        Set<String> what = JSONObject.jsonStringToStringSet(idontevenKnow);
        for(String w in what) {
            try {
                Doll parent = Doll.loadSpecificDoll(w);
                parents.add(doll);
            }catch(e, trace) {
                print("error loading parent $w, $e, $trace");
            }
        }

    }

    Future<DivElement> generateHorizontalScrollOfParents() async {
        //have parents show up in horizontal scrolling thing, return it so you can do whatever with it
        DivElement parentDivContainer = new DivElement();
        parentDivContainer.classes.add("parentHorizontalScroll");
        List<CanvasElement> pendingCanvases = new List<CanvasElement>();
        for(Doll parent in parents) {
            CanvasElement parentDiv = new CanvasElement(width: 80, height: 80);
            //fruit is visible, not flower
            if(parent is TreeDoll) {
                parent.fruitTime = true;
            }
            parentDiv.classes.add("parentBox");
            pendingCanvases.add(parentDiv);

        }

        //not async, can happen whenever
        finishDrawingParents(pendingCanvases,parentDivContainer);
        //we return before we finish drawing, so it doesn't hang
        return parentDivContainer;
    }

    Future<Null> finishDrawingParents(List<CanvasElement> pendingCanvases, Element parentDivContainer) async {
        for(Doll parent in parents) {
            CanvasElement parentDiv = pendingCanvases[parents.indexOf(parent)];
            CanvasElement parentCanvas = await parent.getNewCanvas();
            Renderer.drawToFitCentered(parentDiv, parentCanvas);
            parentDivContainer.append(parentDiv);
         }
    }

    Future<Null> setCanvasForStore() async{
        CanvasElement tmpCanvas = await canvas;
        Renderer.drawToFitCentered(itemCanvas, tmpCanvas);
        await setDescription();
    }

    Future<Null> setDescription() async {
        if(textEngine == null) {
            textEngine = new TextEngine(doll.seed);
            await textEngine.loadList("fruitDescriptions");
        }

       description = "${textEngine.phrase("FruitDescriptions")}";
        Random rand = new Random(doll.seed);
        cost = rand.nextIntRange(13, 113);
    }



}