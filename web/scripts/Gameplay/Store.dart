import 'Inventoryable/Ax.dart';
import 'Inventoryable/Essence.dart';
import 'Inventoryable/Flashlight.dart';
import 'Inventoryable/Fruit.dart';
import 'Inventory.dart';
import 'Inventoryable/HelpingHand.dart';
import 'Inventoryable/Inventoryable.dart';
import 'Inventoryable/Record.dart';
import 'Inventoryable/YellowYard.dart';
import 'World.dart';
import 'dart:async';
import 'dart:html';

import 'package:DollLibCorrect/src/Dolls/KidBased/HomestuckGrubDoll.dart';
import 'package:DollLibCorrect/src/Dolls/PlantBased/FruitDoll.dart';
import 'package:RenderingLib/RendereringLib.dart';

class Store extends Inventory {

    List<String> axQuips = <String>["This fell of the back of a truck. No, it doesn't look familiar. No, it's not pre-owened. No, it doesn't belong to an angry semi-omnipotent robot god and I'm just trying to offload it to get him off my back why would you think that that would be dumb oh god you're not him in disguise are you i've heard he wears flesh suits sometimes shit if you're him you gotta tell me"];
    List<String> fruitQuips = <String>["Yeah yeah whatever. Hey, have you seen any eyes yet?","Enjoy your juicy treat.", "One out of every ten fruits I sell is actually a vegetable.", "Uh. You sure you want that one?", "Well, ok. Not like I'm in a position to judge your food habits.", "Disclaimer: I am not responsible for disease, mutilation, or death that may cause from misuse of the fruit.", "I mean, if you're sure?"];
    List<String> flashlightQuips = <String>["Why in f*** would you need a cashlight for gardening."];
    List<String> plusUltra = <String>["Go Beyond!"];

    List<String> cancelQuips = <String>["Don't waste my time you jackass.","Oh come the f*** on."];
    List<String> recordQuips = <String>["I hope you enjoy!", "I really hope you like it.", "I spent a lot of time on this one, hope you like it!", "Thanks for nabbing my music"];
    List<String> sellfruitQuips = <String>["You drive a hard bargin.", "Really? You want how much?", "This smells like shit.", "My grandmas a better gardener then this.", "Damn it, I was hoping for apples.", "Well, time to re-sell these at ten times the price.", "You ever wonder why we seem to be using troll money when we're both secretly human?", "Congrats, you just collapsed the local fruit economy.", "Pleasure doing business with you, now my non-existent children won't starve.", "-The bard messily devours the fruit-", "-The bard eyes the fruit with distrust and hands you a few ceagers-"];
    List<String> sellRecordQuips = <String>["Oh. Ok. I-. Alright.", "Oh. I'm sorry you didn't like it.", "Oh. I kinda liked that one...", "Yeah, it is kinda shit, I'm sorry.", "I see. Alright. I'm sorry to have wasted your time.", "ok. sorry to have bothered you."];
    List<String> sellWigglerQuips = <String>["You drive a hard bargin.", "Really? You want how much?", "This smells like shit.", "My grandmas a better gardener then this.", "Damn it, I was hoping for apples.", "Well, time to re-sell these at ten times the price.", "You ever wonder why we seem to be using troll money when we're both secretly human?", "Congrats, you just collapsed the local fruit economy.", "Pleasure doing business with you, now my non-existent children won't starve.", "-The bard messily devours the fruit, and then looks you dead in the eyes- ...What. Just because its *shaped* like an alien baby doesn't mean it *is* an alien baby", "-The bard eyes the fruit with distrust and hands you a few ceagers-"];

    List<String> cantAffordToBuyQuips = <String>["Don't touch if you can't buy!", "Get out of my shop you broke motherf*****.", "Oh come on, seriously?", "This isn't a charity.", "I only give discounts to people with good taste", "Better luck next time bozo!", "No cash, no goodies"];

    List<Inventoryable> saleItems;
    Element buyTable;
    Element sellTable;
    bool buying = true;
  Store(World world, List<Inventoryable> inventory, List<Inventoryable> this.saleItems) : super(world, inventory);

  @override
  Element makeRightElement() {
      rightElement = new ImageElement(src: "images/BGs/miStorePianoGlitch.png");

  }

  void buyMode() {
      buying = true;
      buyTable.style.display = "block";
      sellTable.style.display = "none";
  }

