import '../Gameplay/World.dart';
import 'dart:async';
import 'dart:html';
import "../Utility/TODOs.dart";

import 'package:CommonLib/NavBar.dart';

Element output = querySelector('#output');
Future<Null> main() async{
    await loadNavbar();
    saveBackups();
}

void saveBackups() {
    ButtonElement button = new ButtonElement()..classes.add("meteorButton")..classes.add("storeButtonColor");
    button.text = "destroy your save data?";
    querySelector('#output').append(button);

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
            //saveLink2.href = new UriData.fromString(window.localStorage[Player.DOLLSAVEID], mimeType: "text/plain").toString();
            String string = window.localStorage[World.SAVEKEY];
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
}

void errorDiv(String message) {
    DivElement error = new DivElement();
    error.style.color = "red";
    error.setInnerHtml(message);
    querySelector('#output').append(error);
}
