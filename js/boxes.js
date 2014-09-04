// Generated by CoffeeScript 1.8.0
var boxes, numBoxes;

boxes = typeof exports !== "undefined" && exports !== null ? exports : this;

numBoxes = 0;

$(function() {
  $("#new-box").click(function() {
    var defaultContent;
    defaultContent = "<div class='draggable ui-widget-content' id='box-" + numBoxes + "'> I am a new Box!<br><br> Go and add some modules.<br><br> <a class='module_list' href='#'><span class='glyphicon glyphicon-plus'></span></a> </div>";
    $("#boxes").append(defaultContent);
    $("#box-" + numBoxes).draggable({
      snap: true
    }).resizable();
    sidemenu.close();
    numBoxes++;
    $(".module_list").click(function() {
      console.log("To be implemented");
    });
  });
});
