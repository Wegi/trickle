// Generated by CoffeeScript 1.8.0

/* Require modules */
var animateBoxes, baseZIndex, boxName, child_content, configDialogue, config_dialogue_box_remove, config_dialogue_edit, config_dialogue_module_add, config_dialogue_module_removal, control_menu_show_edit_hide_standard, control_menu_show_standard_hide_edit, createBox, create_module_list_items, data, destroy_module, fs, getNextNum, getNumFromName, gui, home_path, init_done, load_conf, load_module, modpath, module, modules, num, path, selectedBox, session, showConfig, toggle_control_menu, value, win, _i, _len, _ref, _ref1,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

fs = require("fs");

gui = require("nw.gui");

path = require("path");


/* Core Logic Preparations */

init_done = false;

showConfig = false;

animateBoxes = false;

home_path = process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE;

if (!fs.existsSync(home_path + '/.trickle')) {
  fs.mkdirSync(home_path + '/.trickle');
}

if (!fs.existsSync(home_path + '/.trickle/session.json')) {
  fs.writeFileSync(home_path + '/.trickle/session.json', '{ }');
}

try {
  data = fs.readFileSync(home_path + '/.trickle/session.json', "utf8");
  session = JSON.parse(data);
} catch (_error) {
  console.log("gotcha buddy");
  session = {
    boxes: {}
  };
}


/* General Commands */

$(function() {
  return $("#config-tabs").tabs();
});


/* Boxes Logic */

baseZIndex = 50;

configDialogue = "#config-dialogue";

selectedBox = "";

if (!session.present_boxes) {
  session.present_boxes = [];
}

getNextNum = function() {
  var num;
  num = 0;
  while (__indexOf.call(session.present_boxes, num) >= 0) {
    num++;
  }
  return num;
};

$.fn.center = function() {
  this.css("position", "absolute");
  this.css("top", Math.max(0, (($(window).height() - $(this).outerHeight()) / 2) + $(window).scrollTop()) + "px");
  this.css("left", Math.max(0, (($(window).width() - $(this).outerWidth()) / 2) + $(window).scrollLeft()) + "px");
  return this;
};

createBox = function(numBoxes) {
  var box, defaultContent;
  if (!session.boxes) {
    session.boxes = {};
  }
  if (!session.boxes["#box-" + numBoxes]) {
    session.boxes["#box-" + numBoxes] = {};
  }
  defaultContent = "<div class='draggable ui-widget-content box' id='box-" + numBoxes + "' style='z-index: " + (baseZIndex + numBoxes) + "'>\n    <div class='box-control'>\n        <span id='box-control-button-" + numBoxes + "' class='glyphicon glyphicon-cog glyphicon-fade box-control-button'></span>\n    </div>\n    <div class='box-content' id='box-content-" + numBoxes + "'></div>\n</div>";
  $("#boxes").append(defaultContent);
  $("#config-tabs").append("<div id='config-box-" + numBoxes + "-tabs'><ul></ul></div>");
  box = $("#box-" + numBoxes).draggable({
    grid: [10, 10]
  }).resizable({
    grid: 10
  }).center();
  if (init_done) {
    config_dialogue_module_add("#box-content-" + numBoxes, "#box-" + numBoxes);
  }
  $("div.box-control span#box-control-button-" + numBoxes).click(function() {
    var thisBox;
    thisBox = "#" + $(this).parent().parent().prop("id");
    return toggle_control_menu(thisBox);
  });
  if (__indexOf.call(session.present_boxes, numBoxes) < 0) {
    return session.present_boxes.push(numBoxes);
  }
};


/* Define Listeners */

$("#new-box").click(function() {
  var num;
  num = getNextNum();
  return createBox(num);
});

$("#control-menu-add").click(function() {
  var boxContentId;
  if (selectedBox) {
    boxContentId = "#" + $(selectedBox).children("div.box-content").prop("id");
    return config_dialogue_module_add(boxContentId, selectedBox);
  } else {
    return toggle_control_menu(void 0);
  }
});

