// Generated by CoffeeScript 1.8.0
var numBoxes, root;

root = typeof exports !== "undefined" && exports !== null ? exports : this;

numBoxes = 0;

$(function() {
  $("#new-box").click(function() {
    $("#boxes").append("<div class='draggable ui-widget-content' id='box-" + numBoxes + "'>I am a new Box! Go and add some modules.</div>");
    $("#box-" + numBoxes).draggable().resizable();
    root.toggleSidebar();
    numBoxes++;
  });
});
