numBoxes = 0
session = {}

# Make boxes draggable and resizable and snap them to other boxes
$("#new-box").click ->
    defaultContent = """
        <div class='draggable ui-widget-content' id='box-#{numBoxes}'>
            <div id='box-content-#{numBoxes}'>
                I am a new Box!<br><br>
                Go and add some modules.<br><br>
                <a id='a-#{numBoxes}' href='#' box-id='#{numBoxes}'><span class='glyphicon glyphicon-plus'></span></a>
            </div>
        </div>
    """
    $("#boxes").append defaultContent
    $("#box-#{numBoxes}").draggable(snap: true).resizable()

    # Show list of Modules
    $("div#box-content-#{numBoxes} a#a-#{numBoxes}").click ->
        list "#box-content-" + $(this).attr("box-id")

    # Close Sidebar and prepare for next box to add
    sidemenu.close()
    numBoxes++


### Show all modules ###
# TODO move this into modules.coffee and load it properly
path = require "path"
fs = require "fs"

# Path to the trickle-modules
modpath = "./modules"
modules = []

# List all modules in path
# TODO Check for invalid files
fs.readdir modpath, (err, files) ->
    throw err if err
    modules = files


# List all modules
list = (boxid) ->
    content = "<ul class='module-list'>"
    for module in modules
        content += "<li><a class='module-single' href='#' name='#{module}'>#{module}</a></li>"
    content += "</ul>"

    # Print content
    $(boxid).html content

    # Add listener
    $(".module-single").click ->
        load_module $(this).attr("name"), boxid


# Get into the module and look for config.json
load_module = (modname, boxid) ->
    moddir = path.join(modpath, modname)
    fs.readFile path.join(moddir, "config.json"), "utf8", (err, config) ->
        if err
            console.log "Error: " + err
            return
        config = JSON.parse(config)

        # Take hook and require it. This should be in a different function
        mod = require("./" + path.join(moddir, path.basename(config.hook, path.extname(config.hook))))
        mod boxid, session
