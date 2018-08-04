import '../Gameplay/Consort.dart';
import '../Gameplay/Inventoryable/Record.dart';
import '../Gameplay/World.dart';
import 'dart:async';
import 'dart:html';
import "../Utility/TODOs.dart";

import 'package:CommonLib/NavBar.dart';
import 'package:CommonLib/Random.dart';
/*


                          ```````   `                 `  ``   `                        ```````                           `
                      ```` `   `   ````           `````   `   `````               ````  `   `` ````                ````  `   ``` `
                   ```               ````        ```             ````           ```                ```          ```             ````
                  ``                   ```      ``                 ```         ```                  ```        ```                ``
           `````..``.`..`````````.``.``-``.``..`..``.```.``..``.``.``.``.``.``-`.-``.``.`..``.``.``..`..``.``.``.```..``.``..`..````..````
           `.-............-..-...-.....-........................................................................-.......................-.`
           `.-..........................................................................................................................-.`
           `......:-....-::::::::::----:++++++++++++++oo+++::::::::::::::...::::::::::::::---------::::::::::::::::::::::::::-....-:......`
           `.-..../.                 -ohddddddddddddddddddhh+`           `.`                                                      ./....-.`
           `......+.              .+yhdddxdddddddddddddmmmmmddy.          `.`                            `     `                   .+......`
       `````.-....+.           `:shddddddddddddddddmNNNNNNNNmdy.         `.``.+o+.`  `.oo/.           .sh   .sh                   .+....-.` ```
     ```   `......+.         -ohdddddddddddddddmmNNNNNNNNNNNNmdy`        `.`  +d+      sd:             yd    yd                   .+......`   ```
     ```   `.:....+.         .yddddddddddddmmddNNNNmshNNNNmmNNmdo        `.`  +d+      sd-    ---:.    yd    yd    `---:.         .+....:.`    ```
    ```    `......+-          `+hdddddddddms:-hNdyo.``:shmN+omNdh-       `.`  +do------yd-  -s.``-ho   yd    yd   /o```-ss`       -+......`    ```
    ```    `.-....+:            .ohddddddy-``.:-.````````.-:`-NNdo       `.`  +d+``````yd-  yy:::://`  yd    yd  -h:    -do       :+....-.`    ```
     ```   `......+-              .+hdddds```````````````````.NNmh.      `.`  +d+      sd-  yh.    .`  yd    yd  :do    `d+       -+......`    ```
     ```   `.-..../.                .sddddy-`````````````````+Nmdo`      `.`  odo      yd:  -yho//+:   yd    yd   +h/` `/o`  /o.  ./....-.`    ``
       `````....../.                 -yddddh/```````````````/dyo-        `.``.:::.`  `.::-`  `-//:.   .::.  .::.   .::-..    -/`  ./......` ````
        ````......+.                /hddddddds:``````````.-/:.`          `.`                                                      .+......````
           `......+.               -ddmddddddddo-..-//+ohms              `.`                                                      .+......`
           `.-....+.              -hdNmddddddddddhhdddddyNh              `.`                                                      .+....-.`
           `-.....+.           .-ohddmdddddddddddhhdddddso:              `.`                                                      .+.....-`
          ``......+.          .ohdddddddddddddddhs/ddddddh:              `.`                                                      .+......`
        ````......+.         ```:hdddddddddddddh+--/hdddddh-             `.`                                                      .+......`````
      ```  `......+-      ``````.hddddddddddddho....+dddddy`             `.`                                                      -+......`  ```
     ````  `.:...-+:   ``````` `odddddddddddddo/-..-+sdds/.``            `.`                                                      :+-...:.`   ```
     ```   `....../-`````````   :sssssssyyyyyys+o++o+syyo `````          `.`               ````````````````                       -/......`    ``
     ```   `........````````````--------:::::::::::::::::.````````````````.````````````````````````````````````````````````````````.......`    ``
     ```   `....../```````      -+syyyhhhhhhhhhddddddhyo/.    ```        `.`                                                      `+......`   ```
      ``   `.....-+`   `````       ``.shdddddddddddddo         ```       `.`                                                      `+-.....`   ```
       ``` `.....-+`      `````   ````-/hddddddddddddh-         ```      `.`                                                      `+-.....`  ``
         ```.-...-+`          ````````..:oddddddddddddh.         ```     `.`                                                      `+-...-.```
           `.....-+.                 :shyddddddddddddddy.         ```    `.`                                                      .+-.....`
           `.-...-+.                 sddddddddddddddddddy.        ```    `.`                                                      .+-...-.`
           `......+`                 ydddddddddddddddddddh.        ```   `.`                                                      `+......`
        ````......+`                -hydddddddddddddddddddy`        ``   `.`                                                      `+......`````
      ```  `......+`                +hsdddddddddddddddddddds`        ``  `.`                                                      `+......`  ````
     ```   `.....-+`                +y+hddddddddddddddddddddo         `` `.`                                                      `+-.....`   ```
     ```   `.-...-+`                ys+yddddddddddddddddddddd/         ` `.`                                                      `+-...-.`    ```
     ```   `.....-+`               -d++sdddddddddddddddddddddh-        ```.`                                                      `+-.....`    ```
     ```   `:....-+`               -s++ohhhhhddhdddddddhhhhyso+        ` `..`                                                     `+-....:`   ```
      ``   `.....-+`                .++++++oooo-::::/oooo++++++.         `..`                                                     `+-.....`   ```
       ````..-...:+`                -+++++++++/      :+++++++++/         `.`                                                      `+:...-.` ````
        ```......-+.                -+++++++++/       /+++++++++.        `.`                                                      .+-......```
           `.-...:+.                -+++++++++/       `+++++++++/        `.`                                                      .+:...-.`
           `.-...-+-                -+++++++++/        :+++++++++`       `.`                                                      -+-...-.`
           ......./:...--:::::::::--://///////:......--://///////::::::::...::::::::::::::--------:::::::::::::::::::::::::::--...:/.......
           ..-..........................................................................................................................-..
           ..-........-...-..-..................................................................................-..............-........-..
           `````-``.``.```.`````..`..`..``-``-``-``..``.```-``.```.``.`..``.`..`..`..`..`.``..`..``-``.``.``..``.```-```.``-```.``.``-`````



    Hi!!! JR here, and I'm just thrilled you're poking around in the git hub repo. Coding is fun!

    But... are you SURE you really want to be spoiling shit right now?

 */

