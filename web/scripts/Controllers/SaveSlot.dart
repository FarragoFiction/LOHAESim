import '../Gameplay/World.dart';
import 'dart:html';

import 'package:CommonLib/Utility.dart';


//clicking one loads it to World.SHAREDKEY
//can also delete it
//can load data to a save slot
//and can load this save slots data into the main file
class SaveSlot {
    static String labelKey = "LOHAE_SAVE_SLOT";
    static String currentTimelineLabel = "CURRENT TIMELINE";

    static String sleeping = "images/BGs/sleeping.png";
    static String dead = "images/BGs/dead.png";
    static String owo = "images/BGs/purified.png";
    static String fight = "images/BGs/fight.png";


    String label; //is also the key
    DateTime lastPlayed = new DateTime.now();
    String get size =>  "${((data.codeUnits.length + sharedData.codeUnits.length)/1024).toStringAsFixed(2)} KB";
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
        if(parent != null) {
            container = new DivElement()
                ..classes.add("saveSlot");
            parent.append(container);
            slurpSelf();
            render();
        }
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


        button.onMouseDown.listen((e) {
            e.stopPropagation();
            if (window.confirm("Are you sure? You can't undo this...")) {
                resetTimeline();
            }
        });
        parent.append(button);
    }

    void destroy() {
        window.localStorage.remove(key);
    }

    void resetTimeline() {
        if(current) {
            window.localStorage.remove(World.SHAREDKEY);
            window.localStorage.remove(World.SAVEKEY);
            window.location.href = "index.html";
        }else {
            World newWorld = new World(false); //its reset
            data = newWorld.toDataString();
            sharedData = newWorld.toDataString();
            lastPlayed = new DateTime.now();
            window.localStorage[key] = toJSON().toString();
            window.location.href = "meteor.html";
        }
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
        World world = new World(false);
        world.copyFromDataString(data);
        world.copySharedFromDataString(sharedData);
        numberEssences = world.underWorld.player.numberEssences;
        money = world.underWorld.player.funds;
        numberArchives = world.pastFruit.values.length;

        if(world.underWorld.nidhogg.dead) {
            gigglesnortLocation = SaveSlot.dead;
        }else if(world.underWorld.nidhogg.purified) {
            gigglesnortLocation = SaveSlot.owo;
        }else if(world.bossFight) {
            gigglesnortLocation = SaveSlot.fight;
        }else{
            gigglesnortLocation = SaveSlot.sleeping;
        }

    }

    static List<SaveSlot> handleSaveSlots(Element o) {
        List<SaveSlot> ret = new List<SaveSlot>();
        ret.add(new SaveSlot(o, currentTimelineLabel, true));
        ret.add(new SaveSlot(o, "TIMELINE 1",false));
        ret.add(new SaveSlot(o, "TIMELINE 2",false));
        ret.add(new SaveSlot(o, "TIMELINE 3",false));
        return ret;
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
        writeCurrentHere(cell);
        cell = new TableCellElement();
        row.append(cell);
        cell.style.textAlign = "right";
        DivElement lastPlayedElement = new DivElement()..classes.add("lastPlayed")..text = "${lastPlayed.year}-${lastPlayed.month.toString().padLeft(2,'0')}-${lastPlayed.day.toString().padLeft(2,'0')} ${lastPlayed.hour.toString().padLeft(2,'0')}:${lastPlayed.minute.toString().padLeft(2,'0')}";
        cell.append(lastPlayedElement);

        //do this last in the hope that it doesn't fucking do anything if i click something more important
        container.onMouseDown.listen((Event e){
            makeCurrent();
            e.stopPropagation();
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

        fileElement.onMouseDown.listen((Event e) {
            e.stopPropagation();
        });

        fileElement.onChange.listen((Event e) {
            e.stopPropagation();
            try {
                print("file element is $fileElement and message is ${fileElement.validationMessage} and files is ${fileElement.files}");
                List<File> loadFiles = fileElement.files;
                File file = loadFiles.first;
                FileReader reader = new FileReader();
                reader.readAsText(file);
                reader.onLoadEnd.listen((e) {
                    String loadData = reader.result;
                    data = loadData;
                    save();
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

        fileElement2.onMouseDown.listen((Event e) {
            e.stopPropagation();
        });


        fileElement2.onChange.listen((e) {
            try {
                List<File> loadFiles = fileElement2.files;
                File file = loadFiles.first;
                FileReader reader = new FileReader();
                reader.readAsText(file);
                reader.onLoadEnd.listen((e) {
                    String loadData = reader.result;
                    sharedData = loadData;
                    save();
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
        if (data != null) {
            print("data exists");
            try {
                AnchorElement saveLink2 = new AnchorElement()..classes.add("meteorButtonSaveSlot")..classes.add("storeButtonColor");
                //saveLink2.href = new UriData.fromString(window.localStorage[Player.DOLLSAVEID], mimeType: "text/plain").toString();
                saveLink2.onMouseDown.listen((Event e) {
                    e.stopPropagation();
                });
                saveLink2.classes.add("meteorButtonSaveSlot");
                String string = data;
                Blob blob = new Blob([string]); //needs to take in a list o flists
                saveLink2.href = Url.createObjectUrl(blob).toString();
                saveLink2.target = "_blank";
                saveLink2.download = "treeSimData${label}.txt";
                saveLink2.setInnerHtml("Download Backup");
                parent.append(saveLink2);

            } catch (e) {
                errorDiv("Error attempting to make Object URL for back up url. $e");
            }
        }else {
            errorDiv("No Save Data to Make Backups of.");

        }

        if (sharedData != null) {
            try {
                AnchorElement saveLink2 = new AnchorElement()..classes.add("meteorButtonSaveSlot")..classes.add("storeButtonColor");
                saveLink2.classes.add("meteorButtonSaveSlot");
                saveLink2.onMouseDown.listen((Event e) {
                    e.stopPropagation();
                });
                //saveLink2.href = new UriData.fromString(window.localStorage[Player.DOLLSAVEID], mimeType: "text/plain").toString();
                String string = sharedData;
                Blob blob = new Blob([string]); //needs to take in a list o flists
                saveLink2.href = Url.createObjectUrl(blob).toString();
                saveLink2.target = "_blank";
                saveLink2.download = "treeSimSharedData${label}.txt";
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



    void writeCurrentHere(TableCellElement element) {
        if(!current) {
            DivElement button = new DivElement()..classes.add("meteorButtonSaveSlot")..classes.add("storeButtonColor");
            button.text = "Override Timeline?";
            button.classes.add("meteorButtonSaveSlot");

            button.onMouseDown.listen((e) {
                e.stopPropagation();
                World world = new World();
                data = world.toDataString();
                sharedData = world.sharedToDataString();
                lastPlayed = new DateTime.now();
                save();
                window.location.href = "meteor.html";
            });
            element.append(button);
        }

    }

    void makeCurrent() {
        World world = new World(false);
        world.copyFromDataString(data);
        world.copySharedFromDataString(sharedData);
        world.save("Loading a Timeline");
        //window.alert("check console did anything go wrong?");
        window.location.href = "meteor.html";
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