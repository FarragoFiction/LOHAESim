//wait what why is their a player???

import 'Inventoryable/Ax.dart';
import 'Inventoryable/Flashlight.dart';
import 'Inventoryable/Fruit.dart';
import 'Inventory.dart';
import 'Inventoryable/HelpingHand.dart';
import 'Inventoryable/Inventoryable.dart';
import 'Inventoryable/Record.dart';
import 'Inventoryable/YellowYard.dart';
import 'Secret.dart';
import 'World.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:html';
import "package:CommonLib/Logging.dart";
import 'package:CommonLib/Utility.dart';
import 'package:DollLibCorrect/DollRenderer.dart';

class Player extends Secret {
    static String labelPattern = ":___ ";

    //relative to underworld, center of player (not top left)

    bool hasActiveFlashlight = false;
    int speed = 45;
    //don't let the player go below zero or above this
    int maxX;
    int maxY;
    int minX = 0;
    int minY = 0;
    Inventory inventory;
    int funds = 0;

    //only gigglesnort if you move. spawning counts as moving
    bool playerMoved = true;

    //TODO relative to size of moneybags
    int flashlightRadius =75;


    Player(World world, int this.maxX, int this.maxY):super(world) {
        inventory= new Inventory(world, new List<Inventoryable>());
       // initialInventory();
    }

    void initialInventory() {
        //TODO have all this be a thing you buy from the store
        //add directly to circumvent drawings
        inventory.inventory.add(new HelpingHand(world));
        inventory.inventory.add(new Flashlight(world));
        inventory.inventory.add(new YellowYard(world));
        inventory.inventory.add(new Ax(world));
        inventory.addAll(Record.spawn(world));
        for(int i = 0; i<13; i++) {
            initialFruitInventory();
        }
    }

    String toDataString() {
        try {
            String ret = toJSON().toString();
            return "Player$labelPattern${BASE64URL.encode(ret.codeUnits)}";
        }catch(e) {
            print(e);
            print("Error Saving Data. Are there any special characters in there? ${toJSON()} $e");
        }
    }

    JSONObject toJSON() {
        JSONObject json = new JSONObject();
        json["topLeftX"] = "$topLeftX";
        json["topLeftY"] = "$topLeftY";
        json["funds"] = "$funds";
        json["inventory"] = inventory.toJSON().toString();
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
        //print("copying player from json");
        funds = int.parse(json["funds"]);
        topLeftX = int.parse(json["topLeftX"]);
        topLeftY = int.parse(json["topLeftY"]);
        //empty array counts too dunkass
        inventory.copyFromJSON(new JSONObject.fromJSONString(json["inventory"]));
        if(inventory.isEmpty && world.pastFruit.isEmpty) {
            initialInventory();
        }
    }

    void up() {
        topLeftY += -42;
        if(topLeftY <minY) {
            topLeftY = minY;
            owoPrint("New Friend, I can't go any more above! I'd break through the surface and that would be TERRIBLE!");
        }else {
            owoPrint("What's this above me?");
            playerMoved = true;
        }
    }

    void down() {
        topLeftY += 42;
        if(topLeftY > maxY) {
            topLeftY = maxY;
            owoPrint("New Friend, I can't go any more below!");
        }else {
            owoPrint("What's this down below?");
            playerMoved = true;

        }
    }

    void left() {
        topLeftX += -42;
        if(topLeftX < minX) {
            topLeftX = minX;
            owoPrint("New Friend, I can't go any more to the left!");
        }else {
            owoPrint("What's this to the left?");
            playerMoved = true;
        }
    }

    void right() {
        topLeftX += 42;
        if(topLeftX > maxX){
            topLeftX = maxX;
            owoPrint("New Friend, I can't go any more to the right!");
        }else {
            owoPrint("What's this to the right?");
            playerMoved = true;
        }
    }

    void initialFruitInventory() {
        FruitDoll doll = new FruitDoll();
        TreeDoll parent = new TreeDoll();
        parent.rand.setSeed(doll.seed);
        parent.randomizeNotColors(); //makes sure it's always the same parents
        parent.copyPalette(doll.palette);
        //not for normies
        List<int> banList = <int>[14,15,24];
        if(banList.contains(doll.body.imgNumber)) doll.body.imgNumber = 11;
        Fruit fruit = new Fruit(world,doll);
        fruit.parents.add(parent);
        //make sure the clone parent has you as it's fruit
        parent.fruitTemplate = doll;
        inventory.inventory.add(fruit);
    }

    Future<Null> drawInventory(Element container) async{
        inventory.createContainer(container);
        await inventory.render();
    }



}

void owoPrint(String text, [int size = 24]) {
    String owoCss = "font-family: 'Comic Sans MS', 'Comic Sans', cursive;text-shadow: 0 0 5px #1bfbff;color:#000000;font-size: ${size}px;";
    text = text.replaceAll("r","w");
    text = text.replaceAll("l","w");
    text = text.replaceAll("R","W");
    text = text.replaceAll("L","W");
    fancyPrint("???: $text",owoCss);
}

void consortPrint(String text, [int size = 18]) {
    String consortCss = "font-family: 'Courier New', Courier, monospace;color:#810c92;font-size: ${size}px;font-weight: bold;";
    fancyPrint("Random Consort: $text",consortCss);
}

void jrPrint(String text, [int size = 18]) {
    String jrCSS = "color:#3da35a;font-size: ${size}px;font-weight: bold;";
    String jrGigglesnortCSS = "color:#ffffff;font-size: ${size}px;font-weight: bold;";
    fancyPrint("JR: $text",jrCSS);
    fancyPrint("JR: I mean, if you're here you're practically a Waste already, so...   haxMode=on might help you with that secret path, if you know what i mean. ;) ;) ;)",jrGigglesnortCSS);

}