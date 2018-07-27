import '../Inventoryable/Inventoryable.dart';
import '../World.dart';
import 'dart:async';
import 'dart:html';
import 'package:CommonLib/Utility.dart';
import 'package:DollLibCorrect/DollRenderer.dart';
import 'package:TextEngine/TextEngine.dart';

class Fruit extends Object with Inventoryable {
    //not necessarily a fruit doll
    Doll doll;
    List<Doll> parents = new List<Doll>();
    @override
    bool canSell = true;

    CanvasElement _canvas;
    //if dirty redraw tree.
    bool dirty = true;
    TextEngine textEngine;
    World world;

    Future<CanvasElement> get canvas async {
        if(_canvas == null || dirty) {
            _canvas = new CanvasElement(width: doll.width, height: doll.height);
            await DollRenderer.drawDoll(_canvas, doll);
        }
        return _canvas;
    }

    Fruit(World world, Doll this.doll) {
        name = doll.dollName;
        type = "Fruit";
    }

    //lets world know about the unique fruit you've found
    //as well as giving me an idea if it's a new game or not
    ArchivedFruit makeArchive() {
        if(world != null && !(this is ArchivedFruit)) {
            ArchivedFruit archive = new ArchivedFruit(doll);
            archive.description = description;
            world.pastFruit[doll.toDataBytesX()]= archive;
        }
    }

    //only item type that has a doll
    @override
    JSONObject toJSON() {
        JSONObject json = super.toJSON();
        json["dollString"] = doll.toDataBytesX();
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

        try {
            String dollString = json["dollString"];
            doll = Doll.loadSpecificDoll(dollString);
        }catch(e, trace) {
            print("error loading doll for fruit, ${json["dollString"]}, $e, $trace");
        }
        String idontevenKnow = json["parents"];
        loadParentsFromJSON(idontevenKnow);
    }

    void loadParentsFromJSON(String idontevenKnow) {
        if(idontevenKnow == null) return;
        //print("fruit parents raw is $idontevenKnow");
        List<String> what = JSONObject.jsonStringToStringArray(idontevenKnow);
        //print("as  a set its $what");

        for(String w in what) {
            try {
                if(w != null && w.isNotEmpty) {
                    Doll parent = Doll.loadSpecificDoll(w);
                    parents.add(parent);
                }
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
        //only archive if the player actually owns this, not if they see it in the store.
        if(world != null && world.underWorld.player.inventory.contains(this)){
            makeArchive();
        }
    }



}

//no unneccessary info like about parents
class ArchivedFruit extends Fruit {
    String type = "ArchivedFruit";

  ArchivedFruit(Doll doll) : super(null,doll);

    @override
    JSONObject toJSON() {
        JSONObject json = super.toJSON();
        json.remove("parents"); //don't bother savings, this will be a HUGE amount of data since it will be trees
        return json;
    }
}