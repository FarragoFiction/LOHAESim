import '../Gameplay/Consort.dart';
import '../Gameplay/World.dart';
import 'dart:async';
import 'dart:html';
import "../Utility/TODOs.dart";

import 'package:CommonLib/NavBar.dart';
import 'package:CommonLib/Random.dart';

Element output = querySelector('#output');
World ygdrassil = new World();

Future<Null> main() async {
    await loadNavbar();
    start();
}

void start() {
    TableElement table = new TableElement()..classes.add("container");
    output.append(table);
    new FAQ(table, "What even IS this 'LOHAE' thing???", "The Land of Horticulture and Essence is...<br><br>Well...<br><br>Okay, bear with me now, but have you heard about Homestuck?<br><br>If yes, then it's meant to be a homestuck inspired Life Player land with Beaver consorts. <br><Br>If no....well...it's a fantasy game???");
    new FAQ(table, "Why is nothing happening???", "LOHAE is meant to be an idle game. Plant some trees, come back later and they'll be grown and you can harvet their fruits to grow more trees and to raise money to buy things from the store. <br><br>If nothing happens for more than, let's say... a half hour? Then there might be a bug. Send your <a href = 'meteor.html'>save data</a> to me via email, tumblr or discord (I'm jadedResearcher in all three places) and maybe I can debug it and get you working again.");
    new FAQ(table, "Why is it called the 'Land of Horticulture and Essence'???", "The 'Horticulture' part is easy-peasy, you grow plants!<br><br>As for Essence...I'll leave that as an exercise to the Player.");
    new FAQ(table, "Who all made this???", "I'm <a href = 'http://farragofiction.com/SBURBSim/bio.html?staff=jadedResearcher'>jadedResearcher</a>, primary programmer for FarragoFiction, I made things like WigglerSim and SBURBSim and shit.  <br><br><a href = 'http://farragofiction.com/SBURBSim/bio.html?staff=paradoxLands'>paradoxLands</a> did a lot of back end tools everything is built on top of.<br><Br><a href = 'http://farragofiction.com/SBURBSim/bio.html?staff=karmicRetribution'>karmicRetribution</a> helped all the aesthetics look better than they would if I was all on my own. <br><br><a href = 'http://farragofiction.com/SBURBSim/bio.html?staff=manicInsomniac'>manicInsomniac</a> handled the music, and is also the shopkeep for the store.<br><br>Oh and <a href = 'http://farragofiction.com/CreditSim/?target=Cat,fireRachet.?'>Cat</a> helped brainstorm the name for LOHAE and features it would have :) :) :)");
    new FAQ(table, "Why did you make this???", "Shit got real irl and I needed a small self contained project to keep me busy for the forseeable future. <br><Br> Plus it was soothing to draw all the initial assets for the trees.");


    if(ygdrassil.underWorld.player.canBuyFlashlight) {
        new FAQ(table, "Oh god what is that thing!?", "Hehehehe");
    }
    new FAQ(table, "What is the Land of Horticulture and Essence's other name?", "Hehehehe");
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
