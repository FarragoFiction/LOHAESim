import '../Gameplay/World.dart';
import 'dart:async';
import 'dart:html';
import "../Utility/TODOs.dart";

import 'dart:math' as Math;
import 'package:CommonLib/Collection.dart';
import 'package:CommonLib/NavBar.dart';
import 'package:CommonLib/Random.dart';

Element output = querySelector('#output');
World ygdrassil = new World();

List<Consort> consorts = new List<Consort>();

Future<Null> main() async {
    await loadNavbar();
    spawnConsorts();
}

void spawnConsorts() {
    DivElement strip = new DivElement()..classes.add("consortStrip");
    output.append(strip);
    Random rand = new Random();
    int x = rand.nextInt(10) - 5;
    bool flip = false; //only one can flip out
    bool alligator = false;
    int max = 3;
    int numberConsorts = rand.nextInt(13)+1;
    for(int i = 0; i<numberConsorts; i++) {
        if(flip) max = 2;
        int image = rand.nextInt(max);
        if(image == 4) flip = true;
        consorts.add(new Consort(strip,x, "$image.gif"));
        x += rand.nextInt(300);
        if(x > 1000) x = 0;
    }
}


class Consort {
    ImageElement imageElement;
    int x = 0;
    int textY = 250;
    Element container;
    Element chatter;
    Random rand = new Random();
    bool up = true;
    WeightedList<String> chats = new WeightedList();

    Consort(Element this.container, int this.x, String src) {
        rand.nextInt(); //init
        up = rand.nextBool();
        imageElement = new ImageElement(src: "images/Beavers/$src");
        imageElement.style.left = "${x}px";
        imageElement.classes.add("consort");
        container.append(imageElement);
        chatter = new DivElement()..text = "thwap!";
        initTopics();
        talk();
        animate();
    }

    void initTopics() {
        chats.add("",2);
        chats.add("thwap!");
        chats.add("seeds!");
        chats.add("i love trees!");
        chats.add("trees!");
        chats.add("so many seeds!");

    }

    void talk() {
        chatter.text = rand.pickFrom(chats);
        if(chatter.text.isEmpty) {
            chatter.style.display = "none";
        }else {
            chatter.style.display = "block";
        }
        chatter.classes.add("chatter");
        chatter.style.left = "${x + 100}px";
        chatter.style.bottom = "250px";
        container.append(chatter);
    }

    Future<Null> animate() async{
        if(up) {
            chatter.style.bottom = "240px";
                up = false;
        }else {
            chatter.style.bottom = "250px";
            up = true;
        }
        await window.animationFrame;
        new Timer(new Duration(milliseconds: 77), () => animate());
    }


}