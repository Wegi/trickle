root = exports ? this

numBoxes = 0

$ ->
    # Make boxes draggable and snap them to other boxes
    $(".draggable").draggable snap: true

    $("#new-box").click ->
        $("#boxes").append "<div class='draggable ui-widget-content' id='box-#{numBoxes}'>I am a new Box! Go and add some modules.</div>"
        $("#box-#{numBoxes}").draggable snap: true
        root.toggleSidebar()
        numBoxes++
        return

    return
