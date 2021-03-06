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
    int speechBubbleAnchor = 240;
    int chatterRelativeLeft = 100;
    int chatterBounce = 10;
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
            int numberEssences = World.instance.underWorld.player.numberEssences;
            if(rand.nextDouble()>.70 && numberEssences > 12) {
                new SecretConsort(strip,x);
            }else if(rand.nextDouble()>.75 && numberEssences > 11) {
                new SecretConsort(strip,x);
            }else if(rand.nextDouble()>.80 && numberEssences > 10) {
                new SecretConsort(strip,x);
            }else if(rand.nextDouble()>.85 && numberEssences > 9) {
                new SecretConsort(strip,x);
            }else if(rand.nextDouble()>.90 && numberEssences > 8) {
                new SecretConsort(strip,x);
            }else if(rand.nextDouble()>.95 && numberEssences > 7) {
                new SecretConsort(strip,x);
            }else if(rand.nextDouble()>.99 && numberEssences > 6) {
                new SecretConsort(strip,x);
            }else {
                new Consort(strip, x, "$image.gif");
            }
            x += rand.nextInt(500)+50;
            if(x > 1000) x = 0;
        }
    }

    void initTopics() {
        World world = World.instance;

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
        if(!world.bossDefeated) {
            chats.add("you have ${world.underWorld.player.numberEssences} of 3 needed ESSENCES!!");
            chats.add("if you get enough ESSENCES you can get something cool in the shop!!",0.5);
            chats.add("the TITAN keeps us from growing trees ourselves!!",0.5);
            chats.add("the DENIZEN keeps us from growing trees ourselves!!",0.5);
            chats.add("don't wake the DENIZEN!!",0.5);
            chats.add("don't wake the TITAN!!",0.5);
            chats.add("they say the PRINCE will save us!!",0.5);
            chats.add("they say the VANDAL will save us!!",0.5);
            chats.add("they say the REAPER will save us!!",0.5);
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
            chats.add("the DENIZEN is awake!!",5);
            chats.add("the TITAN is awake!!",5);
            chats.add("run!!",6);
            chats.add("use fraymotiffs!!",8);
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
        chatter.style.left = "${x + chatterRelativeLeft}px";
        chatter.style.bottom = "250px";
    }

    Future<Null> animate() async{
        if(up) {
            chatter.style.bottom = "${speechBubbleAnchor}px";
            up = false;
        }else {
            chatter.style.bottom = "${speechBubbleAnchor+chatterBounce}px";
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
            chats.add("the DENIZEN is awake!!",10);
            chats.add("the TITAN is awake!!",10);
            chats.add("run!!",10);
            chats.add("use fraymotiffs!!",1);
            chats.add("find the EAGLE!!",5);
            chats.add("the BARD can help!!",5);
            chats.add("hide!!",10);
        }

    }
}

class StoreConsort extends Consort {

    StoreConsort(Element container, int x, String src) : super(container, x, src) {
        print("store consort is go");
    }

    @override
    void initTopics() {
        chats.add("hi!!",1);
        chats.add("",5);
    }
}



class SecretConsort extends Consort {
    SecretConsort(Element container, int x,) : super(container, x, "4037.gif") {
        imageElement.onClick.listen((Event e) {
            World.instance.unlockAchievement("secret_aligator");
            window.alert("!! you did it !!  you clicked my scales!! thwap thwap!! have a secret!! i don't know what it does!!");
            window.location.href = "index.html?haxMode=on";
        });
    }

    @override
    void initTopics() {
        chats.add("i am a Secret Aligator!!",10.0);
        chats.add("thwap!!",5.0);
        chats.add("click my Scales, y/n??",10.0);
    }
}

class SecretFAQConsort extends FAQConsort {
    SecretFAQConsort(Element container, int x,) : super(container, x, "4037.gif") {
        imageElement.onClick.listen((Event e) {
            World.instance.unlockAchievement("secret_aligator");
            window.alert("!! you did it !!  you clicked my scales!! thwap thwap!! have a secret!! i don't know what it does!!");
            window.location.href = "index.html?haxMode=on";
        });
    }

    @override
    void initTopics() {
        chats.add("i am a Secret Aligator!!",10.0);
        chats.add("thwap!!",5.0);
        chats.add("hey!! hey!! wanna know a secret??",5.0);
        chats.add("click my Scales, y/n??",10.0);
    }
}