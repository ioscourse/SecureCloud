library ws_server;

import "dart:io";
import "dart:async";
import "dart:uri";
import "dart:json";

//const HOST = "127.0.0.1";
const HOST = "192.168.10.109";
const PORT = 8080;

// HTTP plus WS Server
void main() {
  List<Map> connections = new List<Map>();
  Map<String, String> contentTypes = const {
    "html": "text/html; charset=UTF-8",
    "dart": "application/dart",
    "js": "application/javascript",
    "css" : "text/css"
  };
  WebSocket baseCloudConnection;
  
  void getCloudStructure(WebSocket websocket)
  {
    websocket.add("[new structure]");
  }
  
  String getContentType(String filename)
  {
    String fileType = "";
    
    if (filename.endsWith(".html"))
    {
      return contentTypes["html"];
    } else if (filename.endsWith(".dart"))
    {
      return contentTypes["dart"];
    } else if (filename.endsWith(".js"))
    {
      return contentTypes["js"];
    } else if (filename.endsWith(".css"))
    {
      return contentTypes["css"];
    } else
    {
      return "text/plain";
    }
  }
  
  HttpServer.bind(HOST, PORT).then((HttpServer server) {
    print("HTTP Server is running at http://${HOST}:${PORT}");
    server.listen((HttpRequest request) {
      if (WebSocketTransformer.isUpgradeRequest(request))
      {
        //--------------------//
        // WebSocket Server
        //--------------------//
        print("WebSocket request");
        WebSocketTransformer.upgrade(request).then((WebSocket websocket) {
          Map<String, dynamic> socketData = new Map<String, dynamic>();
          socketData["connection"] = websocket;
          socketData["id"] = 0;
          
          connections.add(socketData);
          websocket.listen((String event) {
            print("message event: ${event}");
            Map input = parse(event);
            Map output = new Map();
            
            if (input["action"] != null)
            {
              switch (input["action"])
              {
                case "setAsBaseCloud":
                  output["message"] = "alrighty, sounds good to me";
                  websocket.add(stringify(output));
                  baseCloudConnection = websocket;
                  break;
                case "getCloudStructure":
                  print(">> getCloudStructure");
                  Map output2 = new Map();
                  output2["message"] = "getting structure";
                  websocket.add(stringify(output2));
                  
                  if (baseCloudConnection != null)
                  {
                    output["action"] = "getCloudStructure";
                    baseCloudConnection.add(stringify(output));
                  } else
                  {
                    Map errorOutput = new Map();
                    errorOutput["error"] = "no base cloud server has been identified";
                    websocket.add(stringify(errorOutput));
                  }
                  break;
                case "distributeStructure":
                  output["action"] = "updateStructure";
                  output["structure"] = input["structure"];
                  connections.forEach((item) {
                    if (item["connection"] != websocket)
                    {
                      item["connection"].add(stringify(output));
                    }
                  });
                  break;
              }
            } else
            {
              connections.forEach((item) {
                print("onData: iterating items");
                if (item["connection"] != websocket)
                {
                  item["connection"].add(event);
                }
              });
            }
          },
          onError:(dynamic error) {
            print("websocket errorz");
          },
          onDone:() {
            print("connection closed");
            int indexToRemoveAt = 0;
            
            connections.forEach((item) {
              print("onDone: iterating items");
              if (item["connection"] == websocket)
              {
                print("item matches");
                indexToRemoveAt = connections.indexOf(item);
              }
            });
            
            connections.removeAt(indexToRemoveAt);
            print(">>> removed");
          });
        });
      } else
      {
        //---------------//
        // HTTP Server
        //---------------//
        print("normal Http request");
        Uri uri = request.uri;
        String path = (uri.path.endsWith("/")) ? "/index.html" : uri.path;
        print(path);
        
        File file = new File("C:/Users/Brandon/Desktop/Google Drive/Documents/Web Dev/Jennex Official/dev-bwhite/secure-cloud" + path);
        file.exists().then((bool exists) {
          if (exists)
          {
            file.fullPath().then((dynamic fullPath) {
              print(fullPath);
            });
            print("file exists");
            file.readAsLines().then((List linesList) {
              request.response.headers.set(HttpHeaders.CONTENT_TYPE, getContentType(file.path));
              linesList.forEach((text) {
                request.response.write(text + "\n");
              });
              request.response.close();
            }, onError:(dynamic error) {
              print("file read error");
            });
          } else
          {
            print("file does not exist");
            request.response.statusCode = HttpStatus.NOT_FOUND;
            request.response.close();
          }
        }, onError:(dynamic error) {
          print("file exists test error");
        });
        
        //String msg = createHtmlResponse();
        
        //request.response.headers.set(HttpHeaders.CONTENT_TYPE, "text/html; charset=UTF-8");
        //request.response.write(msg);
        //request.response.close();
      }
    });
    
  });
}

String createHtmlResponse() {
  return
'''
<!doctype html>
<html>
  <head>
  <title>WebSocket Test</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0" />

  <script type="text/javascript">
    var ws = new WebSocket("ws://$HOST:$PORT");
    ws.onopen = function(e) {
      console.log("open");
      ws.send("I'm connected");
document.querySelector("#sendBtn").onclick = function(){ws.send(document.querySelector("#messageVal").value);};
    };
    ws.onmessage = function(e) {
      console.log("message event: " + e.data);
var item = document.createElement("p");
item.innerText = e.data;
      document.body.appendChild(item);
    };
  </script>
  </head>
  <body>
    <h1>WebSocket Test</h1>
    <input id="messageVal" />&nbsp;<input type="button" value="Send" id="sendBtn" />
  </body>
</html>
''';
}