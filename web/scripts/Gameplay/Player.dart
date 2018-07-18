//wait what why is their a player???

import 'Inventoryable/Ax.dart';
import 'Inventoryable/Fruit.dart';
import 'Inventory.dart';
import 'Inventoryable/Inventoryable.dart';
import 'Inventoryable/Record.dart';
import 'Secret.dart';
import 'World.dart';
import 'dart:async';
import 'dart:html';

import 'package:DollLibCorrect/DollRenderer.dart';

class Player extends Secret {
    //relative to underworld, center of player (not top left)


    int speed = 45;
    //don't let the player go below zero or above this
    int maxX;
    int maxY;
    int minX = 0;
    int minY = 0;
    Inventory inventory = new Inventory(new List<Inventoryable>());

    //TODO relative to size of moneybags
    int flashlightRadius =75;


    Player(World world, int this.maxX, int this.maxY):super(world) {
        //TODO have all this be a thing you buy from the store
        inventory.add(new Ax(world));
        inventory.addAll(Record.spawn(world));
        for(int i = 0; i<3; i++) {
            initialInventory();
        }
    }

    void up() {
        topLeftY += -42;
        if(topLeftY <minY) topLeftY = minY;
    }

    void down() {
        topLeftY += 42;
        if(topLeftY > maxY) topLeftY = maxY;
    }

    void left() {
        topLeftX += -42;
        if(topLeftX < minX) topLeftX = minX;
    }

    void right() {
        topLeftX += 42;
        if(topLeftX > maxX) topLeftX = maxX;
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