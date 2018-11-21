'use strict';

const {Elm} = require('./elm/Main.elm');

try {
  let app = Elm.Main.init({
    node: document.getElementById('elm'),
    flags: {}
  });
} catch (e) {
  console.dir(e);
  document.getElementById('elm').innerText = 'Error: ' + e.message;
}
