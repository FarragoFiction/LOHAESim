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
            inventoryItem.renderStoreInventoryRow(sellTable);
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
            inventoryItem.renderStoreInventoryRow(buyTable);
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

        popup = new StorePopup(container);

    }



}


class StorePopup extends InventoryPopup
{

    StorePopup(Element parent) : super(parent) {
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
        if(chosenItem is Fruit) {
            if(parentScroll != null) parentScroll.remove();
            parentScroll = await chosenItem.generateHorizontalScrollOfParents();
            parentScroll.style.display = "none";
            parentScroll.classes.add("popupParents");

            container.append(parentScroll);
        }
        cycle();
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
        }else {
            if(parentScroll != null)parentScroll.remove();
            dismiss();
        }
        step ++;
    }

}