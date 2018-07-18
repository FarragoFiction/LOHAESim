import 'CollectableSecret.dart';
import 'Inventoryable/Inventoryable.dart';
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

  String gigglesnort(Math.Point point) {
      int eyeX = 217;
      int eyeY = 364;
    Math.Point myPoint = new Math.Point(x+eyeX,y+eyeY);
    double distance = point.distanceTo(myPoint);
    if(distance < collectionRadius) {
      if(world.bossFight) {
        print("You absolute madman, get away from Nidhogg you can't fight him directly!!! And especially not with some weird ghost bear avatar!");
      }else {
          if(world.underWorld.player.hasActiveFlashlight) {
              world.activateBossFight();
          }else {
            print("Um. Are...are you sure you want to be here? Something seems to be....moving. In the dark. If only there were some way to turn on a light...");
          }
      }
    }

    if(distance < giggleSnortRadius) {
      return "$specificPhrase. Or is it ${distance.round()}?";
    }

    return "";
  }

}