$("#control-menu-remove").click(function() {
  var boxContentId;
  if (selectedBox) {
    boxContentId = "#" + $(selectedBox).children("div.box-content").prop("id");
    return config_dialogue_module_removal(boxContentId, selectedBox);
  } else {
    return toggle_control_menu(void 0);
  }
});

$("#control-menu-config").click(function() {
  var boxContentId;
  if (selectedBox) {
    showConfig = true;
    boxContentId = "#" + $(selectedBox).children("div.box-content").prop("id");
    return config_dialogue_edit(boxContentId, selectedBox);
  } else {
    return toggle_control_menu(void 0);
  }
});

$("#control-menu-delete").click(function() {
  var boxContentId;
  if (selectedBox) {
    boxContentId = "#" + $(selectedBox).children("div.box-content").prop("id");
    return config_dialogue_box_remove(boxContentId, selectedBox);
  } else {
    return toggle_control_menu(void 0);
  }
});

$("#control-menu-close").click(function() {
  $("#config-box").trigger("close");
  return toggle_control_menu(selectedBox);
});


/* END Define Listeners */

modpath = "./modules";

modules = [];

fs.readdir(modpath, function(err, files) {
  if (err) {
    throw err;
  }
  return modules = files;
});


/* Configure Control Menu */

control_menu_show_edit_hide_standard = function(animationDirection) {
  animateBoxes = true;
  return $("#control-standard").hide("slide", {
    direction: animationDirection
  }, function() {
    return $("#control-edit-box").show("slide", {
      direction: animationDirection
    }, function() {
      return animateBoxes = false;
    });
  });
};

control_menu_show_standard_hide_edit = function(animationDirection) {
  animateBoxes = true;
  return $("#control-edit-box").hide("slide", {
    direction: animationDirection
  }, function() {
    return $("#control-standard").show("slide", {
      direction: animationDirection
    }, function() {
      return animateBoxes = false;
    });
  });
};

toggle_control_menu = function(thisBox) {
  var animationDirection, highlightedBorder, normalBorder;
  normalBorder = "1px solid #aaa";
  highlightedBorder = "1px solid red";
  animationDirection = "down";
  if (!selectedBox) {
    selectedBox = thisBox;
    $(selectedBox).css("border", highlightedBorder);
    if (!animateBoxes) {
      return control_menu_show_edit_hide_standard(animationDirection);
    }
  } else if (selectedBox === thisBox) {
    $(selectedBox).css("border", normalBorder);
    if (!animateBoxes) {
      control_menu_show_standard_hide_edit(animationDirection);
    }
    return selectedBox = null;
  } else {
    $(selectedBox).css("border", normalBorder);
    $(thisBox).css("border", highlightedBorder);
    return selectedBox = thisBox;
  }
};


/* END Configure Control Menu */


/* Config Dialogue Logic */

config_dialogue_module_add = function(boxContentId, boxOuterId) {
  var content, module, _i, _len;
  content = "<h3>Choose your module</h3>";
  content += "<ul>";
  for (_i = 0, _len = modules.length; _i < _len; _i++) {
    module = modules[_i];
    if ((module.charAt(0)) !== '.') {
      content += create_module_list_items(module);
    }
  }
  content += "</ul>";
  $(configDialogue).lightbox_me().html(content);
  return $(".module-single").click(function() {
    var _ref;
    if (session.boxes[boxOuterId].loaded_modules) {
      if (_ref = $(this).attr("name"), __indexOf.call(session.boxes[boxOuterId].loaded_modules, _ref) >= 0) {
        return;
      }
    }
    return load_module($(this).attr("name"), boxContentId, boxOuterId, configDialogue);
  });
};