  void sellMode() {
      buying = false;
      buyTable.style.display = "none";
      sellTable.style.display = "block";
  }

    Future<Null> renderTabs(Element outerTable) async {
        DivElement buyButton = new DivElement()..text = "Buy Items"..classes.add("tab")..classes.add("selectedTab");

        DivElement sellButton = new DivElement()..text = "Sell Items"..classes.add("tab");

        buyButton.onClick.listen((Event e) {
            sellButton.classes.remove("selectedTab");
            buyButton.classes.add("selectedTab");
            buyMode();
        });

        sellButton.onClick.listen((Event e) {
            buyButton.classes.remove("selectedTab");
            sellButton.classes.add("selectedTab");
            sellMode();
        });


        TableRowElement tabs = new TableRowElement();

        tabs.append(buyButton);
        tabs.append(sellButton);
        outerTable.append(tabs);
    }

    void makeSellAllButton() {
        DivElement sellAllButton = new DivElement()..text = "Sell All Fruit"..classes.add("meteorButton")..classes.add("storeButtonColor");

        sellAllButton.onClick.listen((Event e) {
            sellAllFruit();
        });
        container.append(sellAllButton);
    }

    void sellAllFruit() {
        //print("found ${allItemsOfType.length} copies of this item");
        List<Inventoryable> copyList = new List.from(world.underWorld.player.inventory);
        for(Inventoryable item in copyList) {
            if(item is Fruit) {
                Fruit fruit = item as Fruit;
                if(fruit.doll is FruitDoll) {
                    world.updateFunds(item.saleCost,true);
                    inventory.add(item);
                    world.underWorld.player.inventory.remove(item,true);
                }
            }
        }
        world.save("done selling all");
        world.playSoundEffect("121990__tomf__coinbag");
    }


    Future<Null> renderSellItems(Element td1) async {
        sellTable = new DivElement();
        sellTable.style.display = "none";
        sellTable.classes.add("innerStoreRowContainer");
        td1.append(sellTable);
        for(Inventoryable inventoryItem in saleItems) {
            //so they know how to popup
            await setCanvasForItem(inventoryItem);
            inventoryItem.inventory = this;
            inventoryItem.renderStoreInventoryRow(sellTable, true);
        }

    }

    Future<Null> renderBuyItems(Element td1) async {
        buyTable = new DivElement();
        buyTable.classes.add("innerStoreRowContainer");
        td1.append(buyTable);
        for(Inventoryable inventoryItem in inventory) {
            //so they know how to popup
            await setCanvasForItem(inventoryItem);
            inventoryItem.inventory = this;
            inventoryItem.renderStoreInventoryRow(buyTable,false);
        }
    }


    @override
    Future<Null> render() async{
      TableElement outerTable = new TableElement();
        container.append(outerTable);
        outerTable.classes.add("outerStoreTable");
        await renderTabs(outerTable);

      TableRowElement row = new TableRowElement();
        outerTable.append(row);
        TableCellElement td1 = new TableCellElement();
        row.append(td1);
        renderBuyItems(td1);
        renderSellItems(td1);


        if(rightElement == null) makeRightElement();
        rightElement.onClick.listen((Event e) {
            if(popup.visible()) {
                popup.cycle();
            }
        });
        TableCellElement td2 = new TableCellElement();
        td2.append(rightElement);
        row.append(td2);

        popup = new StorePopup(container, this);
      makeSellAllButton();


    }



}


class StorePopup extends InventoryPopup
{
    Store store;

    StorePopup(Element parent, Store this.store) : super(parent) {
        container = new DivElement();
        container.onClick.listen((Event e) {
            if(visible()) {
                cycle();
            }
        });
        container.classes.add("storePopup");
        container.style.display = "none";

        header = new DivElement()..text = "Placeholder Header";
        header.classes.add("popupHeader");
        container.append(header);

        textBody= new DivElement();
        container.append(textBody);
        textBody.classes.add("popupBody");
        textBody.setInnerHtml("Lorem Ipsum Dolor definitely not a typo okay?<br><br>More Lorem shit I promise okay???");

        parent.append(container);

    }

    void commerce() {
        if(store.buying) {
            buyCommerce();
        }else {
            sellCommerce();
        }
    }

