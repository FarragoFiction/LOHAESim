import 'Inventoryable/Essence.dart';
import 'Inventoryable/HelpingHand.dart';
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
    int x = 0;
    int y = 680;
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
        scatterNidhogg();
    }

    void scatterNidhogg() {
        nidhogg.topLeftX = 0+(nidhogg.width/2).round();
        nidhogg.topLeftY = (height - nidhogg.width+nidhogg.width/2).round();;
    }

    //each essence is one level down from the last
    void scatterEssences() {
        essences = Essence.spawn(world);
        //random, but always in the same places
        Random rand = new Random(13);
        int x = 0;
        int y = 0;
        List<Essence> toRemove = new List<Essence>();
        for(Essence e in essences) {
            y += (height/essences.length).round();
            x = rand.nextIntRange(e.width, width-e.width);
            e.topLeftX = x;
            e.topLeftY = y;
            //now that i've used my rand so they are stable, remove if i already have it
            if(player.hasItemWithSameNameAs(e)) toRemove.add(e);
        }

        for(Essence e in toRemove) {
            essences.remove(e);
        }

    }

    Future<Null> initCanvasAndBuffer() async {
        buffer = new CanvasElement(width: width, height: height);
        dirt = new CanvasElement(width: width, height: height);
        roots = await Loader.getResource("images/BGs/rootsPlain.png");
        if(essences == null) scatterEssences();

        //print("I inited the buffer, roots are $roots");
    }

    void cullSecrets() {
        for(Essence e in essencesToRemove) {
            essences.remove(e);
        }
    }

    void checkCorruptUpgrade() {
        if(player.canGetUpgradedHelpingHand) {
            player.inventory.add(new HelpingHandCorrupt(world));

        }
    }

    Future<Null> render(CanvasElement worldBuffer) async {
        if(buffer == null) await initCanvasAndBuffer();
        checkCorruptUpgrade();

        //print("rendering underworld");
        //slightly brighter dirt to look like light
        //buffer.context2D.fillStyle = "#71402a";
        //#44281b
        //dirt.context2D.fillStyle = "#00ff00";
        if(player.hasActiveFlashlight) {
            buffer.context2D.save();
            CanvasGradient grd = buffer.context2D.createLinearGradient(
                buffer.height, buffer.height, buffer.height, 0);
            grd.addColorStop(0, "#341c11");
            grd.addColorStop(1, "#71402a");

            buffer.context2D.fillStyle = grd;
            buffer.context2D.fillRect(0, 0, buffer.width, buffer.height);
            buffer.context2D.restore();
            //print("before drawing roots, roots are $roots");

            buffer.context2D.drawImage(roots, 0, 0);
        }
        cullSecrets();

        if(!nidhogg.dead && player.hasActiveFlashlight) nidhogg.render(buffer);
        for(Essence e in essences) {
            //also handles collecting
            if(player.playerMoved) {
                e.gigglesnort(new Math.Point(player.x, player.y));
            }
            if(!e.collected) {
                if(player.hasActiveFlashlight)e.render(buffer);
            }else {
                    essencesToRemove.add(e);
            }
        }
        if(!nidhogg.dead && player.playerMoved) nidhogg.gigglesnort(new Math.Point(player.x, player.y));
        player.playerMoved = false;


        if(player.hasActiveFlashlight) {
            ImageElement playerImage = await player.image;
            buffer.context2D.drawImage(playerImage, player.x, player.y);
        }

        //tree grows more healthy closer you get to nidhogg until suddenly everything is terrible forever
        if(!world.bossFight) {
            world.health = World.MAXHEALTH -
                (World.MAXHEALTH * (height - player.y) / height).round();
        }else {
            world.health  = World.MAXHEALTH * -1;
        }
        world.showAndHideYgdrssylLayers();
        await handleDirt();

        //worldBuffer might not have cleared self if it wasn't dirty
        worldBuffer.context2D.clearRect(x,y, width, height);
        worldBuffer.context2D.drawImage(buffer, x, y);

    }

    Future<Null> handleDirt() async {
       // print("filling in dirt");
        dirt.context2D.fillStyle = "#5d3726";
        //dirt.context2D.fillStyle = "#00ff00";

        dirt.context2D.fillRect(0, 0, dirt.width, dirt.height);
        if(player.hasActiveFlashlight) {
            dirt.context2D.beginPath();
            int flashlighRadius = dirt.width * 2; //if you're in a boss fight, show everything
            if (!world.bossFight && !nidhogg.purified) {
                flashlighRadius = player.flashlightRadius;
            } else {
                if(world.bossFightJustStarted)jrPrint("oh hey don't let me interupt you there, just thought you might wanna know there's like...three paths to defeating Nidhogg. I wonder what they could be???");
                world.bossFightJustStarted = false;
                if(!nidhogg.dead) nidhogg.attemptTalk();
                //please don't kill my happy boi
                if(world.fraymotifActive && !nidhogg.dead && !nidhogg.purified)nidhogg.attemptTakeDamage();
            }
            dirt.context2D.arc(
                player.topLeftX, player.topLeftY, flashlighRadius, 0,
                2 * Math.PI);
            dirt.context2D.save();
            dirt.context2D.clip();
            Renderer.clearCanvas(dirt);
        }
        buffer.context2D.drawImage(dirt,0,0);
        dirt.context2D.restore();
    }



    }