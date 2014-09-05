// Generated by CoffeeScript 1.8.0

/*
    Trickle Core
 */

/* Require modules */
var fs, gui, session, win;

fs = require("fs");


/* Global variables */

session = {};

gui = require("nw.gui");

win = gui.Window.get();

fs.readFile('data/session.json', "utf8", function(err, data) {
  if (err) {
    return console.error(err);
  } else {
    return session = JSON.parse(data);
  }
});

win.on("close", function() {
  this.hide();
  return fs.writeFile("data/session.json", JSON.stringify(session), function(err) {
    if (err) {
      throw err;
    }
    return gui.App.quit();
  });
});
