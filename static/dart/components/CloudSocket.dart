library cloud_socket;

import "dart:html";
import "dart:json";
import "../FileManager/FileManager.dart";

class CloudSocket {
  static WebSocket ws;
  
  static void init()
  {
    ws = new WebSocket("ws://192.168.10.109:8080");
    ws.onOpen.listen(onOpen);
    ws.onMessage.listen(onMessage);
    ws.onError.listen(onError);
    ws.onClose.listen(onClose);
    
    query("#setAsBaseBtn").onClick.listen((event){
      event.preventDefault();
      
      Map output = new Map();
      output["action"] = "setAsBaseCloud";
      ws.send(stringify(output));
      event.target.classes.add("selected");
    });
    
    query("#requestBtn").onClick.listen((event) {
      event.preventDefault();
      
      Map output = new Map();
      output["action"] = "getCloudStructure";
      ws.send(stringify(output));
    });
  }
  
  static void onOpen(dynamic event)
  {
    print("WebSocket opened");
    Map data = new Map();
    data["message"] = "I'm connected";
    ws.send(stringify(data));
  }
  
  static void onMessage(dynamic event)
  {
    print("WebSocket message: " + event.data);
    Map input = parse(event.data);
    
    if (input["action"] != null)
    {
      switch (input["action"])
      {
        case "getCloudStructure":
          FileManager.sendToCloud();
          break;
        case "updateStructure":
          FileManager.updateStructure(input["structure"]);
          break;
      }
    }
  }
  
  static void onError(dynamic event)
  {
    print("WebSocket error");
    window.alert("Error connecting to WebSocket.");
  }
  
  static void onClose(dynamic event)
  {
    print("WebSocket closed");
    window.alert("WebSocket has been disconnected.");
  }
}