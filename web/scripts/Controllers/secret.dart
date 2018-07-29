import '../Gameplay/Player.dart';
import '../Gameplay/World.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:html';
import "../Utility/TODOs.dart";

import 'package:CommonLib/NavBar.dart';

Element output = querySelector('#output');
Future<Null> main() async {
    await loadNavbar();
    World ygdrassil = new World();
    ButtonElement button = querySelector("#pw_hint_button");
    button.onClick.listen((Event e) {
        Element spoiler = querySelector("#spoiler");
        print("display is ${spoiler.style.display}");
        if(spoiler.style.display == "block") {
            spoiler.style.display = "none";
        }else {
            spoiler.style.display = "block";
        }
    });

    TextInputElement input = querySelector("#pwtext");
    //how wastey do you feel i guess?? tho the right way to get this is a lot more satisfying, i hope
    String answer = "bGFuZCBvZiBob3Jyb3J0aWN1bHR1cmUgYW5kIGVzc2VuY2U=";
    consortPrint("what was the other name again?? i feel like the last time i remembered it Nidhogg was awake.. that was scary!! i sure hope it doesn't happen again!! thwap!! thwap!!");
    ButtonElement answerButton = querySelector("#pwButton");
    answerButton.onClick.listen((Event e) {
        String guess = input.value.toLowerCase();
        if(BASE64URL.encode(guess.codeUnits) == answer) {
            ygdrassil.playSoundEffect("340356__daehedon__medium-sized-indoor-crowd-clapping-intro");
            ygdrassil.updateFunds(9999);
            window.alert("You're right!!!");
        }else {
            window.alert("Nope!!!");
        }
    });
    ygdrassil.makeFundsElement(querySelector("#navbar"));


}
