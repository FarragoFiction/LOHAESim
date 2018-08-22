import '../Gameplay/Consort.dart';
import '../Gameplay/Inventoryable/Ax.dart';
import '../Gameplay/Inventoryable/Essence.dart';
import '../Gameplay/Inventoryable/Flashlight.dart';
import '../Gameplay/Inventoryable/Fruit.dart';
import '../Gameplay/Inventoryable/HelpingHand.dart';
import '../Gameplay/Inventoryable/Inventoryable.dart';
import '../Gameplay/Inventoryable/Record.dart';
import '../Gameplay/Player.dart';
import '../Gameplay/Store.dart';
import '../Gameplay/World.dart';
import 'dart:async';
import 'dart:html';
import "../Utility/TODOs.dart";
import 'package:CommonLib/NavBar.dart';
import "package:RenderingLib/src/loader/loader.dart" as OldRenderer;

import 'package:DollLibCorrect/DollRenderer.dart';
import 'package:DollLibCorrect/src/Dolls/PlantBased/FruitDoll.dart';
import 'package:RenderingLib/src/Misc/random.dart';

Element output = querySelector('#output');
World ygdrassil = new World();
Store store;
//how often do you get new things? every five minutes
int refreshMinute = 60;

DateTime firstLoad;
DateTime finallyDoneLoading;

Future<Null> main() async{
    firstLoad = new DateTime.now();
    await loadNavbar();
    await OldRenderer.Loader.preloadManifest();
    ygdrassil.health = 26;
    ygdrassil.makeFundsElement(querySelector("#navbar"));
    //example store, TODO have actual inventory system loaded from cache
    Store store = new Store(ygdrassil, spawnInventory(), ygdrassil.underWorld.player.inventory.saleItems);
    store.createContainer(output);
    new StoreConsort(store.container,400,"0.gif")..speechBubbleAnchor = 600..chatterRelativeLeft=200..chatterBounce=5;
    store.render();
    finallyDoneLoading = new DateTime.now();
    Duration diff = finallyDoneLoading.difference(firstLoad);
    print("Took ${diff.inMilliseconds} to load!");


}

List<Inventoryable> spawnInventory() {
    List<Inventoryable> ret = new List<Inventoryable>();

    if(ygdrassil.underWorld.player.canBuyAx) {
        ret.add(new Ax(ygdrassil));
    }

    if(ygdrassil.underWorld.player.canBuyPlusUltra) {
        ret.add(new HelpingHandPlusUltra(ygdrassil));
    }
    if(ygdrassil.underWorld.player.canBuyFlashlight) {
        ret.add(new Flashlight(ygdrassil));
    }
    ret.addAll(spawnRandomFruit());
    ret.addAll(Record.spawn(ygdrassil)); //can always buy

    return ret;
}

//this only changes once every hour
List<Fruit> spawnRandomFruit() {
    Random rand = new Random(nowToSeed());
    List<Fruit> ret = new List<Fruit>();
    for(int i = 0; i<13; i++) {
        FruitDoll doll = new FruitDoll(rand);
        TreeDoll parent = new TreeDoll();
        parent.rand.setSeed(doll.seed);
        parent.randomizeNotColors(); //makes sure it's always the same parents
        parent.copyPalette(doll.palette);
        //not for normies
        List<int> banList = FruitDoll.mutants;
        if(banList.contains(doll.body.imgNumber)) doll.body.imgNumber = 11;
        Fruit fruit = new Fruit(ygdrassil,doll);
        fruit.parents.add(parent);
        //make sure the clone parent has you as it's fruit
        parent.fruitTemplate = doll;
        parent.leafTemplate = new LeafDoll();
        parent.flowerTemplate = new FlowerDoll();
        parent.fruitTime = true;

        /*
        //TODO remove this thing i have in there for testing purposes
        for(int i = 0; i<13; i++) {
            TreeDoll parent = new TreeDoll();
            fruit.parents.add(parent);
        }
        */

        ret.add(fruit);
    }
    return ret;

}


int nowToSeed() {
    return new DateTime.now().millisecondsSinceEpoch ~/ 3600000;
}


