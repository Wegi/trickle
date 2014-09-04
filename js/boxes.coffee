numBoxes = 0

# Make boxes draggable and resizable and snap them to other boxes
$("#new-box").click ->
    defaultContent = "
        <div class='draggable ui-widget-content module_list' id='box-#{numBoxes}'>
            I am a new Box!<br><br>
            Go and add some modules.<br><br>
            <a class='' href='#'><span class='glyphicon glyphicon-plus'></span></a>
        </div>
    "
    $("#boxes").append defaultContent
    $("#box-#{numBoxes}").draggable(snap: true).resizable()

    sidemenu.close()
    numBoxes++

    # Show list of Modules
    $(".module_list").click ->
        list "##{$(this).attr 'id'}"
        return
    return


### Show all modules ###
# TODO move this into modules.coffee and load it properly
dir = require "node-dir"

# Path to the trickle-modules
path = "modules"
modules = []

# List all modules in path
dir.subdirs path, (err, subdirs) ->
    if not err
        modules = subdirs
    return

# List all modules
list = (boxid) ->
    content = "<ul>"
    for module in modules
        content += "<li>#{module}</li>"
    content += "</ul>"
    $(boxid).html content
    return
