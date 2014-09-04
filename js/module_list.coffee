modules = exports ? this

# List all modules
list = ->
    console.log "To be implemented"
    return

$ ->
    dir = require("node-dir")

    # Path to the trickle-modules
    path = "modules"
    modules = []

    # List all Modules
    dir.subdirs path, (err, subdirs) ->
        console.log subdirs
        return

    return
