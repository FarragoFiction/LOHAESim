import 'Essence.dart';
import 'Nidhogg.dart';
import 'Player.dart';
import 'World.dart';
import 'dart:async';
import 'dart:html';
import "dart:math" as Math;

import 'package:RenderingLib/RendereringLib.dart';

class UnderWorld {

    ImageElement roots;
    CanvasElement buffer;
    CanvasElement dirt;
    Player player;
    int width = 800;
    int height = 800;
    //TODO load this from json too
    World world;
    Nidhogg nidhogg;
    List<Essence> essences;
    List<Essence> essencesToRemove = new List<Essence>();

    UnderWorld(World this.world) {
        nidhogg = new Nidhogg(world);
        player = new Player(world, width, height);
        //TODO load essences and their location from json, if can't find, then spawn
        essences = Essence.spawn();
        scatterEssences();
        scatterNidhogg();
    }

    void scatterNidhogg() {
        nidhogg.topLeftX = 0+(nidhogg.width/2).round();
        nidhogg.topLeftY = (height - nidhogg.width+nidhogg.width/2).round();;
    }

    //each essence is one level down from the last
    void scatterEssences() {
        //random, but always in the same places
        Random rand = new Random(13);
        int x = 0;
        int y = 0;
        for(Essence e in essences) {
            y += (height/essences.length).round();
            x = rand.nextIntRange(e.width, width-e.width);
            e.topLeftX = x;
            e.topLeftY = y;
        }
    }

    Future<Null> initCanvasAndBuffer() async {
        buffer = new CanvasElement(width: width, height: height);
        dirt = new CanvasElement(width: width, height: height);
        roots = await Loader.getResource("images/BGs/rootsPlain.png");
    }

    void cullSecrets() {
        for(Essence e in essencesToRemove) {
            essences.remove(e);
        }
    }

    Future<Null> render(CanvasElement worldBuffer) async {
        if(buffer == null) await initCanvasAndBuffer();
        //print("rendering underworld");
        //slightly brighter dirt to look like light
        //buffer.context2D.fillStyle = "#71402a";
        //#44281b
        //dirt.context2D.fillStyle = "#00ff00";
        buffer.context2D.save();
        CanvasGradient grd = buffer.context2D.createLinearGradient(buffer.height, buffer.height, buffer.height, 0);
        grd.addColorStop(0, "#341c11");
        grd.addColorStop(1,"#71402a");

        buffer.context2D.fillStyle = grd;
        buffer.context2D.fillRect(0, 0, buffer.width, buffer.height);
        buffer.context2D.restore();

        buffer.context2D.drawImage(roots,0,0);
        cullSecrets();
        nidhogg.render(buffer);
        for(Essence e in essences) {
            //also handles collecting
            print(e.gigglesnort(new Math.Point(player.x, player.y)));
            if(!e.collected) {
                e.render(buffer);
            }else {
                    essencesToRemove.add(e);
            }


        }
        ImageElement playerImage = await player.image;
        buffer.context2D.drawImage(playerImage, player.x, player.y);
        //closer you get to the bottom the less health you get. can only go negative if you interact with nidhogg, though.
        world.health = (World.MAXHEALTH * (height-player.y)/height).round();
        world.showAndHideYgdrssylLayers();
        await handleDirt();

        //worldBuffer might not have cleared self if it wasn't dirty
        worldBuffer.context2D.clearRect(0,680, width, height);
        worldBuffer.context2D.drawImage(buffer, 0, 680);

    }

    Future<Null> handleDirt() async {
       // print("filling in dirt");
        dirt.context2D.fillStyle = "#5d3726";
        //dirt.context2D.fillStyle = "#00ff00";

        dirt.context2D.fillRect(0, 0, dirt.width, dirt.height);
        dirt.context2D.beginPath();
        dirt.context2D.arc(player.topLeftX,player.topLeftY,player.flashlightRadius,0,2*Math.PI);
        dirt.context2D.save();
        dirt.context2D.clip();
        Renderer.clearCanvas(dirt);
        buffer.context2D.drawImage(dirt,0,0);
        dirt.context2D.restore();
    }



    }