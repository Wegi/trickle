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

### Boxes Logic ###
baseZIndex = 50
configDialogue = "#config-dialogue"
selectedBox = ""
if not session.present_boxes
    session.present_boxes = [ ]

getNextNum = () ->
    num = 0
    num++ while num in session.present_boxes
    num

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

    $("#boxes").append defaultContent
    box = $("#box-#{numBoxes}").draggable(grid: [10, 10]).resizable(grid: 10).center()

    # Show list of Modules (Only do if init is done)
    if init_done
        config_dialogue_module_add "#box-content-#{numBoxes}", "#box-#{numBoxes}"

    # Configure mouseclick event on Preference button in box
    $("div.box-control span#box-control-button-#{numBoxes}").click ->
        # Set selected Box
        thisBox = "#" + $(this).parent().parent().prop "id"
        toggle_highlighted_boxes(thisBox)

    if numBoxes not in session.present_boxes
        session.present_boxes.push numBoxes


### Define Listeners ###
$("#new-box").click ->
    num = getNextNum()
    createBox num

# Add new Module to Box
$("#control-menu-add").click ->
    contentDiv = "#" + $(selectedBox).children("div.box-content").prop "id"
    config_dialogue_module_add contentDiv, selectedBox

# Show list of Modules, remove selected ones
$("#control-menu-remove").click ->
    config_dialogue_module_removal()

# Open configuration of Box containing all Modules to config
$("#control-menu-config").click ->

# Delete complete Box
$("#control-menu-delete").click ->

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
config_dialogue_module_add = (boxid, outer_id) ->
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
        load_module $(this).attr("name"), boxid, outer_id


# Show all modules for removal
config_dialogue_module_removal = ->
    modules = session.boxes[selectedBox].loaded_modules
    content = "<h3>Remove modules from box</h3>"
    content += "<div><ul id='config-box-list-modules'>"

    for module in modules
        content += create_module_list_items module
    content += "</ul></div>"

    $("#config-box-list-modules").selectable()

    # Open Config Dialogue with content
    $("#config-box").lightbox_me().html content

    # Add listener
    $(".module-single").click ->
        load_module $(this).attr("name"), boxid, outer_id


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

    # assign the color to the background
    if bcolor != "" && bcolor
        content += " style='background-color: #{bcolor};'"
    content += ">"

    # decide which icon has to be showed
    if icon_fa
        content += "<span class='fa #{icon_fa}'></span>&nbsp;"
    else if icon
        content += "<img class='icon' src='#{icon}' alt='#{module}' onerror='this.remove()'>"

    # decide which name has to be showed
    if name != "" && name
        content += "#{name}</a></li>"
    else
        content += "#{module}</a></li>"

    return content


# Get into the module and look for config.json
load_module = (modname, boxContentId, boxOuterId) ->
    if session.boxes[boxOuterId].loaded_modules
        if modname in session.boxes[boxOuterId].loaded_modules
            return # do not add modules that are already loaded
    moddir = path.join(modpath, modname)
    config = load_conf moddir

    if config
        # Take hook and require it. This should be in a different function
        mod = require("./" + path.join(moddir, path.basename(config.hook, path.extname(config.hook))))

        # Load module
        mod.init boxContentId, configDialogue, session

        #tell core that you loaded module
        if not session.boxes[boxOuterId].loaded_modules
            session.boxes[boxOuterId].loaded_modules = [ ]
        if modname not in session.boxes[boxOuterId].loaded_modules
            session.boxes[boxOuterId].loaded_modules.push modname


# Get into the module and look for config.json
destroy_module = (modname, boxContentId, boxOuterId) ->
    moddir = path.join(modpath, modname)
    config = load_conf moddir

    if config
        # Take hook and require it. This should be in a different function
        mod = require("./" + path.join(moddir, path.basename(config.hook, path.extname(config.hook))))

        # Load module
        mod.destroy boxContentId, "#config-box", session

        # Tell core that you loaded module
        if not session.boxes[boxOuterId].loaded_modules
            session.boxes[boxOuterId].loaded_modules = [ ]
        if modname not in session.boxes[boxOuterId].loaded_modules
            session.boxes[boxOuterId].loaded_modules.push modname


# Load config of given module
load_conf = (moddir) ->
    try
        config = fs.readFileSync path.join(moddir, "config.json"), "utf8"
    catch e
        config = null
    return JSON.parse(config)

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
    $(boxName).css 'heigth', value.size.height
    $(boxName).css 'width', value.size.width
    if value.loaded_modules # Check for empty windows
        for module in value.loaded_modules
            load_module module, child_content, boxName

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

### Extend Coffeescript Arrays ###
# Removes one item if found. Example:
# a = [1,2,3]; a.remove 1;
# Then a is [2,3]. No need to reassign array
Array::remove = (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1

### Extend jQuery ###
# Center boxes in window, use it with $("path").center()
$.fn.center = ->
    @css "position", "absolute"
    @css "top", Math.max(0, (($(window).height() - $(this).outerHeight()) / 2) + $(window).scrollTop()) + "px"
    @css "left", Math.max(0, (($(window).width() - $(this).outerWidth()) / 2) + $(window).scrollLeft()) + "px"
    this
