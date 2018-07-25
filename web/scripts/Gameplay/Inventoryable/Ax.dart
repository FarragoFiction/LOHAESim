import '../CollectableSecret.dart';
import '../World.dart';
import 'Inventoryable.dart';
import 'dart:async';
import 'dart:html';

import 'package:RenderingLib/RendereringLib.dart';

class Ax extends CollectableSecret with Inventoryable{

    Ax(World world) : super(world, "Use it to chop down unwanted trees. But why would you do this???", "images/BGs/talosAx2.png") {
        name = "ShogunBot's Ax";
        cost = 4037;
        description = specificPhrase;
        type = "Ax";
    }

    Future<Null> setCanvasForStore() async{
        CanvasElement me = new CanvasElement(width:width, height: height);
        ImageElement myImage = await image;
        me.context2D.drawImageScaled(myImage, 0, 0, width, height);
        Renderer.drawToFitCentered(itemCanvas, me);
        //itemCanvas.context2D.drawImageScaled(me, 0,0,itemCanvas.width, itemCanvas.height);
    }


}