config_dialogue_edit = function(boxContentId, boxOuterId) {
  var closeConfigDialogue, module, selectConfigBoxTabs, tempLoadedModules, _i, _len;
  tempLoadedModules = session.boxes[boxOuterId].loaded_modules;
  if (!tempLoadedModules || tempLoadedModules.length === 0) {
    $("#config-empty").lightbox_me();
    closeConfigDialogue = function() {
      return $("#config-empty").trigger("close");
    };
    setTimeout(closeConfigDialogue, 3000);
  } else {
    for (_i = 0, _len = modules.length; _i < _len; _i++) {
      module = modules[_i];
      if ((module.charAt(0)) !== '.') {
        load_module(module, boxContentId, boxOuterId, "#config-" + boxOuterId.slice(1) + "-" + module);
      }
    }
    selectConfigBoxTabs = "#config-" + boxOuterId.slice(1) + "-tabs";
    $(selectConfigBoxTabs).tabs().lightbox_me();
  }
  return showConfig = false;
};

config_dialogue_module_removal = function(boxContentId, boxOuterId) {
  var boxModules, closeConfigDialogue, configBox, content, module, _i, _len;
  configBox = "#config-box";
  boxModules = session.boxes[selectedBox].loaded_modules;
  content = "<h3>Remove modules from box</h3>";
  content += "<div><ul id='config-box-list-modules'>";
  if (boxModules) {
    for (_i = 0, _len = boxModules.length; _i < _len; _i++) {
      module = boxModules[_i];
      content += create_module_list_items(module);
    }
    content += "</ul></div>";
    $("#config-box-list-modules").selectable();
    $(configBox).lightbox_me().html(content);
    return $(".module-single").click(function() {
      var closeConfigDialogue;
      destroy_module($(this).attr("name"), boxContentId, boxOuterId);
      $(configBox).html("<span class='btn'><span class='glyphicon glyphicon-ok'></span> Module successfully removed.</span>");
      closeConfigDialogue = function() {
        return $(configBox).trigger("close");
      };
      return setTimeout(closeConfigDialogue, 3000);
    });
  } else {
    $("#config-empty").lightbox_me();
    closeConfigDialogue = function() {
      return $("#config-empty").trigger("close");
    };
    return setTimeout(closeConfigDialogue, 3000);
  }
};

config_dialogue_box_remove = function(boxContentId, boxOuterId) {
  var boxModules, configBox, content;
  configBox = "#config-box";
  if (session.boxes[selectedBox].loaded_modules) {
    boxModules = session.boxes[selectedBox].loaded_modules;
  } else {
    boxModules = {};
  }
  content = "<h3>Do you really want to delete this box?</h3>";
  content += "<button class='btn btn-default' id='box-remove-yes'>Yes</button>&nbsp;";
  content += "<button class='btn btn-default' id='box-remove-no'>No</button>";
  $(configBox).lightbox_me().html(content);
  $("#box-remove-yes").click(function() {
    var closeConfigDialogue, module, _i, _len;
    for (_i = 0, _len = boxModules.length; _i < _len; _i++) {
      module = boxModules[_i];
      destroy_module(module, boxContentId, boxOuterId);
    }
    delete session.boxes[selectedBox];
    $(selectedBox).remove();
    $("#config-" + boxOuterId.slice(1)).remove();
    toggle_control_menu(selectedBox);
    selectedBox = void 0;
    $(configBox).html("<span class='btn'><span class='glyphicon glyphicon-ok'></span> Box successfully removed.</span>");
    closeConfigDialogue = function() {
      return $(configBox).trigger("close");
    };
    return setTimeout(closeConfigDialogue, 3000);
  });
  return $("#box-remove-no").click(function() {
    return $(configBox).trigger("close");
  });
};

create_module_list_items = function(module) {
  var bcolor, config, content, icon, icon_fa, name;
  config = load_conf(path.join(modpath, module));
  content = "<li class='module-entry'><a class='module-single' href='#' name='" + module + "'";
  if (config) {
    name = config.name;
    bcolor = config.color;
    icon = path.join(modpath, module, config.icon);
    icon_fa = config.icon_fa;
  }
  if (bcolor !== "" && bcolor) {
    content += " style='background-color: " + bcolor + ";'";
  }
  content += ">";
  if (icon_fa) {
    content += "<span class='fa " + icon_fa + "'></span>&nbsp;";
  } else if (icon) {
    content += "<img class='icon' src='" + icon + "' alt='" + name + "' onerror='this.remove()'>";
  }
  content += "" + name + "</a></li>";
  return content;
};

