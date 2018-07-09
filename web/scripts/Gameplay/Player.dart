//wait what why is their a player???

import 'Secret.dart';

class Player extends Secret {
    //relative to underworld, center of player (not top left)

    int speed = 45;
    //don't let the player go below zero or above this
    int maxX;
    int maxY;
    int minX = 0;
    int minY = 0;

    int flashlightWidth =100;
    int flashlightHeight = 100;


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
        topLeftX += -42;
        if(topLeftX < minX) topLeftX = minX;
    }

    void right() {
        topLeftX += 42;
        if(topLeftX > maxX) topLeftX = maxX;
    }



}