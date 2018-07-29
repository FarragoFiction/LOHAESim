import '../Gameplay/Consort.dart';
import '../Gameplay/Inventoryable/Fruit.dart';
import '../Gameplay/Player.dart';
import '../Gameplay/World.dart';
import 'dart:async';
import 'dart:html';
import "../Utility/TODOs.dart";

import 'dart:math' as Math;
import 'package:CommonLib/Collection.dart';
import 'package:CommonLib/NavBar.dart';
import 'package:CommonLib/Random.dart';
import 'package:DollLibCorrect/src/Dolls/PlantBased/FruitDoll.dart';
import "package:RenderingLib/src/loader/loader.dart" as OldRenderer;

Element output = querySelector('body');
World ygdrassil = new World();


Future<Null> main() async {
    await loadNavbar();
    await OldRenderer.Loader.preloadManifest();
    Consort.spawnConsorts(output);
    processVault();
}

void doToggleButton(Element vault) {
    DivElement button = new DivElement()..text = "Toggle All"..classes.add("vaultButton")..classes.add("storeButtonColor");
    vault.append(button);
    button.style.display = "block";
    button.onClick.listen((Event e)
    {
        List<Fruit> fruits = new List.from(ygdrassil.pastFruit.values);
        for(ArchivedFruit fruit in fruits) {
            fruit.toggleDetails();
        }
    });
}

void doSearch(Element vault) {
    TextInputElement input = new TextInputElement();
    DivElement button = new DivElement()..text = "Filter"..classes.add("vaultButton")..classes.add("storeButtonColor");
    vault.append(input);
    vault.append(button);
    button.onClick.listen((Event e)
    {
        String term = input.value.toLowerCase();
        List<Fruit> fruits = new List.from(ygdrassil.pastFruit.values);
        for(ArchivedFruit fruit in fruits) {
            if(term.isEmpty || fruit.hasTerm(term)) {
                fruit.show();
            }else {
                fruit.hide();
            }
        }
    });
}

Future<Null> processVault() async {
    consortPrint("thwap!! there are ${ygdrassil.pastFruit.values.length} seeds in the vault!!");
    DivElement vault = new DivElement();
    doSearch(vault);
    doToggleButton(vault);
    vault.classes.add('vault');
    output.append(vault);
    List<Fruit> fruits = new List.from(ygdrassil.pastFruit.values);
    //if they are all fruit, sort by body number, otherwise sort by doll type
    fruits.sort((Fruit a, Fruit b) {
        if(a.doll is FruitDoll && b.doll is FruitDoll) {
            return (a.doll as FruitDoll).body.imgNumber.compareTo((b.doll as FruitDoll).body.imgNumber);
        }else {
            return a.doll.renderingType.compareTo(b.doll.renderingType);
        }

    });

    for(ArchivedFruit fruit in fruits) {
        SpanElement wrapper = new SpanElement();
        vault.append(wrapper);
        //don't await it will be in same order no matter what
        initOneVaultCell(fruit, wrapper);
    }
}

Future<Null> initOneVaultCell(ArchivedFruit fruit, Element wrapper) async {
    await fruit.setCanvasForStore();
    await fruit.renderMyVault(wrapper);
}

