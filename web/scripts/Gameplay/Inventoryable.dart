import 'dart:html';

abstract class Inventoryable {
    String description = "An item???";
    int cost = 113;
    //up to whoever uses me to make this a thing
    CanvasElement itemCanvas = new CanvasElement(width: 50, height: 50);



    void renderInventoryRow(TableElement parent) {
        TableRowElement me = new TableRowElement();
        me.classes.add("innerStoreTableRow");
        parent.append(me);

        TableCellElement imageCell = new TableCellElement();
        me.append(imageCell);
        itemCanvas.classes.add("inventoryItem");
        imageCell.append(itemCanvas);

        TableCellElement costCell = new TableCellElement()..text = "$cost";
        me.append(costCell);

    }
}