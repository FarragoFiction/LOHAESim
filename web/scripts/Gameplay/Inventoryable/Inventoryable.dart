import '../Inventory.dart';
import 'dart:html';

abstract class Inventoryable {
    String name = "???";
    String description = "An item???";
    Element myInventoryDiv;
    int cost = 113;
    Inventory inventory; //will be set when there's a store
    //up to whoever uses me to make this a thing
    CanvasElement itemCanvas = new CanvasElement(width: 50, height: 50);

    void renderStoreInventoryRow(DivElement parent) {
        myInventoryDiv = new DivElement();
        myInventoryDiv.classes.add("innerStoreTableRow");
        parent.append(myInventoryDiv);

        //print("going to append item canvas for $name");
        myInventoryDiv.append(itemCanvas);
        itemCanvas.classes.add("imageCell");

        DivElement costCell = new DivElement()..text = "\$$cost";
        costCell.classes.add("costCell");
        myInventoryDiv.append(costCell);

        myInventoryDiv.onClick.listen((Event e) {
            inventory.handleItemClick(this,preview:  itemCanvas);
        });
    }

    void removeFromInventoryScreen() {
        myInventoryDiv.remove();
    }

    void renderMyInventoryRow(DivElement parent) {
        myInventoryDiv = new DivElement();
        myInventoryDiv.classes.add("innerInventoryTableRow");
        parent.append(myInventoryDiv);

        //print("going to append item canvas for $name");
        myInventoryDiv.append(itemCanvas);
        itemCanvas.classes.add("imageCell");


        myInventoryDiv.onClick.listen((MouseEvent e) {
            inventory.handleItemClick(this, preview:  itemCanvas);
        });
    }
}