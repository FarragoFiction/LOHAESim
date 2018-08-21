import '../Gameplay/World.dart';
import 'dart:async';
import 'dart:html';
import "../Utility/TODOs.dart";

import 'package:CommonLib/NavBar.dart';
import 'package:CommonLib/src/utility/JSONObject.dart';

Element output = querySelector('#output');
Future<Null> main() async{
    await loadNavbar();
    SaveSlot.handleSaveSlots();

    loadBackups(output);
    saveBackups(output);
    changeFPS();
}
void changeFPS() {
    World world = new World();
    DivElement wrapper = new DivElement()..text = "Change Frames Per Second (at your own peril)";
    wrapper.style.display = "block";
    DivElement label = new DivElement()..text = "Lower it from 30 to make older computers run better.";
    InputElement input = new InputElement();
    LabelElement label2 = new LabelElement()..text = "${world.musicSave.fps} fps";
    input.type = "range";
    input.min = "1";
    input.max = "60";
    input.value = "${world.musicSave.fps}";

    wrapper.append(label);
    wrapper.append(label2);
    wrapper.append(input);
    output.append(wrapper);

    input.onChange.listen((Event e) {
        label2.text = "${input.value} fps";
        world.musicSave.fps = int.parse(input.value);
        world.save("changing fps");
    });


}

void loadBackups(Element parent) {
    LabelElement label = new LabelElement()..classes.add("meteorButtonSaveSlot")..classes.add("storeButtonColor");
    label.text = "Load File";
    InputElement fileElement = new InputElement();
    fileElement.type = "file";
    fileElement.setInnerHtml("Load File:");
    label.append(fileElement);
    parent.append(label);


    fileElement.onChange.listen((e) {
        try {
            print("file element is $fileElement and message is ${fileElement.validationMessage} and files is ${fileElement.files}");
            List<File> loadFiles = fileElement.files;
            File file = loadFiles.first;
            FileReader reader = new FileReader();
            reader.readAsText(file);
            reader.onLoadEnd.listen((e) {
                String loadData = reader.result;
                window.localStorage[World.SAVEKEY] = loadData;
                window.location.href = "meteor.html";
            });
        }catch(e, trace) {
            window.alert("error uploading file");
            print("Error Uploading File $e, $trace");
        }
    });


    label = new LabelElement()..classes.add("meteorButtonSaveSlot")..classes.add("storeButtonColor");
    label.text = "Load Money File:";
    InputElement fileElement2 = new InputElement();
    fileElement2.type = "file";
    label.append(fileElement2);
    parent.append(label);


    fileElement2.onChange.listen((e) {
        try {
            List<File> loadFiles = fileElement2.files;
            File file = loadFiles.first;
            FileReader reader = new FileReader();
            reader.readAsText(file);
            reader.onLoadEnd.listen((e) {
                String loadData = reader.result;
                window.localStorage[World.SHAREDKEY] = loadData;
                window.location.href = "meteor.html";
            });
        }catch(e, trace) {
            window.alert("error uploading file");
            print("Error Uploading File $e, $trace");
        }
    });

}

void saveBackups(Element parent) {

    print("trying to do save back up links");
    if (window.localStorage.containsKey(World.SAVEKEY)) {
        print("data exists");
        try {
            AnchorElement saveLink2 = new AnchorElement()..classes.add("meteorButtonSaveSlot")..classes.add("storeButtonColor");
            //saveLink2.href = new UriData.fromString(window.localStorage[Player.DOLLSAVEID], mimeType: "text/plain").toString();
            saveLink2.classes.add("meteorButtonSaveSlot");
            String string = window.localStorage[World.SAVEKEY];
            Blob blob = new Blob([string]); //needs to take in a list o flists
            saveLink2.href = Url.createObjectUrl(blob).toString();
            saveLink2.target = "_blank";
            saveLink2.download = "treeSimData.txt";
            saveLink2.setInnerHtml("Download Backup");
            parent.append(saveLink2);

        } catch (e) {
            errorDiv("Error attempting to make Object URL for back up url. $e");
        }
    }else {
        errorDiv("No Save Data to Make Backups of.");

    }

    if (window.localStorage.containsKey(World.SHAREDKEY)) {
        try {
            AnchorElement saveLink2 = new AnchorElement()..classes.add("meteorButtonSaveSlot")..classes.add("storeButtonColor");
            saveLink2.classes.add("meteorButtonSaveSlot");
            //saveLink2.href = new UriData.fromString(window.localStorage[Player.DOLLSAVEID], mimeType: "text/plain").toString();
            String string = window.localStorage[World.SHAREDKEY];
            Blob blob = new Blob([string]); //needs to take in a list o flists
            saveLink2.href = Url.createObjectUrl(blob).toString();
            saveLink2.target = "_blank";
            saveLink2.download = "treeSimSharedData.txt";
            saveLink2.setInnerHtml("Download Money?");
            parent.append(saveLink2);
        } catch (e) {
            errorDiv("Error attempting to shared Object URL for back up url. $e");

        }
    }else {
        errorDiv("No Shared Data to Make Backups of.");
    }


}



void errorDiv(String message) {
    DivElement error = new DivElement();
    error.style.color = "red";
    error.setInnerHtml(message);
    querySelector('#output').append(error);
}


//clicking one loads it to World.SHAREDKEY
//can also delete it
//can load data to a save slot
//and can load this save slots data into the main file
class SaveSlot {
    static String labelKey = "LOHAE_SAVE_SLOT";
    static String currentTimelineLabel = "CURRENT TIMELINE";
    String label; //is also the key
    DateTime lastPlayed = new DateTime.now();
    String get size =>  "${((data.codeUnits.length + sharedData.codeUnits.length)/1024/1024).toStringAsFixed(4)} MBs";
    int money;
    int numberArchives;
    int numberEssences;
    String gigglesnortLocation = "images/BGs/sleeping.png";
    String data;
    String sharedData;
    Element container;

