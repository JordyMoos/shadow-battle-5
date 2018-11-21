'use strict';

const {Elm} = require('./elm/Main.elm');
const {PortFunnel} = require('./static/js/PortFunnel.js');

try {
  let app = Elm.Main.init({
    node: document.getElementById('elm'),
    flags: {}
  });

  console.log('Response from init:');
  console.log(app);

  PortFunnel.subscribe(app, {
    modules: ['WebSocket'],
    moduleDirectory: './static/js/PortFunnel',
    portNames: ['cmdPort', 'subPort']
  });
} catch (e) {
  console.log('Error caught:');
  console.dir(e);
  document.getElementsByTagName('body')[0].innerText = 'Error: ' + e.message;
}
