import 'dart:async';
import 'dart:html';

import 'package:RenderingLib/RendereringLib.dart';

class UnderWorld {

    ImageElement roots;
    CanvasElement buffer;
    CanvasElement dirt;
    int width = 800;
    int height = 800;

    Future<Null> initCanvasAndBuffer() async {
        buffer = new CanvasElement(width: width, height: height);
        roots = await Loader.getResource("images/BGs/rootsPlain.png");
    }

    Future<Null> render(CanvasElement worldBuffer) async {
        if(buffer == null) await initCanvasAndBuffer();
        //buffer.context2D.fillStyle = "#5d3726";
        //buffer.context2D.fillRect(0, 0, buffer.width, buffer.height);
        buffer.context2D.drawImage(roots,0,0);

        worldBuffer.context2D.drawImage(roots, 0, 680);

    }

}