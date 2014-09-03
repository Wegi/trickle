sidemenu = exports ? this

# Toggle sidebar
toggle = ->
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

# Close sidebar
close = ->
    event.preventDefault()
    # create menu variables
    slideoutMenu = $(".slideout-menu")
    slideoutMenuWidth = $(".slideout-menu").width()
    # toggle open class
    slideoutMenu.removeClass "open"
    # slide menu
    slideoutMenu.animate left: -slideoutMenuWidth, 200
    return

# Open sidebar
open = ->
    event.preventDefault()
    # create menu variables
    slideoutMenu = $(".slideout-menu")
    slideoutMenuWidth = $(".slideout-menu").width()
    # toggle open class
    slideoutMenu.addClass "open"
    # slide menu
    slideoutMenu.animate left: "0px"
    return

$ ->
    # Add listener to Add button in sidebar
    $(".slideout-menu-toggle").click (event) ->
        toggle()
        return
    return
