import '../Gameplay/World.dart';
import 'dart:html';
import "../Utility/TODOs.dart";

Element output = querySelector('#output');
void main() {
    saveBackups();
}

void saveBackups() {
    ButtonElement button = new ButtonElement();
    button.text = "destroy your save data?";
    querySelector('#output').append(button);

    button.onClick.listen((e) {
        if (window.confirm("Are you sure? You can't undo this...")) {
            window.localStorage.remove(World.SAVEKEY);
            window.location.href = "meteor.html";
        }
    });

    if (window.localStorage.containsKey(World.SAVEKEY)) {
        try {
            AnchorElement saveLink2 = new AnchorElement();
            //saveLink2.href = new UriData.fromString(window.localStorage[Player.DOLLSAVEID], mimeType: "text/plain").toString();
            String string = window.localStorage[World.SAVEKEY];
            Blob blob = new Blob([string]); //needs to take in a list o flists
            saveLink2.href = Url.createObjectUrl(blob).toString();
            saveLink2.target = "_blank";
            saveLink2.download = "treeSimData.txt";
            saveLink2.setInnerHtml("Download Backup");
            querySelector('#output').append(saveLink2);
        } catch (e) {
            DivElement error = new DivElement();
            error.style.color = "red";
            error.setInnerHtml(
                "Error attempting to make Object URL for alternative back up url. $e");
            querySelector('#output').append(error);
        }
    }
}
