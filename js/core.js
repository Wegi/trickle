
/* Require modules */

(function() {
  var baseZIndex, boxName, child_content, configDialogue, createBox, data, fs, getNextNum, getNumFromName, gui, home_path, init_done, list, load_conf, load_module, modpath, module, modules, num, path, selectedBox, session, toggle_highlighted_boxes, value, win, _i, _len, _ref, _ref1,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  fs = require("fs");

  gui = require("nw.gui");

  path = require("path");


  /* Core Logic Preparations */

  init_done = false;

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
    box = $("#box-" + numBoxes).draggable({
      grid: [10, 10]
    }).resizable({
      grid: 10
    }).center();
    if (init_done) {
      list("#box-content-" + numBoxes, "#box-" + numBoxes);
    }
    $("div.box-control span#box-control-button-" + numBoxes).click(function() {
      var thisBox;
      thisBox = "#" + $(this).parent().parent().prop("id");
      return toggle_highlighted_boxes(thisBox);
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
    var contentDiv;
    contentDiv = "#" + $(selectedBox).children("div.box-content").prop("id");
    return list(contentDiv, selectedBox);
  });

  $("#control-menu-remove").click(function() {});

  $("#control-menu-config").click(function() {});

  $("#control-menu-delete").click(function() {});


  /* END Define Listeners */

  modpath = "./modules";

  modules = [];

  fs.readdir(modpath, function(err, files) {
    if (err) {
      throw err;
    }
    return modules = files;
  });

  toggle_highlighted_boxes = function(thisBox) {
    var animationDirection, highlightedBorder, normalBorder;
    normalBorder = "1px solid #aaa";
    highlightedBorder = "1px solid red";
    animationDirection = "down";
    if (!selectedBox) {
      selectedBox = thisBox;
      $(selectedBox).css("border", highlightedBorder);
      return $("#control-standard").hide("slide", {
        direction: animationDirection
      }, function() {
        return $("#control-edit-box").show("slide", {
          direction: animationDirection
        });
      });
    } else if (selectedBox === thisBox) {
      $(selectedBox).css("border", normalBorder);
      $("#control-edit-box").hide("slide", {
        direction: animationDirection
      }, function() {
        return $("#control-standard").show("slide", {
          direction: animationDirection
        });
      });
      return selectedBox = null;
    } else {
      $(selectedBox).css("border", normalBorder);
      $(thisBox).css("border", highlightedBorder);
      return selectedBox = thisBox;
    }
  };

  list = function(boxid, outer_id) {
    var bcolor, config, content, icon, icon_fa, module, name, _i, _len;
    content = "<h3 style='padding-bottom: 1em;'>Choose your module</h3>";
    content += "<ul>";
    for (_i = 0, _len = modules.length; _i < _len; _i++) {
      module = modules[_i];
      if ((module.charAt(0)) !== '.') {
        config = load_conf(path.join(modpath, module));
        content += "<li class='module-entry'><a class='module-single opacity-trans' href='#' id='" + module + "' name='" + module + "'";
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
          content += "<img class='icon' src='" + icon + "' alt='" + module + "'>&nbsp;";
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
      return load_module($(this).attr("name"), boxid, outer_id);
    });
  };

  load_module = function(modname, boxid, outer_id) {
    var config, mod, moddir;
    if (session.boxes[outer_id].loaded_modules) {
      if (__indexOf.call(session.boxes[outer_id].loaded_modules, modname) >= 0) {
        return;
      }
    }
    moddir = path.join(modpath, modname);
    config = load_conf(moddir);
    if (config) {
      mod = require("./" + path.join(moddir, path.basename(config.hook, path.extname(config.hook))));
      mod.init(boxid, configDialogue, session);
      if (!session.boxes[outer_id].loaded_modules) {
        session.boxes[outer_id].loaded_modules = [];
      }
      if (__indexOf.call(session.boxes[outer_id].loaded_modules, modname) < 0) {
        return session.boxes[outer_id].loaded_modules.push(modname);
      }
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
    $(boxName).css('heigth', value.size.height);
    $(boxName).css('width', value.size.width);
    if (value.loaded_modules) {
      _ref1 = value.loaded_modules;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        module = _ref1[_i];
        load_module(module, child_content, boxName);
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

}).call(this);