Element output = querySelector('#output');
World ygdrassil = new World();

Future<Null> main() async {
    await loadNavbar();
    start();
}

void start() {
    TableElement table = new TableElement()..classes.add("container");
    output.append(table);

    if(ygdrassil.underWorld.player.canBuyFlashlight) {
        new FAQ(table, "Oh god what is that thing!?", "A pain in my ass.");
        new FAQ(table, "Okay, seriously, what's the point of Flashlight???", "To light up the dark, numbnuts.");
    }

    if(ygdrassil.bossFight) {
        new FAQ(table, "Shit where are my trees, what is going on? Why are there EYES???", "Wow its almost like you ran away from a boss fight like a coward.<br><br> I can’t give you a direct answer because yada yada passive bullshit, but I *can* idly happen to gesture towards a stable of buck teeth morons who might be able to help.");
        new FAQ(table, "Is there NOTHING you can tell me about defeating this weird Eye thing?","He’s in charge of Roots. Which somehow also means Root, the coding thing because SOMEONE decided puns would be a good engine to run reality on. There’s probably a couple of clues from JR if you do that whole Think Like A Waste shtick.");
    }

    if(ygdrassil.secretsForCalm.isNotEmpty) {
        new FAQ(table, "... What. The. Actual. Shit. Why did my tree grow Wigglers?", "Goddamn it. I thought we patched that. You must’ve picked up some extra scenes from the roots World Tree, Ygdrassil.<br><Br>Better hope you have an <a target = '_blank' href = 'http://www.farragofiction.com/WigglerSim/currentEmpress.html'>Empress</a> calm enough to not knee jerk cull these little guys, huh. Or I guess you could just....plant them?");
    }

    if(ygdrassil.underWorld.nidhogg.purified) {
        new FAQ(table, "... Well THAT was a thing.", "Congrats, you found the hacky bullshit solution, which, in our world, is obviously the PROPER solution. Have a Yellow Yard. Don’t ask where I got it.");

    }

    if(ygdrassil.pastFruit.length >= 288 && ygdrassil.bossDefeated) {
        new FAQ(table, "What was the point of getting 288 unique fruits???", "Our local master of reality wanted to give you a solid ‘crimson distraction fish’ (JUST CALL IT A  [redacted by order of jR]! LIKE A NORMAL PERSON!) on what the point of LOHAE is. Part of it was also was just them being curious how many unique kinds of fruits there were, and thinking it was fun to keep track of them. ");
    }else if(ygdrassil.pastFruit.length >= 288) {
        new FAQ(table, "What was the point of getting 288 unique fruits???", "Bullshit Bard restrictions means I can’t just tell you to go and do what I need you to do, so we have to litter in distractions. Wait. Shit. Have you not beaten it yet? Ignore me.");
    }

    if(ygdrassil.underWorld.player.hasItemWithSameNameAs(new Noir(ygdrassil))){
        new FAQ(table, "Does this noirsong have any reference to that one dude with the knives?","...Actually, no! Despite the fact that I tried to mix in a jazzy theme, the only reason its called 'noir' is because its associated with void and darkness and all that. Despite my attempts to try and fraymix it, it doesn't seem to actually DO anything. I blame that asshole messing around in the Root c-. Never mind!");

    }

    if(ygdrassil.underWorld.player.hasItemWithSameNameAs(new Splinters(ygdrassil))){
        new FAQ(table, "Splinters of... What now? You said something about this being primal?","Yeah, this was one of the first, if not THE first, songs I ever made. Its sound is a bit raw, a bit unrefined because of that. It was one of my first attempts at working the fraymixing system, trying to hide effects within the music. It was a bit unsuccessful- Like a lot of my songs, it can act like a fraymotif, but only in certain situations. Unlike some of my other songs, the activation conditions for this one aren't in this sim.");
    }

    if(ygdrassil.underWorld.player.hasItemWithSameNameAs(new Saphire(ygdrassil))){
        new FAQ(table, "You said you found 'Saphire Spires' in a cave or something?","Yeah, most of the flavor text for these is just a wee bit bullshit. I do tend to fuck around behind the scenes, but I don't really find music there. I usually lurk around the Root code, but recently this one asshole has been messing stuff up down there, making it hard to do my shtick. Goddamn jacking my goddamn style... Anyway, I can't exactly move on him directly- I'm a bard! We don't do face to face combat.");
    }

    if(ygdrassil.underWorld.player.hasItemWithSameNameAs(new Vethrfolnir(ygdrassil))){
        new FAQ(table, "What is up with this Verbi-. Vergith-. Vsomethingorother song?","Vethrfolnir was the massive Eagle who perched atop Ygdrassil, the World Tree. He oversaw the entirety of reality, all nine realms, intertwined within the World Trees branches and roots and leaves. He had a mortal enemy- Nidhogg, the Great Serpent, World Eater, Oath-breaker, Herald of The Twilight Of the Gods. Nidhogg lived in darkness, at the depths of the trees roots, gnawing at them, slowly but surely ripping away and corrupting the Life of that great and terrible Ash Tree. Between Nidhogg at the bottom and Verthrfolnir at the top ran Ratasook, a squirrel of some shape. He carried messages back and forth, insults from Eagle to Beast and Beast to Eagle. <br><br> What, you wanted to know WHY I wrote it? Eh, you'll figure it out.");
    }
    new FAQ(table, "What even IS this 'LOHAE' thing???", "The Land of Horticulture and Essence is...<br><br>Well...<br><br>Okay, bear with me now, but have you heard about Homestuck?<br><br>If yes, then it's meant to be a homestuck inspired Life Player land with Beaver consorts. <br><Br>If no, then. I dont dude, its a fantasy thing. Don’t think about it.");
    new FAQ(table, "Why is nothing happening???", "LOHAE is meant to be an idle game. Plant some trees, come back later and they'll be grown and you can harvest their fruits to sell to me to grow more trees and to raise money to buy things from me. <br><br>If nothing happens for more than, let's say... a half hour? Then there might be a bug. Send your <a href = 'meteor.html'>save data</a> to our local Omnipotent Codemiester via email, tumblr or discord (jadedResearcher in all three places) and maybe they can debug it and get you working again.");
    new FAQ(table, "Why is it called the 'Land of Horticulture and Essence'???", "'Horticulture' because you grow plants, duh. <br><br>Then why essence? Well.<br><br> Nyeheheheheheh.");
    new FAQ(table, "Who made all this???","This was made by <a target ='blank' href = 'http://farragofiction.com/SBURBSim/bio.html?staff=jadedResearcher'>jadedResearcher</a>, primary programmer for FarragoFiction, who made things like WigglerSim and SBURBSim and shit. <br><br><a target ='blank' href = 'http://farragofiction.com/SBURBSim/bio.html?staff=manicInsomniac'>manicInsomniac</a> (thats me!) handles the music, and sells you shit. <br><br><a target ='blank' href = 'http://farragofiction.com/SBURBSim/bio.html?staff=paradoxLands'>paradoxLands</a> did a lot of back end tools everything is built on top of.<br><Br><a target ='blank' href = 'http://farragofiction.com/SBURBSim/bio.html?staff=karmicRetribution'>karmicRetribution</a> helped all the aesthetics look better than they would if I was all on my own.<Br><Br><a target ='blank' href = 'http://www.farragofiction.com/SBURBSim/bio.html?staff=insufferableOracle'>InsufferableOracle</a> drew the landscape background you see everywhere, with the dark blue sky and the dark green grass. <br><br>Oh and <a target ='blank' href = 'http://farragofiction.com/CreditSim/?target=Cat,fireRachet.?'>Cat</a> helped brainstorm the name for LOHAE and features it would have.<br><Br><a href = 'http://farragofiction.com/CreditSim/?target=yearnfulNode'>yearnfulNode</a> made a bunch of fruit right before LOHAE went life.<br><br><a href = 'http://farragofiction.com/CreditSim/?target=dystopicFuturism'> dystopicFuturism</a> designed the first few fruits and flowers.");
    new FAQ(table, "Why did you make this???", "I’m gonna take a step back and let jR answer: Shit got real irl and I needed a small self contained project to keep me busy for the forseeable future. <br><Br> Plus it was soothing to draw all the initial assets for the trees.");
    new FAQ(table, "What is the Land of Horticulture and Essence's other name?", "Eheheheh.<br><br>What, you thought the answer to the puzzle would just BE here? I CAN assure that you probably aren't gonna guess the password until you've seen at least a few of LOHAE's secrets...<br><Br>And before I forget, NO, it is not case sensitive.");
    new FAQ(table, "Wait. You mean there's multiple secrets???","Muwahahahahah <br><Br>This was made by jR, what did you EXPECT? Even her secrets have secrets. Off the top of my head I can think of.... <br><br><li>Why is the canvas [REDACTED]???<li>What does the changing tree mean???<li>How do you move [REDACTED]??? <li>[??]<li>How do you defeat [REDACTED]??? (and there's multiple ways for that one)<li>what does [REDACTED] do??? (where theres like....at least 3 different [REDACTED]s.)<li>How do you upgrade [REDACTED]???<li>Oh! And the one this was all built around, how does this all relate to <a target = '_blank' href = 'http://www.farragofiction.com/WigglerSim'>WigglerSim</a>???<li>And of course, the classic: 'How do you Think Like a Waste(tm)???'<li>Oh! I almost forgot: How do you change the radius of the [REDACTED]??? <br><Br>I’m told I’m allowed to give you a freebie: This FAQ page updates itself depending on how your game is going.");
}

