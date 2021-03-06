import 'package:CommonLib/Colours.dart';
import 'package:CommonLib/Random.dart';

import 'World.dart';
import 'dart:html';
import 'package:RenderingLib/RendereringLib.dart';

class OnScreenText {
    String text;
    int fontSize = 48;
    String font = "Courier New";
    Colour color1;
    Colour color2;
    int x;
    int y;
    int millisOnScreen;
    DateTime firstRender;
    bool finished = false;

    int width = 500;


    OnScreenText(String this.text, int this.x, int this.y, Colour this.color1, Colour this.color2, {int this.millisOnScreen: 10000});

    bool checkFinished() {
        if(firstRender == null) firstRender = new DateTime.now();
        DateTime now = new DateTime.now();
        Duration diff = now.difference(firstRender);
        if(diff.inMilliseconds >= millisOnScreen){
            finished = true;
            return true;
        }
        return false;
    }

    void render(CanvasElement buffer) {
        if(checkFinished()) return;
        buffer.context2D.font = "bold ${fontSize}px $font";
        buffer.context2D.fillStyle = color1.toStyleString();
        String canvasText = text.replaceAll("<br>", "\n");
        int borderSize = 1;
        Renderer.wrap_text(buffer.context2D, canvasText, x+borderSize, y+borderSize, fontSize * 2, width, "left");
        Renderer.wrap_text(buffer.context2D, canvasText, x+borderSize, y-borderSize, fontSize * 2, width, "left");
        Renderer.wrap_text(buffer.context2D, canvasText, x-borderSize, y+borderSize, fontSize * 2, width, "left");
        Renderer.wrap_text(buffer.context2D, canvasText, x-borderSize, y-borderSize, fontSize * 2, width, "left");
        buffer.context2D.fillStyle = color2.toStyleString();
        Renderer.wrap_text(buffer.context2D, canvasText, x, y, fontSize * 2, width, "left");
    }
}

class NidhoggText extends OnScreenText{
    String font = "Strife";
    int fontSize = 32;
    NidhoggText(String text) : super(text,50, 1000, new Colour.fromStyleString("#85afff"), new Colour.fromStyleString("#291d53"));

    @override
    void render(CanvasElement buffer) {
        if(checkFinished()) return;
        buffer.context2D.font = "bold ${fontSize}px $font";
        buffer.context2D.fillStyle = color1.toStyleString();
        String canvasText = text.replaceAll("<br>", "\n");
        Random rand = new Random();
        int borderSize = rand.nextInt(fontSize) ;
        Renderer.wrap_text(buffer.context2D, canvasText, x+borderSize, y+borderSize, fontSize * 2, width, "left");
        borderSize = rand.nextInt(fontSize) ;
        Renderer.wrap_text(buffer.context2D, canvasText, x+borderSize, y-borderSize, fontSize * 2, width, "left");
        borderSize = rand.nextInt(fontSize) ;
        Renderer.wrap_text(buffer.context2D, canvasText, x-borderSize, y+borderSize, fontSize * 2, width, "left");
        borderSize = rand.nextInt(fontSize) ;
        Renderer.wrap_text(buffer.context2D, canvasText, x-borderSize, y-borderSize, fontSize * 2, width, "left");
        buffer.context2D.fillStyle = color2.toStyleString();
        Renderer.wrap_text(buffer.context2D, canvasText, x, y, fontSize * 2, width, "left");
    }

}

class NidhoggPride extends NidhoggText {
  NidhoggPride(String text) : super(text);

  @override
  void render(CanvasElement buffer) {
      if(checkFinished()) return;
      buffer.context2D.font = "bold ${fontSize}px $font";
      buffer.context2D.fillStyle = color1.toStyleString();
      String canvasText = text.replaceAll("<br>", "\n");
      int borderSize = 1;
      //stable text, not overflowing with life
      Renderer.wrap_text(buffer.context2D, canvasText, x+borderSize, y+borderSize, fontSize * 2, width, "left");
      Renderer.wrap_text(buffer.context2D, canvasText, x+borderSize, y-borderSize, fontSize * 2, width, "left");
      Renderer.wrap_text(buffer.context2D, canvasText, x-borderSize, y+borderSize, fontSize * 2, width, "left");
      Renderer.wrap_text(buffer.context2D, canvasText, x-borderSize, y-borderSize, fontSize * 2, width, "left");
      buffer.context2D.fillStyle = color2.toStyleString();
      Renderer.wrap_text(buffer.context2D, canvasText, x, y, fontSize * 2, width, "left");
  }
}

class NidhoggPain extends NidhoggText {
  NidhoggPain(String text) : super(text);

  @override
  void render(CanvasElement buffer) {
      if(checkFinished()) return;
      buffer.context2D.font = "bold ${fontSize}px $font";
      buffer.context2D.fillStyle = color1.toStyleString();
      String canvasText = text.replaceAll("<br>", "\n");
      Random rand = new Random();
      //text is more scattered because pain
      int borderSize = rand.nextInt(fontSize*3) ;
      Renderer.wrap_text(buffer.context2D, canvasText, x+borderSize, y+borderSize, fontSize * 2, width, "left");
      borderSize = rand.nextInt(fontSize) ;
      Renderer.wrap_text(buffer.context2D, canvasText, x+borderSize, y-borderSize, fontSize * 2, width, "left");
      borderSize = rand.nextInt(fontSize) ;
      Renderer.wrap_text(buffer.context2D, canvasText, x-borderSize, y+borderSize, fontSize * 2, width, "left");
      borderSize = rand.nextInt(fontSize) ;
      Renderer.wrap_text(buffer.context2D, canvasText, x-borderSize, y-borderSize, fontSize * 2, width, "left");
      buffer.context2D.fillStyle = color2.toStyleString();
      //even the left text is disrupted from pain
      borderSize = rand.nextInt(fontSize) ;
      Renderer.wrap_text(buffer.context2D, canvasText, x+ borderSize, y+ borderSize, fontSize * 2, width, "left");
  }

}

class HPNotification extends OnScreenText{
    HPNotification(String text) : super(text, 150, 1100, new Colour.fromStyleString("#ff0000"), new Colour.fromStyleString("#4c0000"), millisOnScreen: 3000) {
        scatterAroundCentralPoint();
    }

    void scatterAroundCentralPoint() {
        Random rand = new Random();
        int amountX = rand.nextInt(100);
        if(rand.nextBool()) {
            x += amountX;
        }else {
            x += amountX * -1;
        }
        int amountY = rand.nextInt(fontSize);
        if(rand.nextBool()) {
            y += amountY;
        }else {
            y += amountY * -1;
        }
    }


}