    bool current;

    String get key => "${labelKey}_${label}";

    SaveSlot(Element parent, String this.label, bool this.current) {
        container = new DivElement()..classes.add("saveSlot");
        parent.append(container);
        slurpSelf();
        render();
    }

    //loads self from file, if can't find self use current save data to create self
    void slurpSelf() {
        if(window.localStorage.containsKey(key) && !current) {
            fromJSON();
        }else {
            createFromScratch();
            save();
        }
    }

    void save() {
        window.localStorage[key] = toJSON().toString();
    }

    void deleteButton(Element parent) {
        DivElement button = new DivElement()..classes.add("meteorButtonSaveSlot")..classes.add("storeButtonColor");
        button.text = "Delete?";
        button.classes.add("meteorButtonSaveSlot");


        button.onClick.listen((e) {
            if (window.confirm("Are you sure? You can't undo this...")) {
                resetTimeline();
            }
        });
        parent.append(button);
    }

    void resetTimeline() {
      World newWorld = new World(true); //its reset
      data = newWorld.toDataString();
      sharedData = newWorld.toDataString();
      lastPlayed = new DateTime.now();
      window.localStorage[key] = toJSON().toString();
      window.location.href = "meteor.html";
    }


    void fromJSON() {
        JSONObject json = new JSONObject.fromJSONString(window.localStorage[key]);
        //everything else follows from it
        data = json["data"];
        sharedData = json["sharedData"];
        String plantString = json["lastPlayed"];
        lastPlayed = new DateTime.fromMillisecondsSinceEpoch(int.parse(plantString));

        parseData();
    }

    void createFromScratch() {
        if(window.localStorage.containsKey(World.SAVEKEY)){
            data = window.localStorage[World.SAVEKEY];
            sharedData = window.localStorage[World.SHAREDKEY];
        }else {
            World world = World.instance;
            world.save("Making init for save slots");
            data = world.toDataString();
            sharedData = world.sharedToDataString();
        }
        parseData();
    }

    JSONObject toJSON() {
        JSONObject json = new JSONObject();
        json["data"] = data;
        json["sharedData"] = sharedData;
        json["lastPlayed"] = "${lastPlayed.millisecondsSinceEpoch}";
        return json;

    }

    void parseData() {

    }

    static void handleSaveSlots() {
        new SaveSlot(output, currentTimelineLabel, true);
        new SaveSlot(output, "TIMELINE 1",false);
        new SaveSlot(output, "TIMELINE 2",false);
        new SaveSlot(output, "TIMELINE 3",false);
    }

    void render() {
        DivElement nameElement = new DivElement()..text = "$label ($size)";
        container.append(nameElement);
        TableElement table = new TableElement();
        container.append(table);
        TableRowElement row = new TableRowElement();
        table.append(row);

        TableCellElement cell1 = new TableCellElement();
        row.append(cell1);
        ImageElement gigglesnort = new ImageElement(src: "$gigglesnortLocation")..classes.add("gigglesnort");
        cell1.append(gigglesnort);
        TableCellElement cell = new TableCellElement();
        row.append(cell);
        renderStats(cell);
        cell = new TableCellElement();
        row.append(cell);
        saveBackups(cell);
        cell = new TableCellElement();
        row.append(cell);
        loadBackups(cell);
        cell = new TableCellElement();
        row.append(cell);

        cell = new TableCellElement();
        row.append(cell);
        deleteButton(cell);
        changeTimeline(cell);
        cell = new TableCellElement();
        row.append(cell);
        cell.style.textAlign = "right";
        DivElement lastPlayedElement = new DivElement()..classes.add("lastPlayed")..text = "${lastPlayed.year}-${lastPlayed.month.toString().padLeft(2,'0')}-${lastPlayed.day.toString().padLeft(2,'0')} ${lastPlayed.hour.toString().padLeft(2,'0')}:${lastPlayed.minute.toString().padLeft(2,'0')}";
        cell.append(lastPlayedElement);
    }

    void changeTimeline(TableCellElement element) {
        if(!current) {
            DivElement button = new DivElement()..classes.add("meteorButtonSaveSlot")..classes.add("storeButtonColor");
            button.text = "Make Current?";
            button.classes.add("meteorButtonSaveSlot");


            button.onClick.listen((e) {
                World world = World.instance;
                world.copyFromDataString(data);
                world.copySharedFromDataString(sharedData);
                world.save("Loading a Timeline");
                window.location.href = "meteor.html";
            });
            element.append(button);
        }

    }



    void renderStats(TableCellElement cell) {
        TableElement table = new TableElement();
        cell.append(table);
        TableRowElement row = new TableRowElement();
        table.append(row);
        TableCellElement essenceElement = new TableCellElement()..text = "Essences: ";
        TableCellElement valueElement1 = new TableCellElement()..text = "$numberEssences"..classes.add("valueElement");
        row.append(essenceElement);
        row.append(valueElement1);

        row = new TableRowElement();
        table.append(row);
        TableCellElement moneyElement = new TableCellElement()..text = "Funds:";
        TableCellElement valueElement2 = new TableCellElement()..text = "$money"..classes.add("valueElement");
        row.append(moneyElement);
        row.append(valueElement2);

        row = new TableRowElement();
        table.append(row);
        TableCellElement archiveElement = new TableCellElement()..text = "Unique Fruit:";
        TableCellElement valueElement3 = new TableCellElement()..text = "$numberArchives"..classes.add("valueElement");
        row.append(archiveElement);
        row.append(valueElement3);



    }

}