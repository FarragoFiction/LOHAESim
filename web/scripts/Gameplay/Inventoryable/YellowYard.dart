import '../CollectableSecret.dart';
import '../World.dart';
import 'Inventoryable.dart';
import 'dart:async';
import 'dart:html';

import 'package:RenderingLib/RendereringLib.dart';

class YellowYard extends CollectableSecret with Inventoryable{

    YellowYard(World world) : super(world, "Given to those who pass a Wastes Challenge with ample Restraint. (not to scale)", "images/BGs/yellowYard.png") {
        name = "Yellow Yard";
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