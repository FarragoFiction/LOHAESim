import 'Inventoryable.dart';
import 'dart:html';

class Store {
    DivElement container;

    List<Inventoryable> inventory;

    Store(Element parent, List<Inventoryable> this.inventory) {
        container = new DivElement();
        container.classes.add("store");
        parent.append(container);
    }


    void render() {
        TableElement table = new TableElement();
        container.append(table);
        for(Inventoryable inventoryItem in inventory) {
            inventoryItem.renderInventoryRow(table);
        }
    }


}