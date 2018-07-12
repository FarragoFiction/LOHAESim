import '../Gameplay/Essence.dart';
import '../Gameplay/Player.dart';
import '../Gameplay/Store.dart';
import '../Gameplay/World.dart';
import 'dart:html';
import "../Utility/TODOs.dart";

Element output = querySelector('#output');
World ygdrassil = new World(output);
Store store;
void main() {
    ygdrassil.health = 26;
    //example store, TODO have actual inventory system loaded from cache
    Store store = new Store(output, Essence.spawn());
    store.render();
}



