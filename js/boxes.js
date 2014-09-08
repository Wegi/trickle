// Generated by CoffeeScript 1.8.0
var baseZIndex, configDialogue, fs, list, load_module, modpath, modules, numBoxes, path, session;

baseZIndex = 50;

numBoxes = 0;

session = {};

configDialogue = "#config-dialogue";

$("#new-box").click(function() {
  var defaultContent;
  defaultContent = "<div class='draggable ui-widget-content' id='box-" + numBoxes + "' style='z-index: " + (baseZIndex + numBoxes) + "'>\n    <div class='box-content' id='box-content-" + numBoxes + "'>\n        I am a new Box!<br><br>\n        Go and add some modules.<br><br>\n        <a id='a-" + numBoxes + "' href='#' box-id='" + numBoxes + "'><span class='glyphicon glyphicon-plus'></span></a>\n    </div>\n</div>";
  root.session.foo = "foo";
  $("#boxes").append(defaultContent);
  $("#box-" + numBoxes).draggable({
    grid: [10, 10]
  }).resizable({
    grid: 10
  });
  $("#box-" + numBoxes).center();
  list("#box-content-" + numBoxes);
  sidemenu.close();
  return numBoxes++;
});


/* Show all modules */

path = require("path");

fs = require("fs");

modpath = "./modules";

modules = [];

fs.readdir(modpath, function(err, files) {
  if (err) {
    throw err;
  }
  return modules = files;
});

list = function(boxid) {
  var content, module, _i, _len;
  content = "<h3>Choose your modules</h3>";
  content += "<ul>";
  for (_i = 0, _len = modules.length; _i < _len; _i++) {
    module = modules[_i];
    content += "<li><a class='module-single' href='#' name='" + module + "'>" + module + "</a></li>";
  }
  content += "</ul>";
  $(configDialogue).lightbox_me();
  $(configDialogue).html(content);
  return $(".module-single").click(function() {
    return load_module($(this).attr("name"), boxid);
  });
};

load_module = function(modname, boxid) {
  var moddir;
  moddir = path.join(modpath, modname);
  return fs.readFile(path.join(moddir, "config.json"), "utf8", function(err, config) {
    var mod;
    if (err) {
      console.log("Error: " + err);
      return;
    }
    config = JSON.parse(config);
    mod = require("./" + path.join(moddir, path.basename(config.hook, path.extname(config.hook))));
    return mod(boxid, configDialogue, session);
  });
};

$.fn.center = function() {
  this.css("position", "absolute");
  this.css("top", Math.max(0, (($(window).height() - $(this).outerHeight()) / 2) + $(window).scrollTop()) + "px");
  this.css("left", Math.max(0, (($(window).width() - $(this).outerWidth()) / 2) + $(window).scrollLeft()) + "px");
  return this;
};
