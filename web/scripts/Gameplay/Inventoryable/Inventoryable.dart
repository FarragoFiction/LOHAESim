import '../Inventory.dart';
import 'dart:convert';
import 'dart:html';

import 'package:CommonLib/Utility.dart';

abstract class Inventoryable {
    static String labelPattern = ":___ ";

    String name = "???";
    String description = "An item???";
    Element myInventoryDiv;
    //things like essences are hidden till you beat the game
    bool hidden = false;
    int cost = 113;
    Inventory inventory; //will be set when there's a store
    //up to whoever uses me to make this a thing
    CanvasElement itemCanvas = new CanvasElement(width: 50, height: 50);

    String toDataString() {
        try {
            String ret = toJSON().toString();
            return "$name$labelPattern${BASE64URL.encode(ret.codeUnits)}";
        }catch(e) {
            print(e);
            print("Error Saving Data. Are there any special characters in there? ${toJSON()} $e");
        }
    }

    JSONObject toJSON() {
        JSONObject json = new JSONObject();
        json["name"] = name;
        json["description"] = description;
        json["cost"] = "$cost";
        json["hidden"] = hidden.toString();
        return json;
    }

    void renderStoreInventoryRow(DivElement parent) {
        myInventoryDiv = new DivElement();
        myInventoryDiv.classes.add("innerStoreTableRow");
        parent.append(myInventoryDiv);

        //print("going to append item canvas for $name");
        myInventoryDiv.append(itemCanvas);
        itemCanvas.classes.add("imageCell");

        DivElement costCell = new DivElement()..text = "\$$cost";
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