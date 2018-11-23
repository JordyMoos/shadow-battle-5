'use strict';

import "./static/css/style.css";
const {Elm} = require('./elm/Main.elm');

let app = null;

try {
  app = Elm.Main.init({
    node: document.getElementById('elm')
  });

  console.log('Response from init:');
  console.log(app);

} catch (e) {
  console.log('Error caught:');
  console.dir(e);
  document.getElementById('elm').innerText = 'Error: ' + e.message;
}

try {
  let socket = new WebSocket("ws://localhost:3030ll/ws");
  socket.onerror = function(event) {
    console.log('WebSocket error:');
    console.log(event);
  };

  socket.onopen = function(event) {
    console.log('WebSocket open:');
    console.log(event);
  };

  socket.onclose = function(event) {
    console.log('WebSocket close:');
    console.log(event);
  };

  socket.onmessage = function(event) {
    console.log('WebSocket message:');
    console.log(event);
  };
} catch (e) {
  console.log('Websocket error caught:');
  console.dir(e);
  document.getElementById('websocket-notification').innerText = 'Error: ' + e.message;
}