library text_file_editor_box;

import "dart:html";
import "../FileManager/FileManager.dart";

class TextFileEditorBox {  
  static void show([String filename, String fileContents])
  {
    print(">>> TextFileEditorBox.show($filename, $fileContents)");
    
    DocumentFragment _frag = query("#template_textFileEditor").content.clone(true);
    InputElement filenameInput = _frag.query(".filename");
    TextAreaElement textarea = _frag.query(".fileContents");
    InputElement saveBtn = _frag.query(".saveBtn");
    InputElement deleteBtn = _frag.query(".deleteBtn");
    
    if (filename != null)
    {
      filenameInput.value = filename;
    }
    
    if (fileContents != null)
    {
      textarea.text = fileContents;
    }
    
    saveBtn.onClick.listen((event) {
      print(">>> saving file");
      String filename = filenameInput.value;
      String fileContents = textarea.value;
      
      if (filename != "")
      {
        FileManager.addFile(filename, fileContents);
      }
      hide();
    });
    
    deleteBtn.onClick.listen((event) {
      FileManager.removeFileByName(filename);
      hide();
    });
    
    window.document.body.append(_frag);
  }
  
  static void hide()
  {
    query(".textFileEditorBox").remove();
  }
}