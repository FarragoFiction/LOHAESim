import 'Inventoryable/Inventoryable.dart';
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
            if(world.bossFight) {
                print("You absolute madman, you can't collect anything while NIDHOGG is awake!!! FIGHT!!!");
            }else {
                collected = true;
                if (this is Inventoryable) {
                    Inventoryable meAsItem = this as Inventoryable;
                    world.underWorld.player.inventory.add(meAsItem);
                    print("collected ${meAsItem.name} and added to inventory.");
                } else{
                    print("collected $this");
                }
            }
        }

        if(distance < giggleSnortRadius) {
            return "$specificPhrase. Or is it ${distance.round()}?";
        }

        return "";
    }


}