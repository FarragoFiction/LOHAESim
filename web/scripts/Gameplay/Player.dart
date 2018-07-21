//wait what why is their a player???

import 'Inventoryable/Ax.dart';
import 'Inventoryable/Flashlight.dart';
import 'Inventoryable/Fruit.dart';
import 'Inventory.dart';
import 'Inventoryable/Inventoryable.dart';
import 'Inventoryable/Record.dart';
import 'Inventoryable/YellowYard.dart';
import 'Secret.dart';
import 'World.dart';
import 'dart:async';
import 'dart:html';
import "package:CommonLib/Logging.dart";
import 'package:DollLibCorrect/DollRenderer.dart';

class Player extends Secret {
    //relative to underworld, center of player (not top left)

    bool hasActiveFlashlight = false;
    int speed = 45;
    //don't let the player go below zero or above this
    int maxX;
    int maxY;
    int minX = 0;
    int minY = 0;
    Inventory inventory;

    //only gigglesnort if you move. spawning counts as moving
    bool playerMoved = true;

    //TODO relative to size of moneybags
    int flashlightRadius =75;


    Player(World world, int this.maxX, int this.maxY):super(world) {
        //TODO have all this be a thing you buy from the store
        inventory= new Inventory(world, new List<Inventoryable>());
        inventory.add(new Flashlight(world));
        inventory.add(new Ax(world));
        inventory.add(new YellowYard(world));
        inventory.addAll(Record.spawn(world));
        for(int i = 0; i<3; i++) {
            initialInventory();
        }
    }

    void up() {
        topLeftY += -42;
        if(topLeftY <minY) {
            topLeftY = minY;
            owoPrint("New friend, I can't go any more above! I'd break through the surface and that would be TERRIBLE!");
        }else {
            owoPrint("What's this above me?");
            playerMoved = true;
        }
    }

    void down() {
        topLeftY += 42;
        if(topLeftY > maxY) {
            topLeftY = maxY;
            owoPrint("New friend, I can't go any more below!");
        }else {
            owoPrint("What's this down below?");
            playerMoved = true;

        }
    }

    void left() {
        topLeftX += -42;
        if(topLeftX < minX) {
            topLeftX = minX;
            owoPrint("New friend, I can't go any more to the left!");
        }else {
            owoPrint("What's this to the left?");
            playerMoved = true;
        }
    }

    void right() {
        topLeftX += 42;
        if(topLeftX > maxX){
            topLeftX = maxX;
            owoPrint("New friend, I can't go any more to the right!");
        }else {
            owoPrint("What's this to the right?");
            playerMoved = true;
        }
    }

    void initialInventory() {
        FruitDoll doll = new FruitDoll();
        TreeDoll parent = new TreeDoll();
        parent.rand.setSeed(doll.seed);
        parent.randomizeNotColors(); //makes sure it's always the same parents
        parent.copyPalette(doll.palette);
        //not for normies
        List<int> banList = <int>[14,15,24];
        if(banList.contains(doll.body.imgNumber)) doll.body.imgNumber = 11;
        Fruit fruit = new Fruit(doll);
        fruit.parents.add(parent);
        //make sure the clone parent has you as it's fruit
        parent.fruitTemplate = doll;

        inventory.add(fruit);
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