import 'Consort.dart';
import 'Inventoryable/Ax.dart';
import 'Inventoryable/Essence.dart';
import 'Inventoryable/Flashlight.dart';
import 'Inventoryable/Fruit.dart';
import 'Inventory.dart';
import 'Inventoryable/HelpingHand.dart';
import 'Inventoryable/Inventoryable.dart';
import 'Inventoryable/Record.dart';
import 'Inventoryable/YellowYard.dart';
import 'Store.dart';
import 'World.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:html';

import 'package:CommonLib/Utility.dart';
import 'package:DollLibCorrect/src/Dolls/KidBased/HomestuckGrubDoll.dart';
import 'package:RenderingLib/RendereringLib.dart';
class Inventory extends Object with IterableMixin<Inventoryable>{
    static String labelPattern = ":___ ";

    DivElement container;
    InventoryPopup popup;
    Element rightElement;

    //did you know LOHAE went live on 8/5? And that the discord server for Farrago
    //was created on 5/17? And that 5 * 17 is 85???
    //well now you do
    static int FRUITLIMIT = 85;


    DivElement inventoryColumn;
    //if it's active this is the thing we'll buy if it's a store
    //otherwise it's rendered as your mouse pointer in the canvas.
    Inventoryable activeItem;

    List<Inventoryable> inventory;
    World world;
    List<Inventoryable> get saleItems =>inventory.where((Inventoryable t) => t.canSell);


    Inventory(World this.world, List<Inventoryable> this.inventory) {

    }

    String toDataString() {
        try {
            String ret = toJSON().toString();
            return "Inventory$labelPattern${BASE64URL.encode(ret.codeUnits)}";
        }catch(e) {
            print(e);
            print("Error Saving Data. Are there any special characters in there? ${toJSON()} $e");
        }
    }

    int get numberEssences {
        int essenceCount = 0;
        for(Inventoryable item in inventory) {
            if (item is Essence) {
                essenceCount ++;
            }
        }
        return essenceCount;
    }

    void addIfUnique(Inventoryable itemToAdd) {
        for(Inventoryable item in inventory) {
            if(itemToAdd.name == item.name) {
                return;
            }
        }
        //can only get here if not a duplicate
        inventory.add(itemToAdd);
    }

    int get numberFruit {
        int fruitCount = 0;
        for(Inventoryable item in inventory) {
            if (item is Fruit) {
                fruitCount ++;
            }
        }
        return fruitCount;
    }

    bool get fruitOverflow {
        return numberFruit >= FRUITLIMIT;
    }

    Future setCanvasForItem(Inventoryable inventoryItem) async {
        if(inventoryItem is Essence) {
            await inventoryItem.setCanvasForStore();
        }else if(inventoryItem is Fruit) {
            await inventoryItem.setCanvasForStore();
        }else if(inventoryItem is Ax) {
            await inventoryItem.setCanvasForStore();
        }else if(inventoryItem is Flashlight) {
            await inventoryItem.setCanvasForStore();
        }else if(inventoryItem is Record) {
            await inventoryItem.setCanvasForStore();
        }else if(inventoryItem is YellowYard) {
            await inventoryItem.setCanvasForStore();
        }else if(inventoryItem is HelpingHand) {
            await inventoryItem.setCanvasForStore();
        }
    }

    JSONObject toJSON() {
        JSONObject json = new JSONObject();
        List<JSONObject> itemArray = new List<JSONObject>();
        for(Inventoryable item in inventory) {
            itemArray.add(item.toJSON());
        }
        json["inventory"] = itemArray.toString();
        return json;
    }

    void syncToSharedCalm(){
        List<Inventoryable> items = new List.from(inventory);
        for(Inventoryable item in items) {
            if(item is Fruit) {
                Fruit fruit = item as Fruit;
                if(fruit.doll is HomestuckGrubDoll) {
                    String data = fruit.doll.toDataBytesX();
                    if(!world.secretsForCalm.contains(data)) {
                        //if you got removed from shared, you're removed here too.
                        inventory.remove(item);
                    }
                }
            }
        }
    }

    void copyFromJSON(JSONObject json) {
        String idontevenKnow = json["inventory"];
        loadInventoryFromJSON(idontevenKnow);
    }

    void loadInventoryFromJSON(String idontevenKnow) {
        //print("loading inventory from $idontevenKnow");
        inventory.clear(); //i'm loading it so ignore whatever is already here
        if(idontevenKnow == null) return;
        List<dynamic> what = JSON.decode(idontevenKnow);
        //print("what json is $what");
        for(dynamic d in what) {
            //print("dynamic json thing is  $d");
            JSONObject j = new JSONObject();
            j.json = d;
            //shit, okay i need to know what kind of object it is
            Inventoryable item = Inventoryable.loadItemFromJSON(j);
            if(item is Fruit) item.world = world;
            //print("adding $item to inventory from json");
            inventory.add(item);
        }
        //do it all at once so it happens in same order

        inventory.sort((Inventoryable a, Inventoryable b) {
            return a.sortPriority.compareTo(b.sortPriority);
        });
    }



    void removeItem(Inventoryable item) {
        if(activeItem == item) activeItem = null;
        inventory.remove(item);
        item.removeFromInventoryScreen();
    }

