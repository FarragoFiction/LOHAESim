//wait what why is their a player???

import 'Secret.dart';
import 'World.dart';

class Player extends Secret {
    //relative to underworld, center of player (not top left)

    int speed = 45;
    //don't let the player go below zero or above this
    int maxX;
    int maxY;
    int minX = 0;
    int minY = 0;

    //TODO relative to size of moneybags
    int flashlightRadius =75;


    Player(World world, int this.maxX, int this.maxY):super(world);

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