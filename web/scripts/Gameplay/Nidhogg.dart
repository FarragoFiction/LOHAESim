import 'CollectableSecret.dart';
import 'Inventoryable/Fruit.dart';
import 'Inventoryable/Inventoryable.dart';
import 'Inventoryable/Record.dart';
import 'OnScreenText.dart';
import 'Player.dart';
import 'World.dart';
import 'dart:html';
import "dart:math" as Math;

import 'package:DollLibCorrect/DollRenderer.dart';
import 'package:DollLibCorrect/src/Dolls/PlantBased/FruitDoll.dart';
import 'package:RenderingLib/RendereringLib.dart';

/*
when to json record if dead or not and hp
 */
class Nidhogg extends CollectableSecret {
  @override
  int width = 440;
  @override
  int height = 580;

  @override
  int giggleSnortRadius = 400;
  @override
  int collectionRadius = 200;

  //when you're zero or less you're dead
  int hp = 4037;
  int scaleDirection  = -1;

  DateTime lastSpoke;
  int timeBetweenSentences = 11000;
  DateTime lastTookDamage;
  int timeBetweenDamage = 700;

  bool get dead => hp <= 0;

  bool hadPain = false;


  int speechIndex = 0;
  List<String> speechLines = <String>["Child, Two Paths Lie Before You. Which Will Uou Choose?","Will You Choose to Extingish The Spark Of Life Within Your Own Children?","Or Will You Choose To Snuff Out My Own Spark?","Or...Is There a Third Path, a Hidden One?"];
  //then perish
  List<String> damageLines = <String>["Oof","Is This Your Choice Then?","So Be It.","I Shall Perish.", "The Spark of My Life Will Forever Go Out."];


  Nidhogg(World world) : super(world, "It sleeps.", "images/BGs/nidhoggTrue.png");


  bool canDamage(Record record) {
      return record.isFraymotif;
  }


  void attemptTalk() {
      if(scaleX < 0.98) {
          scaleDirection = scaleDirection * -1;
      }else if (scaleX > 1.0) {
          scaleDirection = scaleDirection * -1;
      }
      scaleX = scaleX - 0.001*scaleDirection;

      if(lastSpoke == null) return talk();
      DateTime now = new DateTime.now();
      Duration diff = now.difference(lastSpoke);
      // print("it's been ${diff.inMilliseconds} since last render, is that more than ${minTimeBetweenRenders}?");
      if(diff.inMilliseconds > timeBetweenSentences || (world.fraymotifActive && !hadPain)) {
          if(world.fraymotifActive) {
              if(!hadPain) {
                  speechIndex = 0; //start over
              }
              talkPain();
          }else if(speechIndex < speechLines.length) {
              talk();
          }
      }
  }

  void talk() {
      lastSpoke = new DateTime.now();
      world.texts.add(new NidhoggText(speechLines[speechIndex]));
      speechIndex ++;
      //if you're talking and not in pain and not too many trees, tree
      if(world.trees.length < world.maxTrees) {
          int randomX = new Random().nextInt(world.width);
          int randomY = new Random().nextInt(world.height);
          Point p = new Point(randomX, randomY);
          FruitDoll eye = new FruitDoll()..body.imgNumber = 24;
          Fruit fruit = new Fruit(eye);
          fruit.parents.add(new TreeDoll());
          world.plantATreeAtPoint(fruit, p);
      }
  }

  //wrap around
  void talkPain() {
      hadPain = true;
      lastSpoke = new DateTime.now();
      world.texts.add(new NidhoggPain(damageLines[speechIndex]));
      speechIndex ++;
      if(speechIndex >= damageLines.length) speechIndex = 0;
  }

  void attemptTakeDamage() {
      if(lastTookDamage == null) {
          return takeDamage();
      }
      DateTime now = new DateTime.now();
      Duration diff = now.difference(lastTookDamage);
      // print("it's been ${diff.inMilliseconds} since last render, is that more than ${minTimeBetweenRenders}?");
      if(diff.inMilliseconds > timeBetweenDamage && !dead) {
          takeDamage();
      }
  }

  void takeDamage() {
      int damage = -113;
      hp += damage;
      lastTookDamage = new DateTime.now();
      world.texts.add(new HPNotification("$damage"));
      if(dead) {
        world.nidhoggDies();
      }
  }


  void gigglesnort(Math.Point point) {
      int eyeX = 217;
      int eyeY = 364;
    Math.Point myPoint = new Math.Point(x+eyeX,y+eyeY);
    double distance = point.distanceTo(myPoint);
    if(distance < collectionRadius) {
      if(world.bossFight) {
          if(world.bossFightJustStarted)owoPrint("New friend!!! Get away from Nidhogg you can't fight him directly!!! And especially not with some weird ghost bear avatar!",48);
      }else {
          if(world.underWorld.player.hasActiveFlashlight) {
              world.activateBossFight();
          }else {
              owoPrint("Um. Are...are you sure you want to be here, new friend? Something seems to be....moving. In the dark. If only there were some way to turn on a light...",12);
          }
      }
    }

    if(distance < giggleSnortRadius) {
        if(world.bossFight) {
            owoPrint("$specificPhrase. Or is it ${distance.round()}?");
        }else {
            owoPrint("It GROWS!");
        }
    }

  }

}