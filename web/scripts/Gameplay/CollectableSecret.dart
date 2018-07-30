import 'Inventoryable/Inventoryable.dart';
import 'Player.dart';
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

    void gigglesnort(Math.Point point) {
        Math.Point myPoint = new Math.Point(x,y);
        double distance = point.distanceTo(myPoint);
        if(distance < collectionRadius) {
            if(world.bossFight) {
                owoPrint("New Friend, you can't collect anything while NIDHOGG is awake!!! FIGHT!!!",48);
            }else {
                collected = true;
                if (this is Inventoryable) {
                    Inventoryable meAsItem = this as Inventoryable;
                    world.underWorld.player.inventory.add(meAsItem);
                    if(world.bossDefeated) meAsItem.hidden = false;
                    owoPrint("You got a ${meAsItem.name}!!! I wonder what it will take to use it???",33);
                } else{
                    owoPrint("You got a $this!!! I don't think it does anything though, New Friend...");
                }
            }
        }

        if(distance < giggleSnortRadius) {
            owoPrint("$specificPhrase. Or is it ${distance.round()}?");
        }

    }


}