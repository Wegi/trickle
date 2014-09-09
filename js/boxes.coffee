baseZIndex = 50
numBoxes = 0
configDialogue = "#config-dialogue"
loaded_modules = { }
global.loaded_modules = loaded_modules

# Make boxes draggable and resizable and snap them to other boxes
$("#new-box").click ->
    defaultContent = """
        <div class='draggable ui-widget-content box box-modules' id='box-#{numBoxes}' style='z-index: #{baseZIndex + numBoxes}'>
            <div class='box-control'>
                <span id='box-control-button-#{numBoxes}' class='glyphicon glyphicon-cog glyphicon-fade box-control-button'></span>
            </div>
            <div class='box-content' id='box-content-#{numBoxes}'>
                I am a new Box!<br><br>
                Go and add some modules.<br><br>
                <a id='a-#{numBoxes}' href='#' box-id='#{numBoxes}'><span class='glyphicon glyphicon-plus'></span></a>
            </div>
        </div>
    """

    $("#boxes").append defaultContent
    box = $("#box-#{numBoxes}").draggable(grid: [10, 10]).resizable(grid: 10).center()

    # Show list of Modules
    list "#box-content-#{numBoxes}", "#box-#{numBoxes}"
    $("div#box-content-#{numBoxes} a#a-#{numBoxes}").click ->
        list "#box-content-" + $(this).attr("box-id")

    # Configure mouseclick event on Preference button in box
    $("div.box-control span#box-control-button-#{numBoxes}").click ->
        if $(".control-hidden").css("display") == "inline"
            $(this).parent().parent().css "border", "1px solid #aaa"
            $(".control-hidden").hide "slide", direction: "right"
        else
            $(this).parent().parent().css "border", "1px solid red"
            $(".control-hidden").show "slide", direction: "right"

    numBoxes++


### Show all modules ###
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
list = (boxid, outer_id) ->
    # Header
    content = "<h3 style='padding-bottom: 1em;'>Choose your module</h3>"

    content += "<ul>"
    for module in modules
        if (module.charAt 0) != '.'

            # Assign values from the correlated config.json
            config = load_conf path.join(modpath, module)

            content += "<li class='module-entry'><a class='module-single' href='#' name='#{module}'"

            if config
                name   = config.name
                bcolor = config.color
                icon   = path.join modpath, module, config.icon

            if bcolor != "" && bcolor
                content += " style='background-color: #{bcolor};'"

            content += ">"

            if icon then content += "<img class='icon' src='#{icon}' alt='#{module}'> "

            if name != "" && name
                content += "#{name}</a></li>"
            else
                content += "#{module}</a></li>"

    content += "</ul>"

    # Open Config Dialogue with content
    $(configDialogue).lightbox_me().html content

    # Add listener
    $(".module-single").click ->
        load_module $(this).attr("name"), boxid, outer_id


# Get into the module and look for config.json
load_module = (modname, boxid, outer_id) ->
    moddir = path.join(modpath, modname)
    config = load_conf moddir

    #tell core that you loaded module
    if not loaded_modules[outer_id]
        loaded_modules[outer_id] = [ ]
    loaded_modules[outer_id].push modname

    if config
        # Take hook and require it. This should be in a different function
        mod = require("./" + path.join(moddir, path.basename(config.hook, path.extname(config.hook))))

        # Load module
        mod boxid, configDialogue, session


# Load config of given module
load_conf = (moddir) ->
    try
        config = fs.readFileSync path.join(moddir, "config.json"), "utf8"
    catch e
        config = null
    return JSON.parse(config)


# Center boxes in window, use it with $("path").center()
$.fn.center = ->
    @css "position", "absolute"
    @css "top", Math.max(0, (($(window).height() - $(this).outerHeight()) / 2) + $(window).scrollTop()) + "px"
    @css "left", Math.max(0, (($(window).width() - $(this).outerWidth()) / 2) + $(window).scrollLeft()) + "px"
    this
