############
#    Trickle Core
############

### Require modules ###
fs = require "fs"
gui = require "nw.gui"
path = require "path"

### Core Logic Preparations ###
# Set Startup-Parameters
init_done = false

# Get Home PATH
home_path = process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE

# Check if folder and file are existent and create them if not
if not fs.existsSync(home_path+'/.trickle')
    fs.mkdirSync home_path+'/.trickle'
if not fs.existsSync(home_path+'/.trickle/session.json')
    fs.writeFileSync(home_path+'/.trickle/session.json', '{ }')

# Read session and parse it to the variable
try
    data = fs.readFileSync home_path+'/.trickle/session.json', "utf8"
    session = JSON.parse(data)  # Parse file to session
catch
    console.log "gotcha buddy"
    session =
        boxes: { }

### General Commands ###
showConfig = false
$ ->
    $("#config-tabs").tabs();


### Boxes Logic ###
baseZIndex = 50
configDialogue = "#config-dialogue"
selectedBox = ""
if not session.present_boxes
    session.present_boxes = [ ]

getNextNum = ->
    num = 0
    num++ while num in session.present_boxes
    num

# Center boxes in window, use it with $("path").center()
$.fn.center = ->
    @css "position", "absolute"
    @css "top", Math.max(0, (($(window).height() - $(this).outerHeight()) / 2) + $(window).scrollTop()) + "px"
    @css "left", Math.max(0, (($(window).width() - $(this).outerWidth()) / 2) + $(window).scrollLeft()) + "px"
    this

# Make boxes draggable and resizable
createBox = (numBoxes) ->
    if not session.boxes
        session.boxes = { }
    if not session.boxes["#box-#{numBoxes}"]
        session.boxes["#box-#{numBoxes}"] = { }
    defaultContent = """
        <div class='draggable ui-widget-content box' id='box-#{numBoxes}' style='z-index: #{baseZIndex + numBoxes}'>
            <div class='box-control'>
                <span id='box-control-button-#{numBoxes}' class='glyphicon glyphicon-cog glyphicon-fade box-control-button'></span>
            </div>
            <div class='box-content' id='box-content-#{numBoxes}'></div>
        </div>
    """

    # Append box to boxes-div
    $("#boxes").append defaultContent
    $("#config-tabs").append "<div id='config-box-#{numBoxes}'></div>"

    # Set options to each box
    box = $("#box-#{numBoxes}").draggable(grid: [10, 10]).resizable(grid: 10).center()

    # Show list of Modules (Only do if init is done)
    if init_done
        config_dialogue_module_add "#box-content-#{numBoxes}", "#box-#{numBoxes}"

    # Configure mouseclick event on Preference button in box
    $("div.box-control span#box-control-button-#{numBoxes}").click ->
        # Set selected Box
        thisBox = "#" + $(this).parent().parent().prop "id"
        toggle_highlighted_boxes thisBox

    if numBoxes not in session.present_boxes
        session.present_boxes.push numBoxes


### Define Listeners ###
$("#new-box").click ->
    num = getNextNum()
    createBox num

# Add new Module to Box
$("#control-menu-add").click ->
    boxContentId = "#" + $(selectedBox).children("div.box-content").prop "id"
    config_dialogue_module_add boxContentId, selectedBox

# Show list of Modules, remove selected ones
$("#control-menu-remove").click ->
    boxContentId = "#" + $(selectedBox).children("div.box-content").prop "id"
    config_dialogue_module_removal boxContentId, selectedBox

# Open configuration of Box containing all Modules to config
$("#control-menu-config").click ->
    showConfig = true
    boxContentId = "#" + $(selectedBox).children("div.box-content").prop "id"
    config_dialogue_edit boxContentId, selectedBox

# Delete complete Box
$("#control-menu-delete").click ->
    boxContentId = "#" + $(selectedBox).children("div.box-content").prop "id"
    config_dialogue_box_remove boxContentId, selectedBox

# Clicking on preferences icon closes menu
$("#control-menu-close").click ->
    $("#config-box").trigger "close"
    toggle_highlighted_boxes selectedBox

### END Define Listeners ###


# Path to the trickle-modules
modpath = "./modules"
modules = []

