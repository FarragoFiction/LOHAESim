import 'World.dart';
import 'dart:async';
import 'dart:html';

import 'package:LoaderLib/Loader.dart';


class Secret {
    int topLeftX = 400;
    int topLeftY = 300;
    int width = 92;
    int height = 92;
    //need to know what to do when found
    World world;
    double scaleX = 1.0;
    double scaleY = 1.0;


    num get x => topLeftX-width/2;
    num get y => topLeftY-height/2;

    String imgLoc = "images/BGs/owo.png";
    ImageElement _image;

    Future<ImageElement> get image async {
        if(_image == null) await initCanvasAndBuffer();
        return _image;
    }

    Secret(World this.world);

    Future<Null> initCanvasAndBuffer() async {
        _image = await Loader.getResource(imgLoc);
    }

    Future<Null> render(CanvasElement buffer) async {
        ImageElement myImage = await image;
        buffer.context2D.drawImageScaled(myImage, x, y, width*scaleX, height*scaleY);
    }
}