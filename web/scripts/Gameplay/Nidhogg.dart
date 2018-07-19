import 'CollectableSecret.dart';
import 'Inventoryable/Inventoryable.dart';
import 'Player.dart';
import 'World.dart';
import "dart:math" as Math;

class Nidhogg extends CollectableSecret {
  @override
  int width = 440;
  @override
  int height = 580;

  @override
  int giggleSnortRadius = 400;
  @override
  int collectionRadius = 200;

  Nidhogg(World world) : super(world, "It sleeps.", "images/BGs/nidhoggTrue.png");

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