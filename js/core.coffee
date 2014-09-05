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

# Read session and parse it to the variable
fs.readFile 'data/session.json', "utf8", (err, data) ->
    if err
        console.error err
    else
        root.session = JSON.parse(data)  # Parse file to session

# Before closing window, write session to file
win.on "close", ->
    @hide() # Pretend to be closed already
    # Write session to file
    root.session.bar = "bar"
    console.log root.session
    fs.writeFile "data/session.json", JSON.stringify(root.session, null, 4), (err) ->
        if err
            console.error err
        gui.App.quit()
