//used to handle saving and loading music information, nothing else.

import 'dart:convert';

import 'package:CommonLib/Utility.dart';

class MusicSave {
    static String labelPattern = ":___ ";

    String currentSong;
    //number between 0 and 100;
    int volume = 50;
    bool paused = true;



    String toDataString() {
        try {
            String ret = toJSON().toString();
            return "Music$labelPattern${BASE64URL.encode(ret.codeUnits)}";
        }catch(e) {
            print(e);
            print("Error Saving Data. Are there any special characters in there? ${toJSON()} $e");
        }
    }

    JSONObject toJSON() {
        JSONObject json = new JSONObject();
        json["currentSong"] = currentSong;
        json["volume"] = "$volume";
        json["paused"] = "$paused";
        return json;
    }

    void copyFromDataString(String dataString) {
        //print("dataString is $dataString");
        List<String> parts = dataString.split("$labelPattern");
        //print("parts are $parts");
        if(parts.length > 1) {
            dataString = parts[1];
        }

        String rawJson = new String.fromCharCodes(BASE64URL.decode(dataString));
        JSONObject json = new JSONObject.fromJSONString(rawJson);
        copyFromJSON(json);
    }

    void copyFromJSON(JSONObject json) {
        paused = json["paused"] ==true.toString();;
        volume = int.parse(json["volume"]);
        currentSong = json["currentSong"];
    }


}