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

import 'package:RenderingLib/RendereringLib.dart';

class Store extends Inventory {

    List<String> axQuips = <String>["[INSERT QUIP ABOUT FELL OFF A TRUCK HERE]"];
    List<String> fruitQuips = <String>["[GENERIC QUIPS ABOUT FRUIT BUYING]", "[EVEN MORE GENERIC QUIPS ABOUT BUYING FRUIT]"];
    List<String> flashlightQuips = <String>["[FLASHLIGHT QUIP GOES HERE]"];
    List<String> cancelQuips = <String>["[INSERT SARCASTIC QUIPS ABOUT CANCELING HERE]","[SARCASTIC CANCEL GOES HERE]"];
    List<String> recordQuips = <String>["[GENERIC QUIPS ABOUT RECORD BUYING]", "[EVEN MORE GENERIC QUIPS ABOUT BUYING RECORDS]"];
    List<String> sellfruitQuips = <String>["[GENERIC QUIPS ABOUT FRUIT SELLING]", "[EVEN MORE GENERIC QUIPS ABOUT SELLING FRUIT]"];
    List<String> sellRecordQuips = <String>["[GENERIC QUIPS ABOUT RECORD SELLING]", "[EVEN MORE GENERIC QUIPS ABOUT SELLING RECORDS]"];

    List<String> cantAffordToBuyQuips = <String>["[GENERIC QUIPS ABOUT YOU BEING BROKE]", "[EVEN MORE GENERIC QUIPS ABOUT YOU BEING BROKE]"];

    List<Inventoryable> saleItems;
    Element buyTable;
    Element sellTable;
    bool buying = true;
  Store(World world, List<Inventoryable> inventory, List<Inventoryable> this.saleItems) : super(world, inventory);

  @override
  Element makeRightElement() {
      rightElement = new ImageElement(src: "images/BGs/miStorePiano.png");

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

    void buyCommerce() {
      if(store.activeItem.canAfford) {
          textBody.text = rand.pickFrom(store.cantAffordToBuyQuips);
      }else {
          if (store.activeItem is Ax) {
              textBody.text = rand.pickFrom(store.axQuips);
          } else if (store.activeItem is Fruit) {
              textBody.text = rand.pickFrom(store.fruitQuips);
          } else if (store.activeItem is Flashlight) {
              textBody.text = rand.pickFrom(store.flashlightQuips);
          } else if (store.activeItem is Record) {
              textBody.text = rand.pickFrom(store.recordQuips);
          }else {
              textBody.text = "???";
          }
          buy(store.activeItem);
      }
    }

    void sellCommerce() {
        if (store.activeItem is Fruit) {
            textBody.text = rand.pickFrom(store.sellfruitQuips);
        } else if (store.activeItem is Record) {
            textBody.text = rand.pickFrom(store.sellRecordQuips);
        }else {
            textBody.text = "???";
        }
        sell(store.activeItem);
    }

    void sell(Inventoryable item) {
        store.world.updateFunds(item.saleCost);
        store.inventory.add(item);
        store.world.underWorld.player.inventory.remove(item);
    }

    void buy(Inventoryable item) {
        store.world.updateFunds(-1*item.saleCost);
        store.inventory.remove(item);
        store.world.underWorld.player.inventory.add(item);
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
    }


    @override
    Future<Null> popup(Inventoryable chosenItem, {Point point, Element preview}) async {
        step = 0;

        container.style.display = "block";
        header.text = "${chosenItem.name.toUpperCase()} - \$${chosenItem.cost}";
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

        DivElement yesButton = new DivElement()..text = "YES"..classes.add("storeButton");
        DivElement noButton = new DivElement()..text = "NO"..classes.add("storeButton");

        yesButton.onClick.listen((Event e) {
            e.stopPropagation(); //don't give it to other things
            commerce();
        });

        noButton.onClick.listen((Event e) {
            e.stopPropagation(); //don't give it to other things
            failedCommerce();
        });
        textBody.append(yesButton);
        textBody.append(noButton);
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
        }else if(step == 2 || step == 1 && parentScroll == null){
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