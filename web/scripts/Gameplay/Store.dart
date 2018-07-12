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
            inventoryItem.renderInventoryRow(table);
        }

        ImageElement manicInsomniac = new ImageElement(src: "images/BGs/miStore.png");
        TableCellElement td2 = new TableCellElement();
        td2.append(manicInsomniac);
        row.append(td2);
    }


}