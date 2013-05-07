library main_nav;

import "dart:html";
import "../FileManager/FileManager.dart";

class MainNav {
  static Element element = query("#mainNav");
  static Element sendBtn = query("#sendBtn");
  static Element requestBtn = query("#requestBtn");
  
  static void init()
  {
    sendBtn.onClick.listen((event) {
      FileManager.sendToCloud();
    });
    /*
    requestBtn.onClick.listen((event) {
      FileManager.requestFromCloud();
    });
    */
  }
  
  static void toggle(event)
  {
    event.preventDefault();
    
    element.classes.toggle("displayed");
  }
}