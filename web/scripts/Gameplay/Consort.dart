import 'World.dart';
import 'dart:async';
import 'dart:html';

import 'package:CommonLib/Collection.dart';
import 'package:CommonLib/Random.dart';


class Consort {
    ImageElement imageElement;
    int x = 0;
    int textY = 250;
    int talkCount = 0;
    Element container;
    Element chatter;
    static int max = 1;
    Random rand = new Random();
    bool up = true;
    WeightedList<String> chats = new WeightedList();
    DateTime lastTalk;

    Consort(Element this.container, int this.x, String src) {
        rand.nextInt(); //init
        up = rand.nextBool();
        imageElement = new ImageElement(src: "images/Beavers/$src");
        imageElement.style.left = "${x}px";
        imageElement.classes.add("consort");
        container.append(imageElement);
        chatter = new DivElement()..text = "thwap!";
        container.append(chatter);
        initTopics();
        talk();
        animate();
    }

    static void spawnConsorts(Element output) {
        DivElement strip = new DivElement()..classes.add("consortStrip");
        output.append(strip);
        Random rand = new Random();
        int x = rand.nextInt(10) - 5;
        bool alligator = false;
        int numberConsorts = rand.nextInt(5)+1;
        if(rand.nextDouble()<.1) {
            numberConsorts = rand.nextInt(13)+1;
        }
        for(int i = 0; i<numberConsorts; i++) {
            int image = rand.nextInt(2);
            new Consort(strip,x, "$image.gif");
            x += rand.nextInt(500)+50;
            if(x > 1000) x = 0;
        }
    }

    void initTopics() {
        chats.add("",10.0);
        chats.add("thwap!!",10.0);
        chats.add("thwap thwap!!",10.0);
        chats.add("seeds!!",2);
        chats.add("i love trees!!");
        chats.add("trees!!",2);
        chats.add("fruit!!",2);
        chats.add("flowers!!",2);
        chats.add("leaves!!",2);
        chats.add("so many seeds!!");
        World world = World.instance;
        if(!world.bossDefeated) {
            chats.add("the DENIZEN keeps us from growing trees ourselves!!",0.5);
            chats.add("don't wake the DENIZEN!!",0.5);
            chats.add("they say the PRINCE will save us!!",0.5);
            chats.add("so many eyes :( :(",0.3);
            chats.add("we had to stop planting trees because Nidhogg would wake!!",0.1);
            chats.add("even if the Nidhogg causes all trees to die, the seed vault will survive!!",0.5);
        }else if (world.underWorld.nidhogg.dead) {
            chats.add("thank you for saving us!!");
            chats.add("you did it!!");
            chats.add("now we can grow our trees in peace!!");
            if (world.underWorld.nidhogg.purified) {
                chats.add("how did you grow trees underground??");
                chats.add("Nidhogg is actually a good guy??");
                chats.add("i'm confused!!");
            }
        }
        chats.add("you can find all your seeds here!!");
        chats.add("seed vault best vault!!");
        chats.add("we store seeds here so they will never go extinct!!");
        chats.add("lohae has two names!!",0.3);

        if(world.bossFight) {
            chats.add("Nidhogg absorbs the Life from Trees!!",10);
            chats.add("the Denizen is awake!!",5);
            chats.add("run!!",6);
            chats.add("use fraymotiffs!!",1);
            chats.add("find the EAGLE!!",5);
            chats.add("the BARD can help!!",5);
            chats.add("hide!!",6);
        }

    }

    void talk() {
        talkCount ++;
        if(talkCount % 2 == 0) {
            imageElement.style.transform = "scaleX(-1)";
        }else {
            imageElement.style.transform = "scaleX(1)";
        }
        lastTalk = new DateTime.now();
        chatter.text = rand.pickFrom(chats);
        if(chatter.text.isEmpty) {
            chatter.style.display = "none";
        }else {
            chatter.style.display = "block";
        }
        chatter.classes.add("chatter");
        chatter.style.left = "${x + 100}px";
        chatter.style.bottom = "250px";
    }

    Future<Null> animate() async{
        if(up) {
            chatter.style.bottom = "240px";
            up = false;
        }else {
            chatter.style.bottom = "250px";
            up = true;
        }
        Duration diff = new DateTime.now().difference(lastTalk);
        if(diff.inSeconds > rand.nextInt(10)+3) talk();
        await window.animationFrame;
        new Timer(new Duration(milliseconds: 77), () => animate());
    }


}

class FAQConsort extends Consort {
  FAQConsort(Element container, int x, String src) : super(container, x, src);

  @override
  void initTopics() {
      chats.add("",5.0);
      chats.add("thwap!!",5.0);
      chats.add("thwap thwap!!",5.0);
      chats.add("seeds!!",2);
      chats.add("hi!!",2);
      chats.add("??",5);
      chats.add("i love trees!!");
      chats.add("trees!!",2);
      chats.add("fruit!!",2);
      chats.add("flowers!!",2);
      chats.add("leaves!!",2);
      chats.add("lohae has two names!!",0.3);
      World world = World.instance;
      if(world.bossFight) {
          chats.add("Nidhogg absorbs the Life from Trees!!",10);
          chats.add("the Denizen is awake!!",10);
          chats.add("run!!",10);
          chats.add("use fraymotiffs!!",1);
          chats.add("find the EAGLE!!",5);
          chats.add("the BARD can help!!",5);
          chats.add("hide!!",10);
      }

  }
}