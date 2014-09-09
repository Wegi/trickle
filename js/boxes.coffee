baseZIndex = 50
numBoxes = 0
session = {}
configDialogue = "#config-dialogue"

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

    $("#boxes").append defaultContent
    $("#box-#{numBoxes}").draggable(grid: [10, 10]).resizable(grid: 10)
    $("#box-#{numBoxes}").center()

    # Show list of Modules
    list "#box-content-#{numBoxes}"
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
    # Header
    content = "<h3 style='padding-bottom: 1em;'>Choose your module</h3>"

    content += "<ul>"
    for module in modules
        if (module.charAt 0) != '.'

            #assign values from the correlated config.json
            try
                config = load_conf path.join(modpath, module)
                name   = config.name
                bcolor = config.color
                icon   = path.join modpath, module, config.icon
            catch e
                console.error e

            content += "<li class='module-entry'><a class='module-single' href='#' name='#{module}' "

            if bcolor != "" then content += "style='background-color: #{bcolor};'"

            content += ">"

            if icon then content += "<img class='icon' src='#{icon}' alt=''> "

            content += "#{module}</a></li>"

    content += "</ul>"

    # Open Config Dialogue
    $(configDialogue).lightbox_me();

    # Print content
    $(configDialogue).html content

    # Add listener
    $(".module-single").click ->
        load_module $(this).attr("name"), boxid


# Get into the module and look for config.json
load_module = (modname, boxid) ->
    moddir = path.join(modpath, modname)
    config = load_conf moddir

    # Take hook and require it. This should be in a different function
    mod = require("./" + path.join(moddir, path.basename(config.hook, path.extname(config.hook))))

    # Load module
    mod boxid, configDialogue, session


# Load config of given module
load_conf = (moddir) ->
    config = fs.readFileSync path.join(moddir, "config.json"), "utf8"
    return JSON.parse config


# Center boxes in window, use it with $("path").center()
$.fn.center = ->
    @css "position", "absolute"
    @css "top", Math.max(0, (($(window).height() - $(this).outerHeight()) / 2) + $(window).scrollTop()) + "px"
    @css "left", Math.max(0, (($(window).width() - $(this).outerWidth()) / 2) + $(window).scrollLeft()) + "px"
    this
