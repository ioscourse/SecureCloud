library main_section;

import "dart:html";
import "../FileManager/FileManager.dart";
import "MainNav.dart";
import "TextFileEditorBox.dart";

class MainSection {
  static Element element = query("#mainSection");
  static Element menuBtn = query("#menu");
  static Element createFileBtn = query("#newFile");
  
  static void init()
  {
    menuBtn.onClick.listen(MainNav.toggle);
    createFileBtn.onClick.listen((event) => TextFileEditorBox.show());
  }
  
  static void displayTextFileEditor([String filename, String fileContents])
  {
    DocumentFragment frag = query("#template_textFileEditor").content.clone(true);
    InputElement filenameLabel = frag.query(".filename");
    TextAreaElement textarea = frag.query(".fileContents");
    InputElement saveBtn = frag.query(".saveBtn");
    
    if (filename != null)
    {
      filenameLabel.value = filename;
    }
    
    if (fileContents != null)
    {
      textarea.text = fileContents;
    }
    
    saveBtn.onClick.listen((event) {
      print(">>> saving file");
      String filename = filenameLabel.value;
      String fileContents = textarea.value;
      FileManager.addFile(filename, fileContents);
      event.target.parent.remove();
    });
    
    MainSection.element.append(frag);
  }
}