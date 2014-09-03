root = exports ? this

# Toggle sidebar
root.toggleSidebar = ->
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
        slideoutMenu.animate left: -slideoutMenuWidth, 200
    return

$ ->
    $(".slideout-menu-toggle").click (event) ->
        root.toggleSidebar()
        return

    return