load_module = function(modname, boxContentId, boxOuterId, configWindow) {
  var config, mod, moddir, selectConfigBox;
  moddir = path.join(modpath, modname);
  config = load_conf(moddir);
  if (config) {
    mod = require("./" + path.join(moddir, path.basename(config.hook, path.extname(config.hook))));
    mod.init(boxContentId, configWindow, session);
    if (!session.boxes[boxOuterId].loaded_modules) {
      session.boxes[boxOuterId].loaded_modules = [];
    }
    if (__indexOf.call(session.boxes[boxOuterId].loaded_modules, modname) < 0) {
      session.boxes[boxOuterId].loaded_modules.push(modname);
    }
    if (!showConfig) {
      selectConfigBox = "#config-" + boxOuterId.slice(1);
      $(selectConfigBox + "-tabs ul").append("<li><a href='" + selectConfigBox + "-" + modname + "'>" + config.name + "</a></li>");
      return $(selectConfigBox + "-tabs").append("<div id='" + selectConfigBox.slice(1) + ("-" + modname + "'></div>"));
    }
  }
};

destroy_module = function(modname, boxContentId, boxOuterId) {
  var config, i, mod, moddir;
  moddir = path.join(modpath, modname);
  config = load_conf(moddir);
  if (config) {
    mod = require("./" + path.join(moddir, path.basename(config.hook, path.extname(config.hook))));
    mod.destroy(boxOuterId, boxContentId, session);
    i = session.boxes[boxOuterId].loaded_modules.indexOf("twitter");
    if (i !== -1) {
      return session.boxes[boxOuterId].loaded_modules.splice(i, 1);
    }
  }
};

load_conf = function(moddir) {
  var config, e, result;
  try {
    config = fs.readFileSync(path.join(moddir, "config.json"), "utf8");
    result = JSON.parse(config);
  } catch (_error) {
    e = _error;
    result = "";
  }
  return result;
};


/* END Config Dialogue Logic */


/* Core Logic (Startup and Close) */

getNumFromName = function(name) {
  var pattern;
  pattern = /^#.*-(\d+)$/;
  return Number(name.match(pattern)[1]);
};

_ref = session.boxes;
for (boxName in _ref) {
  value = _ref[boxName];
  child_content = value.content_child;
  num = getNumFromName(boxName);
  createBox(num);
  $(boxName).offset(value.position);
  $(child_content).html(value.content);
  $(boxName).css('height', value.size.height);
  $(boxName).css('width', value.size.width);
  if (value.loaded_modules) {
    _ref1 = value.loaded_modules;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      module = _ref1[_i];
      load_module(module, child_content, boxName, configDialogue);
    }
  }
}

init_done = true;

win = gui.Window.get();

win.on("close", function() {
  var jsonified;
  this.hide();
  if (!session.boxes) {
    session["boxes"] = {};
  }
  $(".box-content").each(function(index) {
    var id, parent_id;
    id = '#' + $(this).prop("id");
    parent_id = '#' + $(id).parent().prop("id");
    if (!session.boxes[parent_id]) {
      session.boxes[parent_id] = {};
    }
    session.boxes[parent_id].content_child = id;
    session.boxes[parent_id].position = $(parent_id).offset();
    session.boxes[parent_id].content = $(id).html();
    return session.boxes[parent_id].size = {
      "height": $(parent_id).height(),
      "width": $(parent_id).width()
    };
  });
  jsonified = JSON.stringify(session, null, 4);
  fs.writeFileSync(home_path + '/.trickle/session.json', jsonified, 'utf8');
  return gui.App.quit();
});


/* END Core Logic (Startup and Close) */
