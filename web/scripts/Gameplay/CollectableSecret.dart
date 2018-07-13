import 'Secret.dart';
import 'World.dart';
import "dart:math" as Math;
//TODO if you pick up a collectable it's removed, only to respawn much later.
class CollectableSecret extends Secret {
    String specificPhrase = "???";
    int giggleSnortRadius = 100;
    int collectionRadius = 50;
    bool collected = false;


    CollectableSecret(World world, String this.specificPhrase, String imgLoc):super(world) {
        this.imgLoc = imgLoc;
    }

    String gigglesnort(Math.Point point) {
        Math.Point myPoint = new Math.Point(x,y);
        double distance = point.distanceTo(myPoint);
        if(distance < collectionRadius) {
            collected  = true;
            print("collected $this");
            //TODO add to inventory
        }

        if(distance < giggleSnortRadius) {
            return "$specificPhrase. Or is it ${distance.round()}?";
        }

        return "";
    }


}