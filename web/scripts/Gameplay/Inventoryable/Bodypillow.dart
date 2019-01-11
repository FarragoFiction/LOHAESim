import '../CollectableSecret.dart';
import '../World.dart';
import 'Inventoryable.dart';
import 'dart:async';
import 'dart:html';

import 'package:RenderingLib/RendereringLib.dart';

//should togggle nidhogg between corurpt and pure states
class BodyPillow extends CollectableSecret with Inventoryable{
    @override
    int sortPriority = 2;

    BodyPillow(World world) : super(world, "You...wonder why anyone would actually sleep with this, and if there is a 'real world' analogue.", "images/BGs/bodypillow.png") {
        name = "Body Pillow Of Nidhogg";
        cost = 4037;
        description = specificPhrase;
        type = name;

    }

    Future<Null> setCanvasForStore() async{
        CanvasElement me = new CanvasElement(width:width, height: height);
        print("awaiting my image i guess??? $imgLoc");
        ImageElement myImage = await image;
        me.context2D.drawImageScaled(myImage, 0, 0, width, height);
        Renderer.drawToFitCentered(itemCanvas, me);
        //itemCanvas.context2D.drawImageScaled(me, 0,0,itemCanvas.width, itemCanvas.height);
    }


}