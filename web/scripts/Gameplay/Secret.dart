import 'dart:async';
import 'dart:html';

import 'package:DollLibCorrect/DollRenderer.dart';

class Secret {
    int topLeftX = 400;
    int topLeftY = 300;
    int width = 92;
    int height = 92;


    num get x => topLeftX-width/2;
    num get y => topLeftY-height/2;

    String imgLoc = "images/BGs/owo.png";
    ImageElement _image;

    Future<ImageElement> get image async {
        if(_image == null) await initCanvasAndBuffer();
        return _image;
    }

    Future<Null> initCanvasAndBuffer() async {
        _image = await Loader.getResource(imgLoc);
    }
}