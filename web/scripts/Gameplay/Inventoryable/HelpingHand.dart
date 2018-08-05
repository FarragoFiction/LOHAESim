import '../CollectableSecret.dart';
import '../World.dart';
import 'Inventoryable.dart';
import 'dart:async';
import 'dart:html';

import 'package:RenderingLib/RendereringLib.dart';

class HelpingHand extends CollectableSecret with Inventoryable{
    @override
    int sortPriority = 1;

    int tier = 1;
    HelpingHand(World world) : super(world, "It's time to pick some fruit. Don't worry about where this hand comes from, it's just here to help. Despap Citato.", "images/BGs/fruitPicking.png") {
        name = "Helping Hand";
        cost = 333;
        description = specificPhrase;
        type = "Helping Hand";

    }

    Future<Null> setCanvasForStore() async{
        CanvasElement me = new CanvasElement(width:width, height: height);
        ImageElement myImage = await image;
        me.context2D.drawImageScaled(myImage, 0, 0, width, height);
        Renderer.drawToFitCentered(itemCanvas, me);
        //itemCanvas.context2D.drawImageScaled(me, 0,0,itemCanvas.width, itemCanvas.height);
    }



}

class HelpingHandPlusUltra extends HelpingHand with Inventoryable {
  HelpingHandPlusUltra(World world) : super(world) {
      sortPriority = 1;
      tier = 2;
    name = "Helping Hand Plus Ultra";
    specificPhrase = "Go Beyond! (The normal mortal limits on how many fruit you can pick at a time.)";
    description = specificPhrase;
    cost = 333;
    type = "Helping Hand Plus Ultra";
    imgLoc = "images/BGs/fruitPicking2.png";
  }

}

class HelpingHandCorrupt extends HelpingHand with Inventoryable {
    HelpingHandCorrupt(World world) : super(world) {
        sortPriority = 1;

        name = "Nidhogg's Hand";
        tier = 3;
        specificPhrase = "Shhh...only Fruit now.";
        description = specificPhrase;
        cost = 4037;
        type = "HelpingHandCorrupt";
        imgLoc = "images/BGs/fruitPickingOmni.png";
    }

}