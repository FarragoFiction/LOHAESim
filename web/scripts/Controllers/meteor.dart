import '../Gameplay/World.dart';
import 'SaveSlot.dart';
import 'dart:async';
import 'dart:html';
import "../Utility/TODOs.dart";

import 'package:CommonLib/NavBar.dart';
import 'package:CommonLib/src/utility/JSONObject.dart';

Element output = querySelector('#output');
Future<Null> main() async{
    await loadNavbar();
    SaveSlot.handleSaveSlots(output);

    changeFPS();
}
void changeFPS() {
    World world = new World();
    DivElement wrapper = new DivElement()..text = "Change Frames Per Second (at your own peril)";
    wrapper.style.display = "block";
    DivElement label = new DivElement()..text = "Lower it from 30 to make older computers run better.";
    InputElement input = new InputElement();
    LabelElement label2 = new LabelElement()..text = "${world.musicSave.fps} fps";
    input.type = "range";
    input.min = "1";
    input.max = "60";
    input.value = "${world.musicSave.fps}";

    wrapper.append(label);
    wrapper.append(label2);
    wrapper.append(input);
    output.append(wrapper);

    input.onChange.listen((Event e) {
        label2.text = "${input.value} fps";
        world.musicSave.fps = int.parse(input.value);
        world.save("changing fps");
    });


}



