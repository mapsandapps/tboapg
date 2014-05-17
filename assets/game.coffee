Game = 
  _display: null
  _currentScreen: null
  _screenWidth: 60
  _screenHeight: 24
  init: ->

    @_display = new ROT.Display(
      width: @_screenWidth
      height: @_screenHeight
      fontFamily: 'FontAwesome'
    )

    # helper function for binding to event and making it
    # send to screen
    game = this
    bindEventToScreen = (event) ->
      window.addEventListener event, (e) ->
        if game._currentScreen isnt null
          # send the event type and data to the screen
          game._currentScreen.handleInput event, e  
        return
      return

    bindEventToScreen('keydown')
    # bindEventToScreen('keyup')
    # bindEventToScreen('keypress')
    return

  getDisplay: ->
    @_display

  getScreenWidth: ->
    @_screenWidth

  getScreenHeight: ->
    @_screenHeight

  refresh: ->
    # clear the screen
    @_display.clear()
    # render the screen
    @_currentScreen.render(@_display)
    return

  switchScreen: (screen) ->

    # if we had a screen, notify it we exited
    @_currentScreen.exit() if @_currentScreen isnt null

    @getDisplay().clear()

    # update screen, notify we entered, render it
    @_currentScreen = screen
    if not @_currentScreen isnt null
      @_currentScreen.enter()
      @refresh()
    return


window.onload = ->
  unless ROT.isSupported()
    alert "The rot.js library isn't supported by your browser."
  else
    Game.init()
    # add container to page
    document.getElementById("game").appendChild Game.getDisplay().getContainer()
    # load start screen
    Game.switchScreen Game.Screen.startScreen
  return