# List all modules in path
# TODO Check for invalid files
fs.readdir modpath, (err, files) ->
    throw err if err
    modules = files


# Toggle highlighted box if selecting config
toggle_highlighted_boxes = (thisBox) ->
    normalBorder = "1px solid #aaa"
    highlightedBorder = "1px solid red"
    animationDirection =  "down"

    # if no box is selected
    if not selectedBox
        selectedBox = thisBox
        $(selectedBox).css "border", highlightedBorder
        $("#control-standard").hide "slide", direction: animationDirection, ->
            $("#control-edit-box").show "slide", direction: animationDirection

    # if you click on the same box as before
    else if selectedBox is thisBox
        $(selectedBox).css "border", normalBorder
        $("#control-edit-box").hide "slide", direction: animationDirection, ->
            $("#control-standard").show "slide", direction: animationDirection
        selectedBox = null

    # if one box is already highlighted, but another config is selected
    else
        $(selectedBox).css "border", normalBorder
        $(thisBox).css "border", highlightedBorder
        selectedBox = thisBox


### Config Dialogue Logic ###

# List all modules to add them to a box
config_dialogue_module_add = (boxContentId, boxOuterId) ->
    # Header
    content = "<h3>Choose your module</h3>"

    content += "<ul>"
    for module in modules
        if (module.charAt 0) != '.'
            content += create_module_list_items module
    content += "</ul>"

    # Open Config Dialogue with content
    $(configDialogue).lightbox_me().html content

    # Add listener
    $(".module-single").click ->
        if session.boxes[boxOuterId].loaded_modules
            if $(this).attr("name") in session.boxes[boxOuterId].loaded_modules
                return # do not add modules that are already loaded
        load_module $(this).attr("name"), boxContentId, boxOuterId, configDialogue


# Show Config Dialogue
config_dialogue_edit = (boxContentId, boxOuterId) ->
    for module in modules
        if (module.charAt 0) != '.'
            load_module module, boxContentId, boxOuterId, "#config-" + boxOuterId[1..] + "-" + module
    $("#config-tabs").lightbox_me()
    showConfig = false


# Destroy modules from a box
config_dialogue_module_removal = (boxContentId, boxOuterId) ->
    configBox = "#config-box"
    boxModules = session.boxes[selectedBox].loaded_modules
    content = "<h3>Remove modules from box</h3>"
    content += "<div><ul id='config-box-list-modules'>"

    for module in boxModules
        content += create_module_list_items module
    content += "</ul></div>"

    $("#config-box-list-modules").selectable()

    # Open Config Dialogue with content
    $(configBox).lightbox_me().html content

    # Add listener
    $(".module-single").click ->
        destroy_module $(this).attr("name"), boxContentId, boxOuterId
        $(configBox).html "<span class='btn'><span class='glyphicon glyphicon-ok'></span> Module successfully removed.</span>"
        closeConfigDialogue = -> $(configBox).trigger "close"
        setTimeout closeConfigDialogue, 2000


# Remove box and destroy all assigned modules
config_dialogue_box_remove = (boxContentId, boxOuterId) ->
    configBox = "#config-box"

    if session.boxes[selectedBox].loaded_modules
        boxModules = session.boxes[selectedBox].loaded_modules
    else
        boxModules = {}

    content = "<h3>Do you really want to delete this box?</h3>"
    content += "<button class='btn btn-default' id='box-remove-yes'>Yes</button>&nbsp;"
    content += "<button class='btn btn-default' id='box-remove-no'>No</button>"

    # Open Config Dialogue with content
    $(configBox).lightbox_me().html content

    $("#box-remove-yes").click ->
        for module in boxModules
            destroy_module module, boxContentId, boxOuterId
        delete session.boxes[selectedBox]
        $(selectedBox).remove()
        toggle_highlighted_boxes selectedBox
        selectedBox = undefined
        $(configBox).html "<span class='btn'><span class='glyphicon glyphicon-ok'></span> Box successfully removed.</span>"
        closeConfigDialogue = -> $(configBox).trigger "close"
        setTimeout closeConfigDialogue, 2000

    $("#box-remove-no").click ->
        $(configBox).trigger "close"


