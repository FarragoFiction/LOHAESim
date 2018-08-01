import '../Gameplay/Consort.dart';
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
        new FAQ(table, "Oh god what is that thing!?", "Hehehehe");
        new FAQ(table, "Okay, seriously, what's the point of Flashlight???", "Hehehehe, I wonder if there is anywhere dark???");
    }

    if(ygdrassil.bossFight) {
        new FAQ(table, "Shit where are my trees, what is going on? Why are there EYES???", "Gosh its ALMOST like you absconded from the middle of a boss fight to go read the FAQ like a total n00b!!!<br><br> Let's break this down: *I* am not going to be giving you the answer here, but maybe there are some other friendly FAQ associated buck toothed morons who might be happy to help? I wonder if they ever babble about ominous shit.");
        new FAQ(table, "Is there NOTHING you can tell me about defeating this weird Eye thing?","Tell you what. If you know how to think like a Waste, maybe I have a couple of clues sitting around for you. Knock yourself out.");
    }

    if(ygdrassil.secretsForCalm.isNotEmpty) {
        new FAQ(table, "... What. The. Actual. Shit. Why did my tree grow Wigglers?", "I mean. What did you THINK would happen when you planted weird color coded Essence Orbs you found randomly hidden in the roots of the World Tree, Ygdrassil???<br><Br>Better hope you have an <a target = '_blank' href = 'http://www.farragofiction.com/WigglerSim/currentEmpress.html'>Empress</a> calm enough to not knee jerk cull these little guys, huh. Or I guess you could just....plant them???");
    }

    if(ygdrassil.underWorld.nidhogg.purified) {
        new FAQ(table, "... Well THAT was a thing.", "Congrats!!! You actually got the True Ending and earned your Yellow Yard. Did all my gigglesnort help?");

    }

    if(ygdrassil.pastFruit.length >= 288 && ygdrassil.bossDefeated) {
        new FAQ(table, "What was the point of getting 288 unique fruits???", "Well, I mean, part of it was to give you a solid crimson distraction fish on what the point of LOHAE is. Part of it was also was just me being curious how many unique kinds of fruits there were, and thinking it was fun to keep track of 'em.");
    }else if(ygdrassil.pastFruit.length >= 288) {
        new FAQ(table, "What was the point of getting 288 unique fruits???", "Well, I mean, part of it was to give you a solid crimson distraction fish on what the point of LOHAE is. Wait. Shit. Have you not beaten it yet??? Never mind that.");
    }

    new FAQ(table, "What even IS this 'LOHAE' thing???", "The Land of Horticulture and Essence is...<br><br>Well...<br><br>Okay, bear with me now, but have you heard about Homestuck?<br><br>If yes, then it's meant to be a homestuck inspired Life Player land with Beaver consorts. <br><Br>If no....well...it's a fantasy game???");
    new FAQ(table, "Why is nothing happening???", "LOHAE is meant to be an idle game. Plant some trees, come back later and they'll be grown and you can harvet their fruits to grow more trees and to raise money to buy things from the store. <br><br>If nothing happens for more than, let's say... a half hour? Then there might be a bug. Send your <a href = 'meteor.html'>save data</a> to me via email, tumblr or discord (I'm jadedResearcher in all three places) and maybe I can debug it and get you working again.");
    new FAQ(table, "Why is it called the 'Land of Horticulture and Essence'???", "The 'Horticulture' part is easy-peasy, you grow plants!<br><br>As for Essence...I'll leave that as an exercise to the Player.");
    new FAQ(table, "Who all made this???", "I'm <a target ='blank' href = 'http://farragofiction.com/SBURBSim/bio.html?staff=jadedResearcher'>jadedResearcher</a>, primary programmer for FarragoFiction, I made things like WigglerSim and SBURBSim and shit.  <br><br><a target ='blank' href = 'http://farragofiction.com/SBURBSim/bio.html?staff=paradoxLands'>paradoxLands</a> did a lot of back end tools everything is built on top of.<br><Br><a target ='blank' href = 'http://farragofiction.com/SBURBSim/bio.html?staff=karmicRetribution'>karmicRetribution</a> helped all the aesthetics look better than they would if I was all on my own.<Br><Br><a target ='blank' href = 'http://www.farragofiction.com/SBURBSim/bio.html?staff=insufferableOracle'>InsufferableOracle</a> drew the landscape background I use everywhere, with the dark blue sky and the dark green grass. <br><br><a target ='blank' href = 'http://farragofiction.com/SBURBSim/bio.html?staff=manicInsomniac'>manicInsomniac</a> handled the music, and is also the shopkeep for the store.<br><br>Oh and <a target ='blank' href = 'http://farragofiction.com/CreditSim/?target=Cat,fireRachet.?'>Cat</a> helped brainstorm the name for LOHAE and features it would have :) :) :)");
    new FAQ(table, "Why did you make this???", "Shit got real irl and I needed a small self contained project to keep me busy for the forseeable future. <br><Br> Plus it was soothing to draw all the initial assets for the trees.");
    new FAQ(table, "What is the Land of Horticulture and Essence's other name?", "Hehehehe.<br><br>While giving you the answer would be cheating, I CAN assure that you probably aren't gonna guess the password until you've seen at least a FEW of LOHAE's secrets...<br><Br>And before I forget, NO, it is not case sensitive.");
    new FAQ(table, "Wait. You mean there's multiple secrets???",";) ;) ;)  <br><Br>Even my secrets have secrets. Off the top of my head I can think of.... <br><br><li>Why is the canvas [REDACTED]???<li>What does the changing tree mean???<li>How do you move [REDACTED]??? <li>[??]<li>How do you defeat [REDACTED]??? (and there's multiple ways for that one)<li>what does [REDACTED] do??? (where theres like....at least 3 different [REDACTED]s.)<li>How do you upgrade [REDACTED]???<li>Oh! And the one this was all built around, how does this all relate to <a target = '_blank' href = 'http://www.farragofiction.com/WigglerSim'>WigglerSim</a>???<li>And of course, the classic: 'How do you Think Like a Waste(tm)???'<li>Oh! I almost forgot: How do you change the radius of the [REDACTED]??? <br><Br>Tell you what though, I'll give you a freebie: This FAQ page updates itself depending on how your game is going ;) ;) ;) ");
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
        FAQConsort consort = new FAQConsort(consortElement, 0, "${rand.nextInt(2)}.gif");

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
