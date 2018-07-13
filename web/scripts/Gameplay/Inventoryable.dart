import 'Store.dart';
import 'dart:html';

abstract class Inventoryable {
    String name = "???";
    String description = "An item???";
    int cost = 113;
    Store store; //will be set when there's a store
    //up to whoever uses me to make this a thing
    CanvasElement itemCanvas = new CanvasElement(width: 50, height: 50);

    void renderInventoryRow(DivElement parent) {
        DivElement me = new DivElement();
        me.classes.add("innerStoreTableRow");
        parent.append(me);

        print("going to append item canvas for $name");
        me.append(itemCanvas);
        itemCanvas.classes.add("imageCell");

        DivElement costCell = new DivElement()..text = "\$$cost";
        costCell.classes.add("costCell");
        me.append(costCell);

        me.onClick.listen((Event e) {
            store.handleItemClick(this);
        });
    }
}