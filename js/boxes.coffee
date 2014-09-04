boxes = exports ? this

numBoxes = 0

$ ->
    # Make boxes draggable and resizable and snap them to other boxes
    $("#new-box").click ->
        defaultContent = "
            <div class='draggable ui-widget-content' id='box-#{numBoxes}'>
                I am a new Box!<br><br>
                Go and add some modules.<br><br>
                <a class='module_list' href='#'><span class='glyphicon glyphicon-plus'></span></a>
            </div>
        "
        $("#boxes").append defaultContent
        $("#box-#{numBoxes}").draggable(snap: true).resizable()

        sidemenu.close()
        numBoxes++

        #
        $(".module_list").click ->
            modules.list()
            return
        return

    return
