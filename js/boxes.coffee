numBoxes = 0
session = {}

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
        list "#" + $(this).attr("id")
        return

    return


### Show all modules ###
# TODO move this into modules.coffee and load it properly

# Path to the trickle-modules
path = "./modules"
modules = []

# List all modules in path
# TODO Check for invalid files
fs = require("fs")
fs.readdir path, (err, files) ->
    throw err if err
    modules = files
    return


# List all modules
list = (boxid) ->
    content = "<ul>"
    for module in modules
        content += "<li><a class='module_single' href='#' name='#{module}'>#{module}</a></li>"
    content += "</ul>"

    # Print content
    $(boxid).html content

    # Add listener
    $(".module_single").click ->
        get_config $(this).attr("name")
        return
    return

# Get into the module and look for config.json
# TODO use PATH module
get_config = (modname) ->
    moddir = path + "/" + modname + "/"
    fs.readFile moddir + "config.json", "utf8", (err, data) ->
        if err
            console.log "Error: " + err
            return
        data = JSON.parse(data)
        mod = require(moddir + data.hook[..-4])
        mod "#box", {}
        return
    return
