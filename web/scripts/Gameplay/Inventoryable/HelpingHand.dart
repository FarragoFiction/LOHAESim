import '../CollectableSecret.dart';
import '../World.dart';
import 'Inventoryable.dart';
import 'dart:async';
import 'dart:html';

import 'package:RenderingLib/RendereringLib.dart';

class HelpingHand extends CollectableSecret with Inventoryable{

    HelpingHand(World world) : super(world, "It's time to pick some fruit. Don't worry about where this hand comes from, it's just here to help. Despap Citato.", "images/BGs/fruitPicking.png") {
        name = "Helping Hand";
        cost = 4037;
        description = specificPhrase;
    }

    Future<Null> setCanvasForStore() async{
        CanvasElement me = new CanvasElement(width:width, height: height);
        ImageElement myImage = await image;
        me.context2D.drawImageScaled(myImage, 0, 0, width, height);
        Renderer.drawToFitCentered(itemCanvas, me);
        //itemCanvas.context2D.drawImageScaled(me, 0,0,itemCanvas.width, itemCanvas.height);
    }



}