    //always pick the highest tier you can
    void helpingHand() {
        for(Inventoryable item in inventory) {
            if(item is HelpingHand) {
                if(activeItem is HelpingHand && item.tier > (activeItem as HelpingHand).tier) {
                    activeItem = item;
                }else if (!(activeItem is HelpingHand)) {
                    activeItem = item;
                }
            }
        }
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

    void add(Inventoryable item)  {
        inventory.add(item);
        if(item is Fruit && !(this is Store)) {
            Fruit fruit = item as Fruit;
            fruit.world = world;
            fruit.makeArchive();
            //wait what, why would this ever happen???
            if(fruit.doll is HomestuckGrubDoll) {
                world.secretsForCalm.add(fruit.doll.toDataBytesX());
            }

        }

        drawOneItem(item);
        world.save("added item to inventory");
    }

    void addAll(List<Inventoryable> items) {
        //don't just call add all, make sure the extra shit happens.
        for(Inventoryable item in items) {
             add(item);
        }
    }

    void remove(Inventoryable item, [bool waitToSave = false]) {
        inventory.remove(item);
        if(item.myInventoryDiv != null) item.myInventoryDiv.remove();
        if(item is Fruit && !(this is Store)) {
            Fruit fruit = item as Fruit;
            //wait what, why would this ever happen???
            if(fruit.doll is HomestuckGrubDoll) {
                world.secretsForCalm.remove(fruit.doll.toDataBytesX());
            }
        }
        if(!waitToSave) world.save("removed item from inventory");
    }

    void handleItemClick(Inventoryable item, {Element preview}) {
        if(activeItem != null) activeItem.unSelect();
        item.select();
        activeItem = item;
        popup.popup(item,  preview:preview);
        world.cursor = new CustomCursor(activeItem.itemCanvas, new Point(100,100));
        if(item is HelpingHand) world.cursor.mode = CustomCursor.BOTTOMRIGHT;
        //stores don't need to worry about rendering the playing field
        if(!(this is Store))world.render(true);
    }

    void handleItemSelect(Inventoryable item, {Element preview}) {
        if(activeItem != null) activeItem.unSelect();
        item.select();
        activeItem = item;
        world.cursor = new CustomCursor(activeItem.itemCanvas, new Point(100,100));
        if(item is HelpingHand) world.cursor.mode = CustomCursor.BOTTOMRIGHT;
        //stores don't need to worry about rendering the playing field
        if(!(this is Store))world.render(true);
    }

    void handleItemInfoClick(Inventoryable item, {Element preview}) {
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

        inventoryColumn = new DivElement();
        inventoryColumn.classes.add("innerInventoryRowContainer");
        td1.append(inventoryColumn);
        for(Inventoryable inventoryItem in inventory) {
            //so they know how to popup
            //tbh i want each kind of inventorable to do something different here, but don't know how to make that a thing
            //and also not have to cast them. deal with it for now
            await drawOneItem(inventoryItem);
        }

        if(rightElement == null) makeRightElement();
        rightElement.onMouseDown.listen((Event e) {
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

    void unlockHidden() {
        for(Inventoryable item in inventory) {
            item.unHide();
        }
    }

    Future drawOneItem(Inventoryable inventoryItem) async {

      //so they know how to popup
      //tbh i want each kind of inventorable to do something different here, but don't know how to make that a thing
      //and also not have to cast them. deal with it for
      setCanvasForItem(inventoryItem);
      inventoryItem.inventory = this;
      if(inventoryColumn != null) {
          inventoryItem.renderMyInventoryRow(inventoryColumn);
      }
    }


  @override
  Iterator<Inventoryable> get iterator => inventory.iterator;
}

class InventoryPopup {
    Element tmpElement; //remove this if it exists when you cycle.
    DivElement container;
    DivElement header;
    DivElement textBody;
    DivElement parentScroll;

    int step = 0;
    InventoryPopup(Element parent) {
        container = new DivElement();
        container.onMouseDown.listen((Event e) {
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
        if(tmpElement != null) tmpElement.remove();

        container.style.display = "block";
        header.text = "${chosenItem.name.toUpperCase()} - \$${chosenItem.cost}";
        if(chosenItem is Fruit) {
            header.text = "${header.text} (Seed ID: ${(chosenItem as Fruit).doll.seed})";
        }
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

    void displayElement(Element ele, String newHeader) {
        tmpElement = ele;
        container.style.display = "block";
        header.text = newHeader;
        step = -13; //vanish on click
        textBody.style.display = "none";
        if(parentScroll != null) parentScroll.style.display = "none";
        container.append(ele);
    }

    void cycle() {
        if(step == 0) {
            textBody.style.display = "block";
            if(parentScroll != null) parentScroll.style.display = "none";
        }else if(step == 1 && parentScroll != null){
            textBody.style.display = "none";
            if(parentScroll != null) parentScroll.style.display = "block";
            header.text = "${header.text}: Parents";
        }else {
            if(parentScroll != null)parentScroll.remove();
            if(tmpElement != null) tmpElement.remove();
            dismiss();
        }
        step ++;
    }
}