    void commerceAll([bool butOne=false]) {
        if(itemIsEye()){
            textBody.text = "...I mean, I'll buy your ocular abominations against the gods, but I won't be happy about it";
        }else if(itemIsCod()){
            textBody.text = "My children.";
        }else if(itemIsHorseNut()) {
            textBody.text = "Please dont ask why I want this";
        }else if (store.activeItem is Fruit) {
            if((store.activeItem as Fruit).doll is HomestuckGrubDoll) {
                textBody.text = rand.pickFrom(store.sellWigglerQuips);
            }else {
                textBody.text = rand.pickFrom(store.sellfruitQuips);
            }
        } else if (store.activeItem is Record) {
            textBody.text = rand.pickFrom(store.sellRecordQuips);
        }else {
            textBody.text = "???";
        }
        sellAll(store.activeItem, butOne);
    }

    bool itemIsCod() {
        if(store.activeItem is Fruit) {
            Fruit fruit = store.activeItem as Fruit;
            if(fruit.doll is FruitDoll) {
                FruitDoll fruitDoll = (fruit.doll as FruitDoll);

                return fruitDoll.body.imgNumber == 26;
            }
        }
        return false;
    }

    bool itemIsEye() {
        if(store.activeItem is Fruit) {
            Fruit fruit = store.activeItem as Fruit;
            if(fruit.doll is FruitDoll) {
                FruitDoll fruitDoll = (fruit.doll as FruitDoll);

                return fruitDoll.body.imgNumber == 24;
            }
        }
        return false;
    }

    bool itemIsHorseNut() {
        return store.activeItem.name == "Horse Nut";
    }

    void buyCommerce() {
      if(!store.activeItem.canAfford) {
          textBody.text = rand.pickFrom(store.cantAffordToBuyQuips);
      }else {
          if(itemIsCod()){
              textBody.text = "Treasure them.";
          }else if(itemIsHorseNut()) {
              textBody.text = "I'm so, so sorry";
          }else if (store.activeItem is Ax) {
              textBody.text = rand.pickFrom(store.axQuips);
          } else if (store.activeItem is Fruit) {
              textBody.text = rand.pickFrom(store.fruitQuips);
          } else if (store.activeItem is Flashlight) {
              textBody.text = rand.pickFrom(store.flashlightQuips);
          } else if (store.activeItem is HelpingHandPlusUltra) {
              textBody.text = rand.pickFrom(store.plusUltra);
          } else if (store.activeItem is Record) {
              textBody.text = rand.pickFrom(store.recordQuips);
          }else {
              textBody.text = "???";
          }
          buy(store.activeItem);
      }
    }

    void sellCommerce() {
        if(itemIsEye()){
            textBody.text = "...I mean, I'll buy your ocular abominations against the gods, but I won't be happy about it";
        }else if(itemIsCod()){
            textBody.text = "My children.";
        }else if(itemIsHorseNut()) {
            textBody.text = "Please dont ask why I want this";
        }else if (store.activeItem is Fruit) {
            if((store.activeItem as Fruit).doll is HomestuckGrubDoll) {
                textBody.text = rand.pickFrom(store.sellWigglerQuips);
            }else {
                textBody.text = rand.pickFrom(store.sellfruitQuips);
            }
        } else if (store.activeItem is Record) {
            textBody.text = rand.pickFrom(store.sellRecordQuips);
        }else {
            textBody.text = "???";
        }
        sell(store.activeItem);
    }

    //https://freesound.org/people/tomf_/sounds/121990/
    void sell(Inventoryable item) {
        store.world.updateFunds(item.saleCost);
        store.inventory.add(item);
        store.world.underWorld.player.inventory.remove(item);
        if(item is Fruit) {
            Fruit fruit = item as Fruit;
            if(fruit.doll is HomestuckGrubDoll) {
                store.world.secretsForCalm.remove(fruit.doll.toDataBytesX());
            }
        }
        store.world.playSoundEffect("121990__tomf__coinbag");
    }

    List<Inventoryable> allItemsThatMatch(Inventoryable itemToMatch) {
        List<Inventoryable> ret = new List<Inventoryable>();
        for(Inventoryable item in store.saleItems) {
            if(item.matches(itemToMatch)){
                ret.add(item); //yes even yourself.
            }
        }
        return ret;
    }

