#
#* $ lightbox_me
#* By: Buck Wilson
#* Version : 2.4
#*
#* Licensed under the Apache License, Version 2.0 (the "License");
#* you may not use this file except in compliance with the License.
#* You may obtain a copy of the License at
#*
#*     http://www.apache.org/licenses/LICENSE-2.0
#*
#* Unless required by applicable law or agreed to in writing, software
#* distributed under the License is distributed on an "AS IS" BASIS,
#* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#* See the License for the specific language governing permissions and
#* limitations under the License.
#
$ ->
  $.fn.lightbox_me = (options) ->
    @each ->
      # Remove or hide all elements
      closeLightbox = ->
        s = $self[0].style
        if opts.destroyOnClose
          $self.add($overlay).remove()
        else
          $self.add($overlay).hide()

        #show the hidden parent lightbox
        opts.parentLightbox.fadeIn 200  if opts.parentLightbox
        $("body").css "overflow", ""  if opts.preventScroll
        $iframe.remove()

        # clean up events.
        $self.undelegate opts.closeSelector, "click"
        $self.unbind "close", closeLightbox
        $self.unbind "repositon", setSelfPosition
        $(window).unbind "resize", setOverlayHeight
        $(window).unbind "resize", setSelfPosition
        $(window).unbind "scroll", setSelfPosition
        $(window).unbind "keyup.lightbox_me"
        opts.onClose()
        return

      # Function to bind to the window to observe the escape/enter key press
      observeKeyPress = (e) ->
        closeLightbox()  if (e.keyCode is 27 or (e.DOM_VK_ESCAPE is 27 and e.which is 0)) and opts.closeEsc
        return

      # Set the height of the overlay
      #                    : if the document height is taller than the window, then set the overlay height to the document height.
      #                    : otherwise, just set overlay height: 100%
      #
      setOverlayHeight = ->
        if $(window).height() < $(document).height()
          $overlay.css height: $(document).height() + "px"
          $iframe.css height: $(document).height() + "px"
        else
          $overlay.css height: "100%"
        return

      # Set the position of the modal'd window ($self)
      #                    : if $self is taller than the window, then make it absolutely positioned
      #                    : otherwise fixed
      #
      setSelfPosition = ->
        s = $self[0].style

        # reset CSS so width is re-calculated for margin-left CSS
        $self.css
          left: "50%"
          marginLeft: ($self.outerWidth() / 2) * -1
          zIndex: (opts.zIndex + 3)


        # we have to get a little fancy when dealing with height, because lightbox_me
        #                    is just so fancy.
        #

        # if the height of $self is bigger than the window and self isn't already position absolute
        if ($self.height() + 80 >= $(window).height()) and ($self.css("position") isnt "absolute")

          # we are going to make it positioned where the user can see it, but they can still scroll
          # so the top offset is based on the user's scroll position.
          topOffset = $(document).scrollTop() + 40
          $self.css
            position: "absolute"
            top: topOffset + "px"
            marginTop: 0

        else if $self.height() + 80 < $(window).height()

          #if the height is less than the window height, then we're gonna make this thing position: fixed.
          if opts.centered
            $self.css
              position: "fixed"
              top: "50%"
              marginTop: ($self.outerHeight() / 2) * -1

          else
            $self.css(position: "fixed").css opts.modalCSS
          $("body").css "overflow", "hidden"  if opts.preventScroll
        return
      opts = $.extend({}, $.fn.lightbox_me.defaults, options)
      $overlay = $()
      $self = $(this)
      $iframe = $("<iframe id=\"foo\" style=\"z-index: " + (opts.zIndex + 1) + ";border: none; margin: 0; padding: 0; position: absolute; width: 100%; height: 100%; top: 0; left: 0; filter: mask();\"/>")
      if opts.showOverlay
        $currentOverlays = $(".js_lb_overlay:visible")
        if $currentOverlays.length > 0
          $overlay = $("<div class=\"lb_overlay_clear js_lb_overlay\"/>")
        else
          $overlay = $("<div class=\"" + opts.classPrefix + "_overlay js_lb_overlay\"/>")
      $("body").append($self.hide()).append $overlay
      if opts.showOverlay
        setOverlayHeight()
        $overlay.css
          position: "absolute"
          width: "100%"
          top: 0
          left: 0
          right: 0
          bottom: 0
          zIndex: (opts.zIndex + 2)
          display: "none"

        $overlay.css opts.overlayCSS  unless $overlay.hasClass("lb_overlay_clear")
      if opts.showOverlay
        $overlay.fadeIn opts.overlaySpeed, ->
          setSelfPosition()
          $self[opts.appearEffect] opts.lightboxSpeed, ->
            setOverlayHeight()
            setSelfPosition()
            opts.onLoad()
            return

          return

      else
        setSelfPosition()
        $self[opts.appearEffect] opts.lightboxSpeed, ->
          opts.onLoad()
          return

      opts.parentLightbox.fadeOut 200  if opts.parentLightbox
      $(window).resize(setOverlayHeight).resize(setSelfPosition).scroll setSelfPosition
      $(window).bind "keyup.lightbox_me", observeKeyPress
      if opts.closeClick
        $overlay.click (e) ->
          closeLightbox()
          e.preventDefault
          return

      $self.delegate opts.closeSelector, "click", (e) ->
        closeLightbox()
        e.preventDefault()
        return

      $self.bind "close", closeLightbox
      $self.bind "reposition", setSelfPosition
      return


  $.fn.lightbox_me.defaults =

    # animation
    appearEffect: "fadeIn"
    appearEase: ""
    overlaySpeed: 250
    lightboxSpeed: 300

    # close
    closeSelector: ".close"
    closeClick: true
    closeEsc: true

    # behavior
    destroyOnClose: false
    showOverlay: true
    parentLightbox: false
    preventScroll: false

    # callbacks
    onLoad: ->

    onClose: ->

    # style
    classPrefix: "lb"
    zIndex: 999
    centered: false
    modalCSS:
      width: "50%",
      top: "10%"

    overlayCSS:
      background: "black"
      opacity: .6
