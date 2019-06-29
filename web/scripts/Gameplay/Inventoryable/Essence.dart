import 'package:CommonLib/Colours.dart';

import '../CollectableSecret.dart';
import '../Inventoryable/Inventoryable.dart';
import '../Player.dart';
import '../World.dart';
import 'dart:async';

import 'dart:html';
import 'package:DollLibCorrect/src/Rendering/ReferenceColors.dart';
import 'package:RenderingLib/RendereringLib.dart';

abstract class Essence extends CollectableSecret with Inventoryable {
    @override
    int sortPriority = 9;

    @override
  int width = 30;
  @override
  int height = 30;
  Palette palette = ReferenceColours.CORRUPT;
  Essence(World world, String myName, String specificPhrase, String imgLoc) : super(world, specificPhrase, imgLoc) {
      //for store
    name = myName;
    description = specificPhrase;
    hidden = true;
    type = myName;
  }

  static List<Essence> spawn(World world) {
      List<Essence> allEssence = new List<Essence>()
          ..add(new BurgundyEssence(world))
          ..add(new BronzeEssence(world))
          ..add(new GoldEssence(world))
          ..add(new LimeEssence(world))
          ..add(new OliveEssence(world))
          ..add(new JadeEssence(world))
          ..add(new TealEssence(world))
          ..add(new CeruleanEssence(world))
          ..add(new IndigoEssence(world))
          ..add(new PurpleEssence(world))
          ..add(new VioletEssence(world))
          ..add(new FuchsiaEssence(world))
          ..add(new MutantEssence(world));

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
    @override
    Palette palette = ReferenceColours.BURGUNDY;
  BurgundyEssence(World world) : super(world,"Burgundy Essence","It grows impatient.", "images/BGs/Essences/burgundy.png");
}

class BronzeEssence extends Essence {
    @override
    Palette palette = ReferenceColours.BRONZE;
  BronzeEssence(World world) : super(world,"Bronze Essence","It grows aloof.", "images/BGs/Essences/bronze.png");
}

class GoldEssence extends Essence {
    @override
    Palette palette = ReferenceColours.GOLD;
  GoldEssence(World world) : super(world,"Gold Essence","It grows calm.", "images/BGs/Essences/gold.png");
}

class LimeEssence extends Essence {
    @override
    Palette palette = ReferenceColours.LIMEBLOOD;
  LimeEssence(World world) : super(world,"Lime Essence","It grows friendly.", "images/BGs/Essences/lime.png");
}

class OliveEssence extends Essence {
    @override
    Palette palette = ReferenceColours.OLIVE;
  OliveEssence(World world) : super(world,"Olive Essence","It grows inwards.", "images/BGs/Essences/olive.png");
}

class JadeEssence extends Essence {
    @override
    Palette palette = ReferenceColours.JADE;
  JadeEssence(World world) : super(world,"Jade Essence","It grows patient.", "images/BGs/Essences/jade.png");
}

class TealEssence extends Essence {
    @override
    Palette palette = ReferenceColours.TEAL;
  TealEssence(World world) : super(world,"Teal Essence","It grows outwards.", "images/BGs/Essences/teal.png");
}

class CeruleanEssence extends Essence {
    @override
    Palette palette = ReferenceColours.CERULEAN;
  CeruleanEssence(World world) : super(world,"Cerulean Essence","It grows curious.", "images/BGs/Essences/cerulean.png");
}

class IndigoEssence extends Essence {
    @override
    Palette palette = ReferenceColours.INDIGO;
  IndigoEssence(World world) : super(world,"Indigo Essence","It grows accepting.", "images/BGs/Essences/indigo.png");
}

class PurpleEssence extends Essence {
    @override
    Palette palette = ReferenceColours.PURPLE;
  PurpleEssence(World world) : super(world,"Purple Essence","It grows rowdy.", "images/BGs/Essences/purple.png");
}

class VioletEssence extends Essence {
    @override
    Palette palette = ReferenceColours.VIOLET;
  VioletEssence(World world) : super(world,"Violet Essence","It grows hopeful.", "images/BGs/Essences/violet.png");
}

class FuchsiaEssence extends Essence {
    @override
    Palette palette = ReferenceColours.FUSCHIA;
  FuchsiaEssence(World world) : super(world,"Fuchsia Essence","It grows energetic.", "images/BGs/Essences/fuchsia.png");
}

//spawns Nidhogg.
class MutantEssence extends Essence {
    @override
    Palette palette = ReferenceColours.CORRUPT;
  MutantEssence(World world) : super(world,"Mutant Essence","It grows ???.", "images/BGs/Essences/mutant.png");
}