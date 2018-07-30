import '../Inventory.dart';
import '../World.dart';
import 'Ax.dart';
import 'Essence.dart';
import 'Flashlight.dart';
import 'Fruit.dart';
import 'HelpingHand.dart';
import 'Record.dart';
import 'YellowYard.dart';
import 'dart:convert';
import 'dart:html';

import 'package:CommonLib/Utility.dart';
import 'package:DollLibCorrect/DollRenderer.dart';

abstract class Inventoryable {
    static String labelPattern = ":___ ";

    bool canSell = false;
    String name = "???";
    //set this on init
    String type = "???";
    String description = "";
    Element myInventoryDiv;
    //things like essences are hidden till you beat the game
    bool hidden = false;
    int cost = 113;
    //when you're selling a thing, you sell at a fraction of its value
    int get saleCost => (cost/5).ceil();
    Inventory inventory; //will be set when there's a store
    //up to whoever uses me to make this a thing
    CanvasElement itemCanvas = new CanvasElement(width: 50, height: 50);

    bool get canAfford {
        if(inventory != null) {
            if(inventory.world.underWorld.player.funds >= cost) return true;
        }
        return false;
    }

    String toDataString() {
        try {
            String ret = toJSON().toString();
            return "$name$labelPattern${BASE64URL.encode(ret.codeUnits)}";
        }catch(e) {
            print(e);
            print("Error Saving Data. Are there any special characters in there? ${toJSON()} $e");
        }
    }

    static List<Inventoryable> oneOfEachType() {
        List<Inventoryable> all = new List<Inventoryable>();
        all.add(new Ax(null));
        all.add(new Flashlight(null));
        all.add(new Flashlight(null));
        all.add(new Fruit(null,new FruitDoll()));
        all.add(new HelpingHand(null));
        all.add(new HelpingHandPlusUltra(null));
        all.add(new YellowYard(null));
        all.addAll(Essence.spawn(null));
        all.addAll(Record.spawn(null));
        return all;
    }

    static Inventoryable loadItemFromJSON(JSONObject json) {
        //there has to be a better way than this, but essentially i'm doing it like dolls are trigger conditions
        //which is to say, get a list of all possible inventoryable types and see if it matches
        List<Inventoryable> allItems = oneOfEachType();
        for(Inventoryable item in allItems) {
            if(item.type == json["type"]) {
                item.copyFromJSON(json);
                return item;
            };
        }
        print("ERROR: COULD NOT FIND ITEM");
    }

    JSONObject toJSON() {
        JSONObject json = new JSONObject();
        json["name"] = name;
        json["type"] = type;//need to know what to instantiate this as
        json["description"] = description;
        json["cost"] = "$cost";
        json["hidden"] = hidden.toString();
        return json;
    }

    void copyFromDataString(String dataString) {
        //print("dataString is $dataString");
        List<String> parts = dataString.split("$labelPattern");
        //print("parts are $parts");
        if(parts.length > 1) {
            dataString = parts[1];
        }

        String rawJson = new String.fromCharCodes(BASE64URL.decode(dataString));
        JSONObject json = new JSONObject.fromJSONString(rawJson);
        copyFromJSON(json);
    }

    void copyFromJSON(JSONObject json) {
        name = json["name"];
        description = json["description"];
        cost = int.parse(json["cost"]);
        hidden =  json["hidden"] == true.toString();
        name = json["name"];
    }

    void renderStoreInventoryRow(DivElement parent, bool forSelling) {
        myInventoryDiv = new DivElement();
        myInventoryDiv.classes.add("innerStoreTableRow");
        parent.append(myInventoryDiv);

        //print("going to append item canvas for $name");
        myInventoryDiv.append(itemCanvas);
        itemCanvas.classes.add("imageCell");

        int realCost = cost;
        if(forSelling) realCost = saleCost;
        DivElement costCell = new DivElement()..text = "\$$realCost";
        costCell.classes.add("costCell");
        myInventoryDiv.append(costCell);

        myInventoryDiv.onClick.listen((Event e) {
            inventory.handleItemClick(this,preview:  itemCanvas);
        });
    }

    void removeFromInventoryScreen() {
        myInventoryDiv.remove();
    }

    void unHide() {
        hidden = false;
        if(myInventoryDiv != null) myInventoryDiv.style.display = "block";
    }

    void select() {
        if(myInventoryDiv != null) myInventoryDiv.classes.add("selected");
    }

    void unSelect() {
        myInventoryDiv.classes.remove("selected");

    }

    void renderMyInventoryRow(DivElement parent) {
        myInventoryDiv = new DivElement();
        myInventoryDiv.classes.add("innerInventoryTableRow");
        parent.append(myInventoryDiv);

        //print("going to append item canvas for $name");
        myInventoryDiv.append(itemCanvas);
        itemCanvas.classes.add("imageCell");


        myInventoryDiv.onClick.listen((MouseEvent e) {
            inventory.handleItemClick(this, preview:  itemCanvas);
        });

        if(hidden) {
            myInventoryDiv.style.display = "none";
        }
    }
}