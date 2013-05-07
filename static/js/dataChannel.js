var sendChannel, receiveChannel;
var startChannelBtn = document.getElementById("startChannel"),
submitDataBtn = document.getElementById("submitData"),
closeChannelBtn = document.getElementById("closeChannel");

startChannelBtn.onclick = createConnection;
submitDataBtn.onclick = sendData;

function trace(text) {
  console.log((performance.now() / 1000).toFixed(3) + ": " + text);
}

function createConnection() {
  var servers = null;
  window.localPeerConnection = new webkitRTCPeerConnection(servers, {
  	"optional": [{
  		"RtpDataChannels": true
  	}]
  });

  trace("Created local peer connection object localPeerConnection");

  try
  {
    sendChannel = localPeerConnection.createDataChannel("sendDataChannel", {
    	"reliable":false
    });
    trace("Created send data channel");
  } catch (e)
  {
    trace("createDataChannel() failed with exception: " + e.message);
  }

  localPeerConnection.onicecandidate = gotLocalCandidate;
  sendChannel.onopen = handleSendChannelStateChange;
  sendChannel.onclose = handleSendChannelStateChange;

  window.remotePeerConnection = new webkitRTCPeerConnection(servers, {
  	"optional": [{
  		"RtpDataChannels": true
  	}]
  });

  trace("Created remote peer connection object remotePeerConnection");

  remotePeerConnection.onicecandidate = gotRemoteIceCandidate;
  remotePeerConnection.ondatachannel = gotReceiveChannel;

  localPeerConnection.createOffer(gotLocalDescription);
  startChannelBtn.disabled = true;
  closeChannelBtn.disabled = false;
}

function sendData() {
  var data = document.getElementById("sendingData").value;
  sendChannel.send(data);
  trace("Sent data: " + data);
}

function closeDataChannels() {
  trace("Closing data channels");

  sendChannel.close();
  trace("Closed data channel with label: " + sendChannel.label);

  receiveChannel.close();
  trace("Closed data channel with label: " + receiveChannel.label);

  localPeerConnection.close();
  remotePeerConnection.close();
  
  localPeerConnection = null;
  remotePeerConnection = null;
  trace("Closed peer connections");
  
  startChannelBtn.disabled = false;
  closeChannelBtn.disabled = true;
}

function gotLocalDescription(desc) {
  localPeerConnection.setLocalDescription(desc);
  trace("Offer from localPeerConnection \n" + desc.sdp);

  remotePeerConnection.setRemoteDescription(desc);
  remotePeerConnection.createAnswer(gotRemoteDescription);
}

function gotRemoteDescription(desc) {
  remotePeerConnection.setLocalDescription(desc);
  trace("Answer from remotePeerConnection \n" + desc.sdp);
  localPeerConnection.setRemoteDescription(desc);
}

function gotLocalCandidate(event) {
  trace("Local ice callback");
  if (event.candidate)
  {
    remotePeerConnection.addIceCandidate(event.candidate);
    trace("Local ICE candidate: \n" + event.candidate.candidate);
  }
}

function gotRemoteIceCandidate(event) {
  trace("Remote ice callback");
  if (event.candidate)
  {
    localPeerConnection.addIceCandidate(event.candidate);
    trace("Remote ICE candidate: \n" + event.candidate.candidate);
  }
}

function gotReceiveChannel(event) {
  trace("Receive channel callback");
  receiveChannel = event.channel;
  receiveChannel.onmessage = handleMessage;
  receiveChannel.onopen = handleReceiveChannelStateChange;
  receiveChannel.onclose = handleReceiveChannelStateChange;
}

function handleMessage(event) {
  trace("Received message: " + event.data);
  document.getElementById("receivedData").value = event.data;
}

function handleSendChannelStateChange() {
  var readyState = sendChannel.readyState;
  trace("Send channel state is: " + readyState);
  
  if (readyState == "open")
  {
    submitDataBtn.disabled = false;
    closeChannelBtn.disabled = false;
  } else
  {
    submitDataBtn.disabled = true;
    closeChannelBtn.disabled = true;
  }
}

function handleReceiveChannelStateChange() {
  var readyState = receiveChannel.readyState;
  trace("Receive channel state is: " + readyState);
}