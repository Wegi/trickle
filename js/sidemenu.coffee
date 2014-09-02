$ ->
    $(".slideout-menu-toggle").on "click", (event) ->
        event.preventDefault()

        # create menu variables
        slideoutMenu = $(".slideout-menu")
        slideoutMenuWidth = $(".slideout-menu").width()

        # toggle open class
        slideoutMenu.toggleClass "open"

        # slide menu
        if slideoutMenu.hasClass("open")
            slideoutMenu.animate left: "0px"
        else
            slideoutMenu.animate
                left: -slideoutMenuWidth
            , 250
        return

    return