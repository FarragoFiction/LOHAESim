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

    if(ygdrassil.bossFight) {
        new FAQ(table, "Shit where are my trees, what is going on? Why are there EYES???", "Gosh its ALMOST like you absconded from the middle of a boss fight to go read the FAQ like a total n00b!!<br><br> Let's break this down: *I* am not going to be giving you the answer here, but maybe there are some other friendly FAQ associated buck toothed morons who might be happy to help? I wonder if they ever babble about ominous shit.");
        new FAQ(table, "Is there NOTHING you can tell me about defeating this weird Eye thing?","Tell you what. If you know how to think like a Waste, maybe I have a couple clues sitting around for you. Knock yourself out.");
    }
    new FAQ(table, "What is the Land of Horticulture and Essence's other name?", "Hehehehe.<br><br>While giving you the answer would be cheating, I CAN assure that you probably aren't gonna guess the password until you've seen at least a FEW of LOHAE's secrets...");
    new FAQ(table, "Wait. You mean there's multiple secrets???",";) ;) ;)  <br><Br>Even my secrets have secrets. Off the top of my head I can think of.... <br><br><li>Why is the canvas [REDACTED]???<li>How do you move [REDACTED]??? <li>[??]<li>How do you defeat [REDACTED]??? (and there's multiple ways for that one)<li>what does [REDACTED] do??? (where theres like....at least 3 different [REDACTED]s.)<li>How do you upgrade [REDACTED]???<li>Oh! And the one this was all built around, how does this all relate to <a target = '_blank' href = 'http://www.farragofiction.com/WigglerSim'>WigglerSim</a>???<li>And of course, the classic: 'How do you Think Like a Waste(tm)???'  ");
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
