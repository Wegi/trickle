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
        list "#box-content-#{numBoxes}", "#box-#{numBoxes}"

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

$("#control-menu-add").click ->
    contentDiv = "#" + $(selectedBox).children("div.box-content").prop "id"
    list contentDiv, selectedBox

$("#control-menu-remove").click ->

$("#control-menu-delete").click ->

$("#control-menu-config").click ->


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
    if session.boxes[outer_id].loaded_modules
        if modname in session.boxes[outer_id].loaded_modules
            return # do not add modules that are already loaded
    moddir = path.join(modpath, modname)
    config = load_conf moddir

    if config
        # Take hook and require it. This should be in a different function
        mod = require("./" + path.join(moddir, path.basename(config.hook, path.extname(config.hook))))

        # Load module
        mod.init boxid, configDialogue, session

        #tell core that you loaded module
        if not session.boxes[outer_id].loaded_modules
            session.boxes[outer_id].loaded_modules = [ ]
        if modname not in session.boxes[outer_id].loaded_modules
            session.boxes[outer_id].loaded_modules.push modname


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

### Core Logic (Startup and Close) ###

getNumFromName = (name) ->
    pattern = /^#.*-(\d+)$/
    Number name.match(pattern)[1]

#restore all old windows
for boxName, value of session.boxes
    child_content = value.content_child
    num = getNumFromName boxName
    createBox num
    $(boxName).offset(value.position)
    $(child_content).html value.content
    $(boxName).css 'heigth', value.size.height
    $(boxName).css 'width', value.size.width
    if value.loaded_modules #check for empty windows
        for module in value.loaded_modules
            load_module module, child_content, boxName

init_done = true  #set when all session startup is done

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
