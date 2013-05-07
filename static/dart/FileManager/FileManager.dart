library file_manager;

import "dart:html";
import "dart:json";
import "dart:async";
import "../components/MainSection.dart";
import "../components/TextFileEditorBox.dart";
import "../components/CloudSocket.dart";

class FileManager {
  static FileSystem _filesystem;
  
  static void init()
  {
    print(">>> FileManager.init");
    
    window.requestFileSystem(1024*1024*30).then(_success, onError: _error);
  }

  static void _success(FileSystem filesystem)
  {
    print(">>> _success");
    
    _filesystem = filesystem;
    updateFileList();
    //MainSection.element.query("#removeFilesBtn").onClick.listen(removeFiles);
    //MainSection.element.query("#editSampleFileBtn").onClick.listen(_editSampleFile);
  }

  static void _error(FileError error)
  {
    print(">>> _error");
    window.console.log(error);
  }

  static void addFile(String filename, String fileContents)
  {
    print(">>> addFile");
    
    _filesystem.root.createFile(filename).then((FileEntry fileEntry) {
      fileEntry.createWriter().then((FileWriter writer) {
        Blob blob = new Blob([fileContents], "text/plain");
        
        StreamSubscription subscr = writer.onWriteEnd.listen(null);
        subscr.onData((event) {
          subscr.cancel();
          print("written");
          writer.onWriteEnd.listen((event) {
            updateFileList();
            sendToCloud();
          });
          writer.write(blob);
        });
        
        writer.truncate(0);
      });
    });
  }

  static void removeFiles([Event event])
  {
    print(">>> removeFiles");

    if (event != null)
    {
      event.preventDefault();
    }

    int index = 0;
    
    _filesystem.root.createReader().readEntries().then((List<Entry> entries) {
      entries.forEach((Entry entry) {
        entry.remove().then((event) {
          index++;
          
          if (index == entries.length)
          {
            updateFileList();
          }
        });
      });
    });
  }

  static void removeFile([event])
  {
    String filename = event.target.dataset.filename;
  }

  static void removeFileByName(String filename)
  {
    print(">>>>> removeFileByName: " + filename);

    _filesystem.root.getFile(filename).then((FileEntry entry) {
      entry.remove().then((event) {
        updateFileList();
        sendToCloud();
      });
    });
  }

  static void updateFileList()
  {
    print(">>> updateFileList");

    UListElement ul = MainSection.element.query("#fileList");
    ul.innerHtml = "";

    _filesystem.root.createReader().readEntries().then((List<Entry> entries) {
      entries.forEach((FileEntry entry) {
        Element li = new Element.tag("li");
        Element str = new Element.tag("strong");

        str.text = entry.name;

        li.append(str);

        entry.file().then((File file) {
          FileReader reader = new FileReader();
          reader.onLoadEnd.listen((event) {
            String fileContents = event.target.result;
            li.onClick.listen((event) {
              TextFileEditorBox.show(file.name, fileContents);
            });
            ul.append(li);
          });
          reader.readAsText(file);
        });
      });
    });
  }

  static void _sendFiles(Map fileDataList)
  {
    print(">>>>> _sendFiles");

    FormData formData = new FormData();
    formData.append("username", "username");
    formData.append("password", "password");
    formData.append("fileStream", stringify(fileDataList));

    HttpRequest.request("processing/upload-to-cloud.php", method: "POST", sendData: formData);
  }
  
