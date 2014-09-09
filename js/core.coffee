###
    Trickle Core
###

root = exports ? this

### Require modules ###
fs = require "fs"

### Global variables ###
root.session = {}

# Load native UI library
gui = require "nw.gui"
# Get the current window
win = gui.Window.get()

#Get Home PATH
home_path = process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE

#Check if folder and file are existent and create them if not
if not fs.existsSync(home_path+'/.trickle')
    fs.mkdirSync home_path+'/.trickle'
if not fs.existsSync(home_path+'/.trickle/session.json')
    fs.writeFileSync(home_path+'/.trickle/session.json', '{ }')

# Read session and parse it to the variable
try
    fs.readFile home_path+'/.trickle/session.json', "utf8", (err, data) ->
        if err
            console.error err
        else
            try
                root.session = JSON.parse(data)  # Parse file to session
            catch
                console.log "close call"
catch
    console.log "gotcha buddy"
    root.session = { }

# Before closing window, write session to file
win.on "close", ->
    @hide() # Pretend to be closed already
    #Collect data about windows
    if not root.session.boxes
        root.session["boxes"] = { }
    $(".box-modules").each (index) ->
        id = '#'+this.id
        if not root.session.boxes["#{id}"]
            root.session.boxes["#{id}"] = { }
        root.session.boxes["#{id}"].position = $(id).offset()
        root.session.boxes["#{id}"].content = $(id).html()
        root.session.boxes["#{id}"].size =
            "height": $(id).height()
            "width": $(id).width()
        if loaded_modules[id]
            root.session.boxes[id].loaded_modules = loaded_modules[id]

    # Write session to file
    jsonified = JSON.stringify(root.session, null, 4)
    fs.writeFile home_path+'/.trickle/session.json', jsonified, 'utf8', (err) ->
        if err
            console.error err
        gui.App.quit()
