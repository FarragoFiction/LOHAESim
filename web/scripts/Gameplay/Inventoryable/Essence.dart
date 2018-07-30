import '../CollectableSecret.dart';
import '../Inventoryable/Inventoryable.dart';
import '../Player.dart';
import '../World.dart';
import 'dart:async';

import 'dart:html';
import 'package:RenderingLib/RendereringLib.dart';

abstract class Essence extends CollectableSecret with Inventoryable {
  @override
  int width = 30;
  @override
  int height = 30;
  Essence(World world, String myName, String specificPhrase, String imgLoc) : super(world, specificPhrase, imgLoc) {
      //for store
    name = myName;
    description = specificPhrase;
    hidden = true;
    type = myName;
  }

  static List<Essence> spawn(World world, Player player, [bool forceAll = false]) {
    List<Essence> allEssence = new List<Essence>();

    Essence essence = new BurgundyEssence(world);
    if(forceAll || !player.hasItem(essence)){
        allEssence.add(essence);
    }
    essence = new BronzeEssence(world);
    if(forceAll ||!player.hasItem(essence)){
        allEssence.add(essence);
    }
    essence =(new GoldEssence(world));
    if(forceAll ||!player.hasItem(essence)){
        allEssence.add(essence);
    }
    essence =(new LimeEssence(world));
    if(forceAll ||!player.hasItem(essence)){
        allEssence.add(essence);
    }
    essence =(new OliveEssence(world));
    if(forceAll ||!player.hasItem(essence)){
        allEssence.add(essence);
    }
    essence =(new JadeEssence(world));
    if(forceAll ||!player.hasItem(essence)){
        allEssence.add(essence);
    }
    essence =(new TealEssence(world));
    if(forceAll ||!player.hasItem(essence)){
        allEssence.add(essence);
    }
    essence =(new CeruleanEssence(world));
    if(forceAll ||player.hasItem(essence)){
        allEssence.add(essence);
    }
    essence =(new IndigoEssence(world));
    if(forceAll ||player.hasItem(essence)){
        allEssence.add(essence);
    }
    essence =(new PurpleEssence(world));
    if(forceAll ||player.hasItem(essence)){
        allEssence.add(essence);
    }
    essence =(new VioletEssence(world));
    if(forceAll ||player.hasItem(essence)){
        allEssence.add(essence);
    }
    essence =(new FuchsiaEssence(world));
    if(forceAll ||!player.hasItem(essence)){
        allEssence.add(essence);
    }
    essence =(new MutantEssence(world));
    if(forceAll ||!player.hasItem(essence)){
        allEssence.add(essence);
    }

    return allEssence;
  }

  Future<Null> setCanvasForStore() async{
      CanvasElement me = new CanvasElement(width:width, height: height);
      ImageElement myImage = await image;
      me.context2D.drawImageScaled(myImage, 0, 0, width, height);
      Renderer.drawToFitCentered(itemCanvas, me);
      //itemCanvas.context2D.drawImageScaled(me, 0,0,itemCanvas.width, itemCanvas.height);
      //print("i drew myself ($name) to the item canvas for the store");
  }


}


class BurgundyEssence extends Essence {
  BurgundyEssence(World world) : super(world,"Burgundy Essence","It grows impatient.", "images/BGs/Essences/burgundy.png");
}

class BronzeEssence extends Essence {
  BronzeEssence(World world) : super(world,"Bronze Essence","It grows aloof.", "images/BGs/Essences/bronze.png");
}

class GoldEssence extends Essence {
  GoldEssence(World world) : super(world,"Gold Essence","It grows calm.", "images/BGs/Essences/gold.png");
}

class LimeEssence extends Essence {
  LimeEssence(World world) : super(world,"Lime Essence","It grows friendly.", "images/BGs/Essences/lime.png");
}

class OliveEssence extends Essence {
  OliveEssence(World world) : super(world,"Olive Essence","It grows inwards.", "images/BGs/Essences/olive.png");
}

class JadeEssence extends Essence {
  JadeEssence(World world) : super(world,"Jade Essence","It grows patient.", "images/BGs/Essences/jade.png");
}

class TealEssence extends Essence {
  TealEssence(World world) : super(world,"Teal Essence","It grows outwards.", "images/BGs/Essences/teal.png");
}

class CeruleanEssence extends Essence {
  CeruleanEssence(World world) : super(world,"Cerulean Essence","It grows curious.", "images/BGs/Essences/cerulean.png");
}

class IndigoEssence extends Essence {
  IndigoEssence(World world) : super(world,"Indigo Essence","It grows accepting.", "images/BGs/Essences/indigo.png");
}

class PurpleEssence extends Essence {
  PurpleEssence(World world) : super(world,"Purple Essence","It grows rowdy.", "images/BGs/Essences/purple.png");
}

class VioletEssence extends Essence {
  VioletEssence(World world) : super(world,"Violet Essence","It grows hopeful.", "images/BGs/Essences/violet.png");
}

class FuchsiaEssence extends Essence {
  FuchsiaEssence(World world) : super(world,"Fuchsia Essence","It grows energetic.", "images/BGs/Essences/fuchsia.png");
}

//spawns Nidhogg.
class MutantEssence extends Essence {
  MutantEssence(World world) : super(world,"Mutant Essence","It grows ???.", "images/BGs/Essences/mutant.png");
}