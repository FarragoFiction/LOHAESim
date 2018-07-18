import 'dart:html';
import 'package:RenderingLib/RendereringLib.dart';

class OnScreenText {
    String text;
    String font = "Strife";
    int fontSize = 72;
    Colour color1;
    Colour color2;
    int x;
    int y;
    int millisOnScreen;
    int fadeTimeInMillis;

    OnScreenText(String this.text, int this.x, int this.y, Colour this.color1, Colour this.color2, {int this.millisOnScreen: 1000, int this.fadeTimeInMillis:1000});

    void render(CanvasElement buffer) {
        buffer.context2D.font = "bold ${fontSize}px Courier New";
        buffer.context2D.fillStyle = color1.toStyleString();
        String canvasText = text.replaceAll("<br>", "\n");
        int borderSize = 1;
        Renderer.wrap_text(buffer.context2D, canvasText, 75+borderSize, 50+borderSize, 48, 650, "center");
        Renderer.wrap_text(buffer.context2D, canvasText, 75+borderSize, 50-borderSize, 48, 650, "center");
        Renderer.wrap_text(buffer.context2D, canvasText, 75-borderSize, 50+borderSize, 48, 650, "center");
        Renderer.wrap_text(buffer.context2D, canvasText, 75-borderSize, 50-borderSize, 48, 650, "center");
        buffer.context2D.fillStyle = color2.toStyleString();
        Renderer.wrap_text(buffer.context2D, canvasText, 75, 50, 48, 650, "center");
    }
}

class NidhoggText extends OnScreenText{
  NidhoggText(String text) : super(text,20, 800, new Colour.fromStyleString("#85afff"), new Colour.fromStyleString("#291d53"));

}

class HPNotification extends OnScreenText{
    HPNotification(String text) : super(text, 20, 800, new Colour.fromStyleString("#ff0000"), new Colour.fromStyleString("#4c0000"));

}