import '../CollectableSecret.dart';
import '../World.dart';
import 'Inventoryable.dart';
import 'dart:async';
import 'dart:html';

import 'package:RenderingLib/RendereringLib.dart';

class Record extends CollectableSecret with Inventoryable{

    String songName;

    Record(String this.songName, World world, String myName, String specificPhrase, String imgLoc) : super(world, specificPhrase, imgLoc) {
        name = myName;
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

    static List<Record> spawn(World world) {
        List<Record> ret = new List<Record>()
            ..add(new FlowOn(world))
            ..add(new Ares(world))
            ..add(new Noir(world))
            ..add(new Saphire(world))
            ..add(new Splinters(world));
        return ret;
    }


}

class FlowOn extends Record {
  FlowOn(World world) : super("Flow_On2", world, "Flow On", "Perfect to grow trees to.", "images/BGs/Records/recordB.png");
}

class Ares extends Record {
    Ares(World world) : super("Ares_Scordatura", world, "Ares Scordatura", "Powerful.", "images/BGs/Records/recordF.png");
}

class Noir extends Record {
    Noir(World world) : super("Noirsong", world, "Noir Song", "Black and White.", "images/BGs/Records/recordD.png");
}

class Saphire extends Record {
    Saphire(World world) : super("Saphire_Spires", world, "Saphire Spires", "Perfect to shop to.", "images/BGs/Records/recordE.png");
}

class Splinters extends Record {
    Splinters(World world) : super("Splinters_of_Royalty", world, "Splinters of Royalty", "Invokes images of moons, somehow.", "images/BGs/Records/recordA.png");
}