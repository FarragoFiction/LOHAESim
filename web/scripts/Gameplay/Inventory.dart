import 'Essence.dart';
import 'Fruit.dart';
import 'Inventory.dart';
import 'Inventoryable.dart';
import 'dart:async';
import 'dart:html';
class Inventory {
    DivElement container;
    InventoryPopup popup;

    List<Inventoryable> inventory;

    Inventory(Element parent, List<Inventoryable> this.inventory) {
        container = new DivElement();
        container.classes.add("store");
        parent.append(container);
    }

    void handleItemClick(Inventoryable item) {
        popup.popup(item);
    }

    Future<Null> render() async{
        TableElement outerTable = new TableElement();
        container.append(outerTable);
        outerTable.classes.add("outerStoreTable");

        TableRowElement row = new TableRowElement();
        outerTable.append(row);
        TableCellElement td1 = new TableCellElement();
        row.append(td1);

        DivElement table = new DivElement();
        table.classes.add("innerStoreRowContainer");
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

        popup = new InventoryPopup(container);

    }


}

class InventoryPopup {
    DivElement container;
    DivElement header;
    DivElement textBody;
    int step = 0;
    InventoryPopup(Element parent) {
        container = new DivElement();
        container.onClick.listen((Event e) {
            if(visible()) {
                cycle();
            }
        });
        container.classes.add("popup");
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

    Future<Null> popup(Inventoryable chosenItem) async {
        step = 0;

        container.style.display = "block";
        header.text = "${chosenItem.name.toUpperCase()} - \$${chosenItem.cost}";
        textBody.setInnerHtml("${chosenItem.description}");
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
        }else{
            dismiss();
        }
        step ++;
    }
}