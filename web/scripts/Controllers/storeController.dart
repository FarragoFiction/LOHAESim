import '../Gameplay/Essence.dart';
import '../Gameplay/Fruit.dart';
import '../Gameplay/Player.dart';
import '../Gameplay/Store.dart';
import '../Gameplay/World.dart';
import 'dart:html';
import "../Utility/TODOs.dart";

import 'package:DollLibCorrect/DollRenderer.dart';
import 'package:DollLibCorrect/src/Dolls/PlantBased/FruitDoll.dart';
import 'package:RenderingLib/src/Misc/random.dart';

Element output = querySelector('#output');
World ygdrassil = new World(output);
Store store;
//how often do you get new things? every five minutes
int refreshMinute = 60;

void main() {
    ygdrassil.health = 26;
    //example store, TODO have actual inventory system loaded from cache
    Store store = new Store(output, spawnRandomFruit());
    store.render();
}

//this only changes once every hour
List<Fruit> spawnRandomFruit() {
    Random rand = new Random(nowToSeed());
    List<Fruit> ret = new List<Fruit>();
    for(int i = 0; i<13; i++) {
        FruitDoll doll = new FruitDoll(rand);
        TreeDoll parent = new TreeDoll();
        parent.copyPalette(doll.palette);
        //not for normies
        List<int> banList = <int>[14,15,24];
        if(banList.contains(doll.body.imgNumber)) doll.body.imgNumber = 11;
        Fruit fruit = new Fruit(doll);
        fruit.parents.add(parent);
        //make sure the clone parent has you as it's fruit
        parent.fruitTemplate = doll;

        //TODO remove this thing i have in there for testing purposes
        for(int i = 0; i<13; i++) {
            TreeDoll parent = new TreeDoll();
            fruit.parents.add(parent);
        }
        
        ret.add(fruit);
    }
    return ret;

}


int nowToSeed() {
    DateTime now = lastRefreshTime();
    String y = "${now.year.toString().padLeft(2,'0')}";
    String m = "${now.month.toString().padLeft(2,'0')}";
    String d = "${now.day.toString().padLeft(2,'0')}";
    String h = "${(now.hour).toString().padLeft(2,'0')}";

    return int.parse("$y$m$d$h");
}

DateTime lastRefreshTime() {
    DateTime now = new DateTime.now();
    //thanks for math pl
    return new DateTime(now.year, now.month, now.day, now.hour, (now.minute ~/ refreshMinute) * refreshMinute);
}


