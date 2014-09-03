$ ->
    # Make boxes draggable and snap them to other boxes
    $(".draggable").draggable snap: true

    $("#box-facebook-trigger").click ->
        $("#box-facebook").show()

    $("#box-twitter-trigger").click ->
        $("#box-twitter").show()

    $("#box-googleplus-trigger").click ->
        $("#box-googleplus").show()

    return