class FAQ {
    TableRowElement me;
    TableCellElement consortElement;
    TableCellElement textElement;
    String question;
    String answer;

    FAQ(TableElement table, String this.question, String this.answer) {

        me = new TableRowElement();
        table.append(me);
        Random rand = new Random();

        consortElement = new TableCellElement()..classes.add("consortStrip");
        consortElement.style.backgroundPosition = "${rand.nextInt(100)}% 0%";
        if(rand.nextDouble()>.99 && World.instance.underWorld.player.numberEssences > 7) {
            new SecretFAQConsort(consortElement,0);
        }else {
            new FAQConsort(consortElement, 0, "${rand.nextInt(2)}.gif");
        }

        textElement = new TableCellElement()..classes.add("faqWrapper");
        textElement.style.verticalAlign = "top";
        DivElement header = new DivElement()..text = "Q: $question"..classes.add("questionHeader");
        DivElement content = new DivElement()..setInnerHtml("A: $answer",treeSanitizer: NodeTreeSanitizer.trusted,validator: new NodeValidatorBuilder()..allowElement("a"))..classes.add("answerBody");
        textElement.append(header);
        textElement.append(content);
        textElement.colSpan = 4;

        if(rand.nextBool()) {
            me.append(consortElement);
            me.append(textElement);
        }else {
            me.append(textElement);
            me.append(consortElement);
        }


    }


}