  static void sendToCloud()
  {
    print(">>> sendToCloud");
    
    // Create a file entry reader in the root directory; gets list of entries
    _filesystem.root.createReader().readEntries().then((List<Entry> entries) {
      Map output = new Map();
      output["action"] = "distributeStructure";
      output["structure"] = new Map();
      output["structure"]["rootDir"] = new List();
      
      if (entries.length > 0)
      {
        // Initialize iteration index
        int index = 0;

        // Loop through each entry
        entries.forEach((FileEntry entry) {
          // Get the file contents
          entry.file().then((File file) {
            // Create object literal for this file's data
            Map fileData = new Map();
            
            // Assign the file name
            fileData["name"] = file.name;

            // Add the file data to the root directory list
            output["structure"]["rootDir"].add(fileData);
            
            // Increase the iteration index
            index++;
            
            // If the index matches the total number of entries,
            // send the data to the server
            if (index == entries.length)
            {
              CloudSocket.ws.send(stringify(output));
            }
          });
        });
      } else
      {
        CloudSocket.ws.send(stringify(output));
      }
    });
      
    return;
/*
    // Create a file entry reader in the root directory; gets list of entries
    _filesystem.root.createReader().readEntries().then((List<Entry> entries) {
      // Create an object literal for holding file data
      Map<String, dynamic> fileDataList = new Map<String, dynamic>();
      
      // Initialize iteration index
      int index = 0;

      // Create a list for files in the root directory
      fileDataList["rootDir"] = new List<Map>();

      // Loop through each entry
      entries.forEach((FileEntry entry) {
        // Get the file contents
        entry.file().then((File file) {
          // Create a file reader object
          FileReader reader = new FileReader();
          
          // Attach async onLoadEnd event callback
          reader.onLoadEnd.listen((event) {
            // Create object literal for this file's data
            Map fileData = new Map();
            
            // Assign the file name and file contents
            fileData["name"] = file.name;
            fileData["data"] = event.target.result;

            // Add the file data to the root directory list
            fileDataList["rootDir"].add(fileData);
            
            // Increase the iteration index
            index++;
            
            // If the index matches the total number of entries,
            // send the data to the server
            if (index == entries.length)
            {
              _sendFiles(fileDataList);
            }
          });
          
          // Read the file as text
          reader.readAsText(file);
        });
      });
    });
    */
  }
  
  static void updateStructure(Map structure)
  {
    print(">>> updateStructure");
    
    List<String> filenames = structure["rootDir"];
    
    _filesystem.root.createReader().readEntries().then((List<Entry> entries) {
      // If there are entries to delete
      if (entries.length > 0)
      {
        int index = 0;
        
        entries.forEach((Entry entry) {
          print(">>> looping read entries");
          entry.remove().then((event) {
            print(">>> entry removed");
            index++;
            
            if (index == entries.length)
            {
              if (filenames.length > 0)
              {
                int filenamesIndex = 0;
                
                filenames.forEach((Map filename) {
                  _filesystem.root.createFile(filename["name"]).then((FileEntry entry) {
                    print(">>>>> created: ${filename["name"]}");
                    filenamesIndex++;
                    
                    if (filenamesIndex == filenames.length)
                    {
                      updateFileList();
                    }
                  });
                });
              } else
              {
                updateFileList();
              }
            }
          });
        });
      }
      // Simply create the new files
      else 
      {
        int filenamesIndex = 0;
        
        filenames.forEach((Map filename) {
          _filesystem.root.createFile(filename["name"]).then((FileEntry entry) {
            print(">>>>> created: ${filename["name"]}");
            filenamesIndex++;
            
            if (filenamesIndex == filenames.length)
            {
              updateFileList();
            }
          });
        });
      }
    });
  }
  
  static void requestFromCloud()
  {
    print(">>> requestFromCloud");
    return;
    
    // Create the FormData object with credentials for submitting to the server
    FormData formData = new FormData();
    formData.append("username", "username");
    formData.append("password", "password");
    
    removeFiles();

    // Start the GET HTTP request for the file data
    HttpRequest.request("processing/download-from-cloud.php", method: "POST", sendData: formData)
    ..then((request) {
      // Parse the JSON response
      Map response = parse(request.responseText);
      
      // Parse the filesystem structure JSON
      Map fileDataList = parse(response["fileStream"]);

      // Create a looping index
      int index = 0;

      // Loop through each root directory file
      fileDataList["rootDir"].forEach((Map fileData) {
        // Create file entry
        _filesystem.root.createFile(fileData["name"]).then((FileEntry entry) {
          // Create file writer
          entry.createWriter().then((FileWriter writer) {
            // Generate blob with data
            Blob blob = new Blob([fileData["data"]]);

            // Write the data
            writer.write(blob);
            
            // Increase the iteration index
            index++;

            // If the iteration index is equal the total loop length, update file list
            if (index == fileDataList["rootDir"].length)
            {
              updateFileList();
            }
          });
        });
      });
    });
  }
}