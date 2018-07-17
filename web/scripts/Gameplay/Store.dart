import 'Essence.dart';
import 'Fruit.dart';
import 'Inventory.dart';
import 'Inventoryable.dart';
import 'dart:async';
import 'dart:html';

class Store extends Inventory {
  Store(List<Inventoryable> inventory) : super(inventory);

  @override
  Element makeRightElement() {
      rightElement = new ImageElement(src: "images/BGs/miStorePiano.png");

  }


    @override
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
            inventoryItem.renderStoreInventoryRow(table);
        }

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

    StorePopup(Element parent) : super(parent);

    @override
    Future<Null> popup(Inventoryable chosenItem, {Point point, Element preview}) async {
        step = 0;

        container.style.display = "block";
        header.text = "${chosenItem.name.toUpperCase()} - \$${chosenItem.cost}";
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