//wait what why is their a player???

import 'dart:async';
import 'dart:html';

import 'package:RenderingLib/RendereringLib.dart';

class Player {
    //relative to underworld, center of player (not top left)
    int x = 300;
    int y = 30;
    int flashlightWidth =100;
    int flashlightHeight = 100;
    String imgLoc = "images/BGs/owo.png";
    ImageElement _image;

    Future<ImageElement> get image async {
        if(_image == null) await initCanvasAndBuffer();
        return _image;
    }

    Future<Null> initCanvasAndBuffer() async {
        _image = await Loader.getResource("images/BGs/owo.png");
    }



}