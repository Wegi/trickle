baseZIndex = 50
numBoxes = 0
session = {}

# Make boxes draggable and resizable and snap them to other boxes
$("#new-box").click ->
    defaultContent = """
        <div class='draggable ui-widget-content' id='box-#{numBoxes}' style='z-index: #{baseZIndex + numBoxes}'>
            <div class='box-content' id='box-content-#{numBoxes}'>
                I am a new Box!<br><br>
                Go and add some modules.<br><br>
                <a id='a-#{numBoxes}' href='#' box-id='#{numBoxes}'><span class='glyphicon glyphicon-plus'></span></a>
            </div>
        </div>
    """
    root.session.foo = "foo"
    $("#boxes").append defaultContent
    $("#box-#{numBoxes}").draggable(snap: true).resizable()
    $("#box-#{numBoxes}").center()

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
    content = "<ul>"
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


# Center boxes, use it with $("path").center()
jQuery.fn.center = ->
    @css "position", "absolute"
    @css "top", Math.max(0, (($(window).height() - $(this).outerHeight()) / 2) + $(window).scrollTop()) + "px"
    @css "left", Math.max(0, (($(window).width() - $(this).outerWidth()) / 2) + $(window).scrollLeft()) + "px"
    this
