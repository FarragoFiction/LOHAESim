import '../Gameplay/Consort.dart';
import '../Gameplay/Inventoryable/Record.dart';
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

    UListElement list = new UListElement()..classes.add("list");

    output.append(list);
    new Gigglesnort(list, "Play a relaxing idle game, by the makers of <a target = '_blank' href = 'http://www.farragofiction.com/WigglerSim/landing.html'>WigglerSim</a>.","What could go wrong?");
    new Gigglesnort(list, "Grow and hybridize procedural trees and harvest their fruit.","You might want to avoid the eyes...");
    new Gigglesnort(list, "Enjoy the local fauna.","Don't wake the Denizen, though.");
    new Gigglesnort(list, "There are definitely no secrets here.","Waste's Honor.");
    DivElement consortContainer = new DivElement();
    consortContainer.classes.add("consortStrip");
    output.append(consortContainer);
    new FAQConsort(consortContainer,300,"0.gif");

}


class Gigglesnort {
    String surfaceText;
    String rootText;

    Gigglesnort(UListElement container, String this.surfaceText, String this.rootText) {
        LIElement surface = new LIElement()..setInnerHtml(surfaceText,treeSanitizer: NodeTreeSanitizer.trusted,validator: new NodeValidatorBuilder()..allowElement("a"));
        surface.classes.add("gigglesnort");
        SpanElement span = new SpanElement()..text = " $rootText"..style.textDecoration="line-through";
        surface.append(span);
        span.style.display = "none";
        container.append(surface);

        surface.onMouseEnter.listen((Event e) {
            span.style.display = "inline";
        });

        surface.onMouseLeave.listen((Event e) {
            span.style.display = "none";
        });
    }
}