    void sellAll(Inventoryable itemTemplate, bool butOne) {
        List<Inventoryable> allItemsOfType = allItemsThatMatch(itemTemplate);
        if(butOne) {
            allItemsOfType.remove(allItemsOfType.first);
        }
        //print("found ${allItemsOfType.length} copies of this item");
        for(Inventoryable item in allItemsOfType) {
            store.world.updateFunds(item.saleCost);
            store.inventory.add(item);
            store.world.underWorld.player.inventory.remove(item);
        }
        store.world.playSoundEffect("121990__tomf__coinbag");
    }

    void buy(Inventoryable item) {
        store.world.updateFunds(-1*item.cost);
        store.inventory.remove(item);
        item.myInventoryDiv.remove();
        store.world.underWorld.player.inventory.add(item);
        store.world.playSoundEffect("121990__tomf__coinbag");
    }

    Random get rand {
        //same fruit always gets the same responses from manic
        if(store.activeItem is Fruit) {
            return new Random((store.activeItem as Fruit).doll.seed);
        }
        return new Random();
    }

    void failedCommerce() {

        textBody.text = rand.pickFrom(store.cancelQuips);
        step = -13;
    }


    @override
    Future<Null> popup(Inventoryable chosenItem, {Point point, Element preview}) async {
        step = 0;

        container.style.display = "block";
        int realCost = chosenItem.cost;
        if(!store.buying) realCost = chosenItem.saleCost;
        header.text = "${chosenItem.name.toUpperCase()} - \$${realCost}";
        if(chosenItem is Fruit) {
            header.text = "${header.text} (Seed ID: ${(chosenItem as Fruit).doll.seed})";
        }
        if(preview != null) {
            CanvasElement previewBox = new CanvasElement(width: 15, height: 15);
            previewBox.style.display = "inline";
            await Renderer.drawToFitCentered(previewBox, preview);
            header.append(previewBox);
        }
        textBody.setInnerHtml("${chosenItem.description}");
        if(parentScroll != null) {
            parentScroll.remove();
            parentScroll = null;
        }
        if(chosenItem is Fruit) {
            if(parentScroll != null) parentScroll.remove();
            parentScroll = await chosenItem.generateHorizontalScrollOfParents();
            parentScroll.style.display = "none";
            parentScroll.classes.add("popupParents");

            container.append(parentScroll);
        }
        cycle();
    }

    void handlePurchasePopup() {
        textBody.style.display = "block";
        textBody.setInnerHtml("");
        if(parentScroll != null) {
            parentScroll.remove();
            parentScroll = null;
        }
        String word = "SELL";
        if(store.buying) word = "BUY";
        header.text = "$word ${header.text.replaceAll(": Parents","")}?";

        DivElement yesButton = new DivElement()..text = "YES"..classes.add("storeButton")..classes.add("storeButtonColor");
        DivElement yesAll = new DivElement()..text = "ALL"..classes.add("storeButton")..classes.add("storeButtonColor");;

        DivElement noButton = new DivElement()..text = "NO"..classes.add("storeButton")..classes.add("storeButtonColor");;
        DivElement allButOne = new DivElement()..text = "Sell All But Leave One"..classes.add("storeButtonJoke")..classes.add("storeButtonColor");;

        yesButton.onClick.listen((Event e) {
            e.stopPropagation(); //don't give it to other things
            commerce();
        });

        yesAll.onClick.listen((Event e) {
            e.stopPropagation(); //don't give it to other things
            commerceAll();
        });

        allButOne.onClick.listen((Event e) {
            e.stopPropagation(); //don't give it to other things
            commerceAll(true);
        });

        noButton.onClick.listen((Event e) {
            e.stopPropagation(); //don't give it to other things
            failedCommerce();
        });
        textBody.append(yesButton);
        if(!store.buying) {
            yesButton.style.margin = "5px";
            yesAll.style.margin = "5px";
            noButton.style.margin = "5px";
            textBody.append(yesAll);
        }

        textBody.append(noButton);

        if(!store.buying) {
            textBody.append(allButOne);
        }
    }

    @override
    void cycle() {
        //print("cycling, step is $step");
        if(step == 0) {
            textBody.style.display = "block";
            if(parentScroll != null) parentScroll.style.display = "none";
        }else if(step == 1 && parentScroll != null){
            textBody.style.display = "none";
            parentScroll.style.display = "block";
            header.text = "${header.text}: Parents";
        }else if(step == 2 || (step == 1 && parentScroll == null)){
            handlePurchasePopup();
        }else {
            if(parentScroll != null) {
                parentScroll.remove();
                parentScroll = null;
            }
            dismiss();
        }
        step ++;
    }

}