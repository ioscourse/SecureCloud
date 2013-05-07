document.addEventListener("DOMContentLoaded", main, false);

function main() {
	var ws = new WebSocket("ws://192.168.10.109:8080");
	ws.onopen = function(event) {
		console.log("WebSocket conmection is open");
		var output = {
			"message" : "I'm connected",
			"action": "getCloudStructure"
		};
		ws.send(JSON.stringify(output));
	};
	ws.onmessage = function(event) {
		console.log("WebSocket message: " + event.data);
		var input = JSON.parse(event.data);
		
		if (input["action"] != null)
		{
			switch (input["action"])
			{
				case "updateStructure":
					updateStructure(input["structure"]);
					break;
			}
		}
	};
	ws.onerror = function(event) {
		alert("An error occurred for the WebSocket connection.");
	};
	ws.onclose = function(event) {
		alert("WebSocket connection has been closed.");
	};
	
	function updateStructure(structure) {
		var ulElement = document.querySelector("#fileList");
		
		ulElement.innerHTML = "";
		
		structure.rootDir.forEach(function(fileData) {
			var listElement = document.createElement("li");
			listElement.innerHTML = "<input type='checkbox' />&nbsp;&nbsp;<strong>" + fileData.name + "</strong>";
			listElement.onclick = function() {
				prompt("What is the file data?", "");
			};
			ulElement.appendChild(listElement);
		});
	}
}