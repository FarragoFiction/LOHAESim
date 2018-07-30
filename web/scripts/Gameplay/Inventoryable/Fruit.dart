import '../Inventoryable/Inventoryable.dart';
import '../Player.dart';
import '../World.dart';
import 'dart:async';
import 'dart:html';
import 'package:CommonLib/Utility.dart';
import 'package:DollLibCorrect/DollRenderer.dart';
import 'package:TextEngine/TextEngine.dart';
import "dart:math" as Math;

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
            //print("getting canvas, my doll is ${doll.associatedColor}");
            _canvas = new CanvasElement(width: doll.width, height: doll.height);
            await DollRenderer.drawDoll(_canvas, doll);
        }
        return _canvas;
    }

    Fruit(World this.world, Doll this.doll) {
        name = doll.dollName;
        type = "Fruit";
    }

    //lets world know about the unique fruit you've found
    //as well as giving me an idea if it's a new game or not
    ArchivedFruit makeArchive() {
        if(world != null && !(this is ArchivedFruit)) {
            //using seed because otherwise offscreen colors will effect if it's 'unique'
            //and that's unintuitive
            String key = "${doll.seed}";
            if(!world.pastFruit.containsKey(key)){
                consortPrint("archiving $name!! now we will have this for generations!!");
                ArchivedFruit archive = new ArchivedFruit(doll);
                archive.description = description;
                archive.cost = cost;
                world.pastFruit[key]= archive;
                world.save();
            }
        }
    }

    //only item type that has a doll
    @override
    JSONObject toJSON() {
        JSONObject json = super.toJSON();
        json["dollString"] = doll.toDataBytesX();
        //print("saving fruit dollstring of ${json["dollString"]}");
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
            //print("before i load the specific doll ${dollString}, my doll is ${doll.associatedColor}");
            doll = Doll.loadSpecificDoll(dollString);
            //print("after i load the specific doll ${dollString}, my doll is ${doll.associatedColor}");

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
        //print("setting desc");
        if(description.isEmpty) {
            if (textEngine == null) {
                textEngine = new TextEngine(doll.seed);
                await textEngine.loadList("fruitDescriptions");
            }

            description = "${textEngine.phrase("FruitDescriptions")}";
            Random rand = new Random(doll.seed);
            cost = rand.nextIntRange(13, 113);
            if(doll is FruitDoll) {
                FruitDoll fruitDoll = doll as FruitDoll;
                if(FruitDoll.mutants.contains(fruitDoll.body.imgNumber)){
                    cost = (cost+5) * 5;
                    cost = Math.min(cost, 999);
                }
            }else if (!(doll is FruitDoll)) {
                cost = (cost+13) * 13;
                cost = Math.min(cost, 999);
            }
            //only archive if the player actually owns this, not if they see it in the store.

        }
        if (world != null && world.underWorld.player.inventory.contains(this)) {
            makeArchive();
        }
    }



}

//no unneccessary info like about parents
class ArchivedFruit extends Fruit {
    String type = "ArchivedFruit";
    DivElement details;
    Element wrapper;

  ArchivedFruit(Doll doll) : super(null,doll);

    @override
    JSONObject toJSON() {
        JSONObject json = super.toJSON();
        json.remove("parents"); //don't bother savings, this will be a HUGE amount of data since it will be trees
        return json;
    }

    void renderDetails(Element wrapper) {
        details = new DivElement()..classes.add("details");
        details.style.display = "none";
        wrapper.append(details);

        DivElement header = new DivElement()..text = name;
        DivElement value = new DivElement()..text = "Value: $cost";
        DivElement descElement = new DivElement()..text = description;
        descElement.style.marginTop = "10px";

        details.append(header);
        details.append(value);
        details.append(descElement);

    }

    void toggleDetails() {
        if(details.style.display == "none") {
            details.style.display = "block";
        }else {
            details.style.display = "none";
        }
    }

    bool hasTerm(String term) {
        if(name.toLowerCase().contains(term.toLowerCase())) return true;
        if(description.toLowerCase().contains(term.toLowerCase())) return true;
    }

    void show() {
        wrapper.style.display = "inline-block";
    }

    void hide() {
        wrapper.style.display = "none";
    }

    void renderMyVault(DivElement parent) {
        wrapper = new DivElement()..classes.add("wrapper");
        myInventoryDiv = new DivElement();
        myInventoryDiv.classes.add("innerInventoryTableRowVault");
        parent.append(wrapper);
        wrapper.append(myInventoryDiv);
        renderDetails(wrapper);


        //print("going to append item canvas for $name");
        myInventoryDiv.append(itemCanvas);
        itemCanvas.classes.add("imageCell");


        myInventoryDiv.onClick.listen((MouseEvent e) {
            toggleDetails();
        });

    }
}