import '../Gameplay/World.dart';
import 'dart:async';
import 'dart:html';
import "../Utility/TODOs.dart";

import 'package:CommonLib/NavBar.dart';

Element output = querySelector('#output');
Future<Null> main() async{
    await loadNavbar();
    loadBackups();
    saveBackups();
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

void loadBackups() {
    LabelElement label = new LabelElement()..classes.add("meteorButton")..classes.add("storeButtonColor");
    label.text = "Restore Main Save From Backup:";
    InputElement fileElement = new InputElement();
    fileElement.type = "file";
    fileElement.setInnerHtml("Restore Main Save from Backup");
    label.append(fileElement);
    output.append(label);


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


    label = new LabelElement()..classes.add("meteorButton")..classes.add("storeButtonColor");
    label.text = "Restore Money Save From Backup:";
    InputElement fileElement2 = new InputElement();
    fileElement2.type = "file";
    label.append(fileElement2);
    output.append(label);


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

void saveBackups() {
    DivElement button = new DivElement()..classes.add("meteorButton")..classes.add("storeButtonColor");
    button.text = "Destroy Your Save Data?";
    button.classes.add("meteorButton");


    button.onClick.listen((e) {
        if (window.confirm("Are you sure? You can't undo this...")) {
            window.localStorage.remove(World.SAVEKEY);
            window.localStorage.remove(World.SHAREDKEY);
            window.location.href = "meteor.html";
        }
    });

    print("trying to do save back up links");
    if (window.localStorage.containsKey(World.SAVEKEY)) {
        print("data exists");
        try {
            AnchorElement saveLink2 = new AnchorElement()..classes.add("meteorButton")..classes.add("storeButtonColor");
            //saveLink2.href = new UriData.fromString(window.localStorage[Player.DOLLSAVEID], mimeType: "text/plain").toString();
            saveLink2.classes.add("meteorButton");
            String string = window.localStorage[World.SAVEKEY];
            Blob blob = new Blob([string]); //needs to take in a list o flists
            saveLink2.href = Url.createObjectUrl(blob).toString();
            saveLink2.target = "_blank";
            saveLink2.download = "treeSimData.txt";
            saveLink2.setInnerHtml("Download Backup");
            querySelector('#output').append(saveLink2);

        } catch (e) {
            errorDiv("Error attempting to make Object URL for back up url. $e");
        }
    }else {
        errorDiv("No Save Data to Make Backups of.");

    }

    if (window.localStorage.containsKey(World.SHAREDKEY)) {
        try {
            AnchorElement saveLink2 = new AnchorElement()..classes.add("meteorButton")..classes.add("storeButtonColor");
            saveLink2.classes.add("meteorButton");
            //saveLink2.href = new UriData.fromString(window.localStorage[Player.DOLLSAVEID], mimeType: "text/plain").toString();
            String string = window.localStorage[World.SHAREDKEY];
            Blob blob = new Blob([string]); //needs to take in a list o flists
            saveLink2.href = Url.createObjectUrl(blob).toString();
            saveLink2.target = "_blank";
            saveLink2.download = "treeSimSharedData.txt";
            saveLink2.setInnerHtml("Download Money Backup?");
            querySelector('#output').append(saveLink2);
        } catch (e) {
            errorDiv("Error attempting to shared Object URL for back up url. $e");

        }
    }else {
        errorDiv("No Shared Data to Make Backups of.");
    }

    querySelector('#output').append(button);

}

void errorDiv(String message) {
    DivElement error = new DivElement();
    error.style.color = "red";
    error.setInnerHtml(message);
    querySelector('#output').append(error);
}