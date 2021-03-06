import '../CollectableSecret.dart';
import '../World.dart';
import 'Inventoryable.dart';
import 'dart:async';
import 'dart:html';

import 'package:RenderingLib/RendereringLib.dart';

class Record extends CollectableSecret with Inventoryable{

    @override
    int sortPriority = 3;

    String songName;
    bool isFraymotif = false;
    @override
    bool canSell = true;

    String get happy => songName;
    String get creepy {
        //most songs don't have a distorted version so just use defaults
        return "Flow_on_2_Distorted";
    }

    Record(String this.songName, World world, String myName, String specificPhrase, String imgLoc) : super(world, specificPhrase, imgLoc) {
        name = myName;
        cost = 413;
        description = specificPhrase;
        type = name;
    }

    Future<Null> setCanvasForStore() async{
        CanvasElement me = new CanvasElement(width:width, height: height);
        ImageElement myImage = await image;
        me.context2D.drawImageScaled(myImage, 0, 0, width, height);
        Renderer.drawToFitCentered(itemCanvas, me);
        //itemCanvas.context2D.drawImageScaled(me, 0,0,itemCanvas.width, itemCanvas.height);
    }

    static Record getRecordFromName(String name) {
        List<Record> records = spawn(World.instance);
        for(Record r in records) {
            if(r.songName == name || r.creepy == name) {
                return r;
            }
        }
        throw("Couldn't find a Record named $name");
    }

    static List<Record> spawn(World world) {
        List<Record> ret = new List<Record>()
            ..add(new FlowOn(world))
            ..add(new Ares(world))
            ..add(new Noir(world))
            ..add(new Saphire(world))
            ..add(new Vethrfolnir(world))
            ..add(new Splinters(world));

        return ret;
    }


}

class FlowOn extends Record {
  FlowOn(World world) : super("Flow_on_2", world, "Flow On", "Changes the BG Music. Perfect to grow trees to.", "images/BGs/Records/recordB.png");
}

class Ares extends Record {
    @override
    String get creepy {
        return "Ares_Scordatura_Distorted";
    }
    Ares(World world) : super("Ares_Scordatura", world, "Ares Scordatura", "Changes the BG Music. For a slightly an ever so slightly more energetic gardening experience.", "images/BGs/Records/recordF.png");
}

class Noir extends Record {
    @override
    String get creepy {
        return "Noirsong_Distorted";
    }
    Noir(World world) : super("Noirsong", world, "Noir Song", "Changes the BG Music. A cool buildup of a song for the discerning gardener. ", "images/BGs/Records/recordD.png");
}

class Saphire extends Record {
    @override
    String get creepy {
        return "${songName}_Distorted";
    }
    Saphire(World world) : super("Saphire_Spires", world, "Saphire Spires", "Changes the BG Music. Recovered from deep within the bowels of the earth in a cave where they have forgotten what light is. Perfect to shop to.", "images/BGs/Records/recordE.png");
}

class Splinters extends Record {
    @override
    String get creepy {
        return "Royalty_Reformed";
    }
    Splinters(World world) : super("Splinters_of_Royalty", world, "Splinters of Royalty", "Changes the BG Music. A primal song, something that came before. Full warning: Contains techno.", "images/BGs/Records/recordA.png");
}

class Vethrfolnir extends Record {
    @override
    bool isFraymotif = true;

    @override
    String get creepy {
        return songName; //never changes
    }
    Vethrfolnir(World world) : super("Vethrfolnir", world, "Vethrfolnir", "Changes the BG Music. Wow. This song is WAY too angry to garden to. Why is this even in here???", "images/BGs/Records/recordC.png") {
        cost = 612;
    }

}