//wait what why is their a player???

import 'dart:async';
import 'dart:html';

import 'package:RenderingLib/RendereringLib.dart';

class Player {
    //relative to underworld, center of player (not top left)
    int topLeftX = 400;
    int topLeftY = 300;
    int width = 92;
    int height = 92;
    int speed = 45;
    //don't let the player go below zero or above this
    int maxX;
    int maxY;
    int minX = 0;
    int minY = 0;


    num get x => topLeftX-width/2;
    num get y => topLeftY-height/2;



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

    Player(int this.maxX, int this.maxY);

    void up() {
        topLeftY += -42;
        if(topLeftY <minY) topLeftY = minY;
    }

    void down() {
        topLeftY += 42;
        if(topLeftY > maxY) topLeftY = maxY;
    }

    void left() {
        topLeftX += 42;
        if(topLeftX < minX) topLeftX = minX;
    }

    void right() {
        topLeftX += 42;
        if(topLeftX > maxX) topLeftX = maxX;
    }



}