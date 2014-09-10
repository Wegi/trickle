############
#    Trickle Core
############

### Require modules ###
fs = require "fs"
gui = require "nw.gui"
path = require "path"

### Core Logic Preparations ###
#Set Startup-Parameters
init_done = false

#Get Home PATH
home_path = process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE

#Check if folder and file are existent and create them if not
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
    session = { }

### Boxes Logic ###
baseZIndex = 50
configDialogue = "#config-dialogue"
loaded_modules = { }
if not session.present_boxes
    session.present_boxes = [ ]

getNextNum = () ->
    num = 0
    num++ while num in session.present_boxes
    num

# Make boxes draggable and resizable and snap them to other boxes
createBox = (numBoxes) ->
    defaultContent = """
        <div class='draggable ui-widget-content box box-modules' id='box-#{numBoxes}' style='z-index: #{baseZIndex + numBoxes}'>
            <div class='box-control'>
                <span class='glyphicon glyphicon-cog box-control-button'></span>
            </div>
            <div class='box-content' id='box-content-#{numBoxes}'>
                I am a new Box!<br><br>
                Go and add some modules.<br><br>
                <a id='a-#{numBoxes}' href='#' box-id='#{numBoxes}'><span class='glyphicon glyphicon-plus'></span></a>
            </div>
        </div>
    """

    $("#boxes").append defaultContent
    $("#box-#{numBoxes}").draggable(grid: [10, 10]).resizable(grid: 10).center()

    # Show list of Modules (Only do if init is done)
    if init_done
        list "#box-content-#{numBoxes}", "#box-#{numBoxes}"
        $("div#box-content-#{numBoxes} a#a-#{numBoxes}").click ->
            list "#box-content-" + $(this).attr("box-id")

    if numBoxes not in session.present_boxes
        session.present_boxes.push numBoxes

    #return conten_id and outer_id
    return ["#box-content-#{numBoxes}", "#box-#{numBoxes}"]


$("#new-box").click ->
    console.log "someone is doing bad thangs ############"
    num = getNextNum()
    createBox num

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
    console.log "loading #{modname} on #{boxid} inside of #{outer_id}"
    moddir = path.join(modpath, modname)
    config = load_conf moddir

    #tell core that you loaded module
    if not loaded_modules[outer_id]
        loaded_modules[outer_id] = [ ]
    if modname not in loaded_modules[outer_id]
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

### Core Logic (Startup and Close) ###

getNumFromName = (name) ->
    pattern = /^#.*-(\d+)$/
    Number name.match(pattern)[1]

#restore all old windows
for boxName, value of session.boxes
    #console.log boxName
    num = getNumFromName boxName
    [content_id, outer_id] = createBox num
    $(boxName).offset(value.position)
    $(boxName).html value.content
    $(boxName).height value.size.height
    $(boxName).width value.size.width
    loaded_modules[boxName] = value.loaded_modules
    console.log value.loaded_modules
    console.log loaded_modules[boxName]
    if loaded_modules[boxName] #check for empty windows
        console.log "inside da loop"
        for module in loaded_modules[boxName]
            load_module module, content_id, outer_id

init_done = true  #set when all session startup is done

# Get the current window
win = gui.Window.get()

# Before closing window, write session to file
win.on "close", ->
    @hide() # Pretend to be closed already

    #Collect data about windows
    if not session.boxes
        session["boxes"] = { }
    $(".box-modules").each (index) ->
        id = '#'+this.id
        if not session.boxes["#{id}"]
            session.boxes["#{id}"] = { }
        session.boxes["#{id}"].position = $(id).offset()
        session.boxes["#{id}"].content = $(id).html()
        session.boxes["#{id}"].size =
            "height": $(id).height()
            "width": $(id).width()
        if loaded_modules[id]
            session.boxes[id].loaded_modules = loaded_modules[id]

    # Write session to file
    jsonified = JSON.stringify(session, null, 4)
    fs.writeFileSync home_path+'/.trickle/session.json', jsonified, 'utf8'
    gui.App.quit()
