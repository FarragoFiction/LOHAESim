import 'Essence.dart';
import 'Fruit.dart';
import 'Inventory.dart';
import 'Inventoryable.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:html';

import 'package:RenderingLib/RendereringLib.dart';
class Inventory extends Object with IterableMixin<Inventoryable>{
    DivElement container;
    InventoryPopup popup;
    Element rightElement;
    //if it's active this is the thing we'll buy if it's a store
    //otherwise it's rendered as your mouse pointer in the canvas.
    Inventoryable activeItem;

    List<Inventoryable> inventory;

    Inventory(List<Inventoryable> this.inventory) {

    }

    void makeRightElement() {
        if(rightElement == null) {
            rightElement = new DivElement();
            rightElement.classes.add("worldContainer");
        }
    }

    void createContainer(Element parent) {
        container = new DivElement();
        container.classes.add("store");
        parent.append(container);
    }

    void add(Inventoryable item) {
        inventory.add(item);
    }

    void remove(Inventoryable item) {
        inventory.remove(item);
    }

    void handleItemClick(Inventoryable item, {Element preview}) {
        activeItem = item;
        popup.popup(item,  preview:preview);
    }

    Future<Null> render() async{
        TableElement outerTable = new TableElement();
        container.append(outerTable);
        //outerTable.classes.add("outerStoreTable");

        TableRowElement row = new TableRowElement();
        outerTable.append(row);
        TableCellElement td1 = new TableCellElement();
        row.append(td1);

        DivElement table = new DivElement();
        table.classes.add("innerInventoryRowContainer");
        td1.append(table);
        for(Inventoryable inventoryItem in inventory) {
            //so they know how to popup
            if(inventoryItem is Essence) {
                await inventoryItem.setCanvasForStore();
            }else if(inventoryItem is Fruit) {
                await inventoryItem.setCanvasForStore();
            }
            inventoryItem.store = this;
            inventoryItem.renderMyInventoryRow(table);
        }

        if(rightElement == null) makeRightElement();
        rightElement.onClick.listen((Event e) {
            if(popup.visible()) {
                popup.cycle();
            }
        });
        TableCellElement td2 = new TableCellElement();
        td2.append(rightElement);
        td2.style.verticalAlign = "top";
        row.append(td2);

        popup = new InventoryPopup(container);

    }


  @override
  Iterator<Inventoryable> get iterator => inventory.iterator;
}

class InventoryPopup {
    DivElement container;
    DivElement header;
    DivElement textBody;
    DivElement parentScroll;

    int step = 0;
    InventoryPopup(Element parent) {
        container = new DivElement();
        container.onClick.listen((Event e) {
            if(visible()) {
                cycle();
            }
        });
        container.classes.add("inventoryPopup");
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

    bool visible() {
        return container.style.display == "block";
    }

    Future<Null> popup(Inventoryable chosenItem, {CanvasElement preview}) async {
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

    void dismiss() {
        container.style.display = "none";
        step = 0;
    }

    void cycle() {
        print("cycling, step is $step");
        if(step == 0) {
            textBody.style.display = "block";
            parentScroll.style.display = "none";
        }else if(step == 1){
            textBody.style.display = "none";
            parentScroll.style.display = "block";
            header.text = "${header.text}: Parents";
        }else {
            parentScroll.remove();
            dismiss();
        }
        step ++;
    }
}
