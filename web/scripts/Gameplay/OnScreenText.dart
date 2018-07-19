import 'World.dart';
import 'dart:html';
import 'package:RenderingLib/RendereringLib.dart';

class OnScreenText {
    String text;
    int fontSize = 48;
    Colour color1;
    Colour color2;
    int x;
    int y;
    int millisOnScreen;
    DateTime firstRender;
    bool finished = false;

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
        buffer.context2D.font = "bold ${fontSize}px Courier New";
        buffer.context2D.fillStyle = color1.toStyleString();
        String canvasText = text.replaceAll("<br>", "\n");
        int borderSize = 1;
        Renderer.wrap_text(buffer.context2D, canvasText, x+borderSize, y+borderSize, 300, 650, "center");
        Renderer.wrap_text(buffer.context2D, canvasText, x+borderSize, y-borderSize, 300, 650, "center");
        Renderer.wrap_text(buffer.context2D, canvasText, x-borderSize, y+borderSize, 300, 650, "center");
        Renderer.wrap_text(buffer.context2D, canvasText, x-borderSize, y-borderSize, 300, 650, "center");
        buffer.context2D.fillStyle = color2.toStyleString();
        Renderer.wrap_text(buffer.context2D, canvasText, x, y, 300, 650, "center");
    }
}

class NidhoggText extends OnScreenText{
  NidhoggText(String text) : super(text,-100, 1000, new Colour.fromStyleString("#85afff"), new Colour.fromStyleString("#291d53"));

}

class HPNotification extends OnScreenText{
    HPNotification(String text) : super(text, -100, 1100, new Colour.fromStyleString("#ff0000"), new Colour.fromStyleString("#4c0000")) {
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