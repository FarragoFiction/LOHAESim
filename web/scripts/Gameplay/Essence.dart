import 'CollectableSecret.dart';
import 'Inventoryable.dart';
import 'dart:async';

import 'dart:html';
import 'package:RenderingLib/RendereringLib.dart';

abstract class Essence extends CollectableSecret with Inventoryable {
  @override
  int width = 30;
  @override
  int height = 30;
  Essence(String specificPhrase, String imgLoc) : super(specificPhrase, imgLoc);

  static List<Essence> spawn() {
    List<Essence> allEssence = new List<Essence>()
        ..add(new BurgundyEssence())
        ..add(new BronzeEssence())
        ..add(new GoldEssence())
        ..add(new LimeEssence())
        ..add(new OliveEssence())
        ..add(new JadeEssence())
        ..add(new TealEssence())
        ..add(new CeruleanEssence())
        ..add(new IndigoEssence())
        ..add(new PurpleEssence())
        ..add(new VioletEssence())
        ..add(new FuchsiaEssence())
        ..add(new MutantEssence());

    return allEssence;
  }

  Future<Null> setCanvasForStore() async{
      CanvasElement me = new CanvasElement(width:width, height: height);
      ImageElement myImage = await image;
      me.context2D.drawImageScaled(myImage, x, y, width, height);
      Renderer.drawToFitCentered(me, itemCanvas);
  }


}


class BurgundyEssence extends Essence {
  BurgundyEssence() : super("It grows impatient.", "images/BGs/Essences/burgundy.png");
}

class BronzeEssence extends Essence {
  BronzeEssence() : super("It grows aloof.", "images/BGs/Essences/bronze.png");
}

class GoldEssence extends Essence {
  GoldEssence() : super("It grows calm.", "images/BGs/Essences/gold.png");
}

class LimeEssence extends Essence {
  LimeEssence() : super("It grows friendly.", "images/BGs/Essences/lime.png");
}

class OliveEssence extends Essence {
  OliveEssence() : super("It grows inwards.", "images/BGs/Essences/olive.png");
}

class JadeEssence extends Essence {
  JadeEssence() : super("It grows patient.", "images/BGs/Essences/jade.png");
}

class TealEssence extends Essence {
  TealEssence() : super("It grows outwards.", "images/BGs/Essences/teal.png");
}

class CeruleanEssence extends Essence {
  CeruleanEssence() : super("It grows curious.", "images/BGs/Essences/cerulean.png");
}

class IndigoEssence extends Essence {
  IndigoEssence() : super("It grows accepting.", "images/BGs/Essences/indigo.png");
}

class PurpleEssence extends Essence {
  PurpleEssence() : super("It grows rowdy.", "images/BGs/Essences/purple.png");
}

class VioletEssence extends Essence {
  VioletEssence() : super("It grows hopeful.", "images/BGs/Essences/violet.png");
}

class FuchsiaEssence extends Essence {
  FuchsiaEssence() : super("It grows energetic.", "images/BGs/Essences/fuchsia.png");
}

//spawns Nidhogg.
class MutantEssence extends Essence {
  MutantEssence() : super("It grows ???.", "images/BGs/Essences/mutant.png");
}