# Creates colorized list items with corresponding icons from module's config.json
create_module_list_items = (module) ->
    config = load_conf path.join(modpath, module)
    content = "<li class='module-entry'><a class='module-single' href='#' name='#{module}'"

    # Assign values from the correlated config.json
    if config
        name   = config.name
        bcolor = config.color
        icon   = path.join modpath, module, config.icon
        icon_fa = config.icon_fa

    # Assign the color to the background
    if bcolor != "" && bcolor
        content += " style='background-color: #{bcolor};'"
    content += ">"

    # Decide which icon has to be showed
    if icon_fa
        content += "<span class='fa #{icon_fa}'></span>&nbsp;"
    else if icon
        content += "<img class='icon' src='#{icon}' alt='#{module}' onerror='this.remove()'>"

    # Decide which name has to be shown
    if name != "" && name
        content += "#{name}</a></li>"
    else
        content += "#{module}</a></li>"

    return content


# Get into the module and look for config.json
load_module = (modname, boxContentId, boxOuterId, configWindow) ->
    moddir = path.join(modpath, modname)
    config = load_conf moddir

    if config
        # Take hook and require it. This should be in a different function
        mod = require("./" + path.join(moddir, path.basename(config.hook, path.extname(config.hook))))

        # Load module
        mod.init boxContentId, configWindow, session

        # Tell core that you loaded module
        if not session.boxes[boxOuterId].loaded_modules
            session.boxes[boxOuterId].loaded_modules = [ ]
        if modname not in session.boxes[boxOuterId].loaded_modules
            session.boxes[boxOuterId].loaded_modules.push modname

        if not showConfig
            # Prepare configuration window for each module in a box
            selectConfigBox = "config-" + boxOuterId[1..]
            $("#config-tabs-ul").append "<li><a href='##{selectConfigBox}-#{modname}'>#{modname}</a></li>"
            $("#"+selectConfigBox).append "<div id='#{selectConfigBox}-#{modname}'></div>"


# Get into the module and look for config.json
destroy_module = (modname, boxContentId, boxOuterId) ->
    moddir = path.join(modpath, modname)
    config = load_conf moddir

    if config
        # Take hook and require it. This should be in a different function
        mod = require("./" + path.join(moddir, path.basename(config.hook, path.extname(config.hook))))
        # Destroy module
        mod.destroy boxOuterId, boxContentId, session


# Load config of given module
load_conf = (moddir) ->
    try
        config = fs.readFileSync path.join(moddir, "config.json"), "utf8"
        result = JSON.parse(config)
    catch e
        result = ""
    return result

### END Config Dialogue Logic ###

### Core Logic (Startup and Close) ###

getNumFromName = (name) ->
    pattern = /^#.*-(\d+)$/
    Number name.match(pattern)[1]

# Restore all old windows
for boxName, value of session.boxes
    child_content = value.content_child
    num = getNumFromName boxName
    createBox num
    $(boxName).offset(value.position)
    $(child_content).html value.content
    $(boxName).css 'height', value.size.height
    $(boxName).css 'width', value.size.width
    if value.loaded_modules # Check for empty windows
        for module in value.loaded_modules
            load_module module, child_content, boxName, configDialogue

init_done = true  # Set when all session startup is done

# Get the current window
win = gui.Window.get()

# Before closing window, write session to file
win.on "close", ->
    @hide() # Pretend to be closed already

    #Collect data about windows
    if not session.boxes
        session["boxes"] = { }
    $(".box-content").each (index) ->
        id = '#'+$(this).prop "id"
        parent_id = '#'+$(id).parent().prop "id"
        if not session.boxes[parent_id]
            session.boxes[parent_id] = { }
        session.boxes[parent_id].content_child = id
        session.boxes[parent_id].position = $(parent_id).offset()
        session.boxes[parent_id].content = $(id).html()
        session.boxes[parent_id].size =
            "height": $(parent_id).height()
            "width": $(parent_id).width()

    # Write session to file
    jsonified = JSON.stringify(session, null, 4)
    fs.writeFileSync home_path+'/.trickle/session.json', jsonified, 'utf8'
    gui.App.quit()

### END Core Logic (Startup and Close) ###
