// Generated by CoffeeScript 1.8.0
var baseZIndex, configDialogue, fs, list, load_conf, load_module, modpath, modules, numBoxes, path, session;

baseZIndex = 50;

numBoxes = 0;

session = {};

configDialogue = "#config-dialogue";

$("#new-box").click(function() {
  var defaultContent;
  defaultContent = "<div class='draggable ui-widget-content box' id='box-" + numBoxes + "' style='z-index: " + (baseZIndex + numBoxes) + "'>\n    <div class='box-content' id='box-content-" + numBoxes + "'>\n        I am a new Box!<br><br>\n        Go and add some modules.<br><br>\n        <a id='a-" + numBoxes + "' href='#' box-id='" + numBoxes + "'><span class='glyphicon glyphicon-plus'></span></a>\n    </div>\n</div>";
  $("#boxes").append(defaultContent);
  $("#box-" + numBoxes).draggable({
    grid: [10, 10]
  }).resizable({
    grid: 10
  }).center();
  list("#box-content-" + numBoxes);
  $("div#box-content-" + numBoxes + " a#a-" + numBoxes).click(function() {
    return list("#box-content-" + $(this).attr("box-id"));
  });
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
  var bcolor, config, content, icon, module, name, _i, _len;
  content = "<h3 style='padding-bottom: 1em;'>Choose your module</h3>";
  content += "<ul>";
  for (_i = 0, _len = modules.length; _i < _len; _i++) {
    module = modules[_i];
    if ((module.charAt(0)) !== '.') {
      config = load_conf(path.join(modpath, module));
      content += "<li class='module-entry'><a class='module-single' href='#' name='" + module + "' ";
      if (config) {
        name = config.name;
        bcolor = config.color;
        icon = path.join(modpath, module, config.icon);
      }
      if (bcolor !== "" && bcolor) {
        content += "style='background-color: " + bcolor + ";'";
      }
      content += ">";
      if (icon) {
        content += "<img class='icon' src='" + icon + "' alt='" + module + "'> ";
      }
      if (name !== "" && name) {
        content += "" + name + "</a></li>";
      } else {
        content += "" + module + "</a></li>";
      }
    }
  }
  content += "</ul>";
  $(configDialogue).lightbox_me().html(content);
  return $(".module-single").click(function() {
    return load_module($(this).attr("name"), boxid);
  });
};

load_module = function(modname, boxid) {
  var config, mod, moddir;
  moddir = path.join(modpath, modname);
  config = load_conf(moddir);
  if (config) {
    mod = require("./" + path.join(moddir, path.basename(config.hook, path.extname(config.hook))));
    return mod(boxid, configDialogue, session);
  }
};

load_conf = function(moddir) {
  var config, e;
  try {
    config = fs.readFileSync(path.join(moddir, "config.json"), "utf8");
  } catch (_error) {
    e = _error;
    config = null;
  }
  return JSON.parse(config);
};

$.fn.center = function() {
  this.css("position", "absolute");
  this.css("top", Math.max(0, (($(window).height() - $(this).outerHeight()) / 2) + $(window).scrollTop()) + "px");
  this.css("left", Math.max(0, (($(window).width() - $(this).outerWidth()) / 2) + $(window).scrollLeft()) + "px");
  return this;
};
