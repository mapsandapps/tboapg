Game.Screen = {}

# initial start screen
Game.Screen.startScreen = 
  enter: -> 
    console.log "Entered start screen."
    return

  exit: -> 
    console.log "Exited start screen."
    return

  render: (display) ->
    display.drawText(1,1, "%c{yellow}Codename: The Best of All Possible Games")
    display.drawText(1,3, "%c{yellow}A CoffeeScript Roguelike by Mollie Taylor")
    display.drawText(1,5, "Press [Enter] to start!")
    return

  handleInput: (inputType, inputData) ->
    if inputType is 'keydown'
      if inputData.keyCode is ROT.VK_RETURN
        Game.switchScreen Game.Screen.playScreen
    return

# playing screen
Game.Screen.playScreen =
  _map: null
  _player: null
  _gameEnded: false
  _subScreen: null
  enter: ->
    width = Game.getScreenWidth()
    height = Game.getScreenHeight()
    depth = 5
    
    # create map from tiles and player
    tiles = new Game.Builder(width, height, depth).getTiles()
    @_player = new Game.Entity(Game.PlayerTemplate)
    @_map = new Game.Map(tiles, @_player)
    # start map's engine
    @_map.getEngine().start()

    return

  exit: ->
    console.log "Exited play screen."
    return

  render: (display) ->
    # render subscreen if there is one
    if @_subScreen
      @_subScreen.render display
      return
    screenWidth = Game.getScreenWidth()
    screenHeight = Game.getScreenHeight()
    # make sure x-axis doesn't go left of left bound
    topLeftX = Math.max(0, @_player.getX() - (screenWidth / 2))
    # make sure we have enough space for game screen
    topLeftX = Math.min(topLeftX, @_map.getWidth() - screenWidth)
    # make sure y-axis doesn't go above top bound
    topLeftY = Math.max(0, @_player.getY() - (screenHeight / 2))
    # make sure we have enough space for game screen
    topLeftY = Math.min(topLeftY, @_map.getHeight() - screenHeight)
    # this object will keep track of all visible map cells
    visibleCells = {}
    # store @_map and player's z to prevent losing it in callbacks
    map = @_map
    currentDepth = @_player.getZ()
    # find all visible cells and update the object
    @_map.getFov(currentDepth).compute(
      @_player.getX()
      @_player.getY()
      @_player.getSightRadius()
      (x, y, radius, visibility) ->
        visibleCells[x + ',' + y] = true
        # mark cell as explored
        map.setExplored(x, y, currentDepth, true)
        return
    )
    # Render the explored map cells
    x = topLeftX

    while x < topLeftX + screenWidth
      y = topLeftY

      while y < topLeftY + screenHeight
        if map.isExplored(x, y, currentDepth)
          
          # Fetch the glyph for the tile and render it to the screen
          # at the offset position.
          glyph = @_map.getTile(x, y, currentDepth)
          foreground = glyph.getForeground()
          
          # If we are at a cell that is in the field of vision, we need
          # to check if there are items or entities.
          if visibleCells[x + "," + y]
            
            # Check for items first, since we want to draw entities
            # over items.
            items = map.getItemsAt(x, y, currentDepth)
            
            # If we have items, we want to render the top most item
            glyph = items[items.length - 1]  if items
            
            # Check if we have an entity at the position
            glyph = map.getEntityAt(x, y, currentDepth)  if map.getEntityAt(x, y, currentDepth)
            
            # Update the foreground color in case our glyph changed
            background = glyph.getBackground()
          else if glyph._walkable is false
            background = glyph.getBackground()
          else
            
            # Since the tile was previously explored but is not 
            # visible, we want to change the background color to
            # dark gray.
            background = "#1b002e"
          display.draw x - topLeftX, y - topLeftY, glyph.getChar(), glyph.getForeground(), background
        y++
      x++

    # get messages in player's queue and render
    messages = @_player.getMessages()
    messageY = 0
    i = 0
    while i < messages.length
      # draw each message, adding the number of lines
      messageY += display.drawText(
        0
        messageY
        '%c{white}%b{black}' + messages[i]
      )
      i++

    # render player HP
    stats = '%c{white}%b{black}'
    stats += vsprintf('HP: %d/%d ', [
      @_player.getHp()
      @_player.getMaxHp()
    ])
    display.drawText 0, screenHeight, stats
    return

  handleInput: (inputType, inputData) ->
    # if the game is over, enter will bring user to losing screen
    if @_gameEnded
      Game.switchScreen Game.Screen.loseScreen  if inputType is 'keydown' and inputData.keyCode is ROT.VK_RETURN
      # return to make sure user can't still play
      return
    
    # handle subscreen input if there is one
    if @_subScreen
      @_subScreen.handleInput inputType, inputData
      return

    if inputType is 'keydown'
      if inputData.keyCode is ROT.VK_RETURN
        Game.switchScreen Game.Screen.winScreen
      else if inputData.keyCode is ROT.VK_ESCAPE
        Game.switchScreen Game.Screen.loseScreen
      else
        # movement
        if inputData.keyCode is ROT.VK_LEFT
          @move -1, 0, 0
        else if inputData.keyCode is ROT.VK_RIGHT
          @move 1, 0, 0
        else if inputData.keyCode is ROT.VK_UP
          @move 0, -1, 0
        else if inputData.keyCode is ROT.VK_DOWN
          @move 0, 1, 0
        else if inputData.keyCode is ROT.VK_D
          currentZ = @_player.getZ()
          @_player.tryMove upLoc[currentZ].x, upLoc[currentZ].y, upLoc[currentZ].z, @_map
        else if inputData.keyCode is ROT.VK_U
          newZ = @_player.getZ() - 1
          @_player.tryMove downLoc[newZ].x, downLoc[newZ].y, downLoc[newZ].z, @_map
        else if inputData.keyCode is ROT.VK_I
          if @_player.getItems().filter((x) ->
            x
          ).length is 0

            # if the player has no items, send a message and don't take a turn
            Game.sendMessage @_player, 'You are not carrying anything!'
            Game.refresh()
          else
            # show the inventory
            Game.Screen.inventoryScreen.setup @_player, @_player.getItems()
            @setSubScreen Game.Screen.inventoryScreen
          return
        else if inputData.keyCode is ROT.VK_COMMA
          items = @_map.getItemsAt(@_player.getX(), @_player.getY(), @_player.getZ())
          # if there are no items, show a message
          unless items
            Game.sendMessage @_player 'There is nothing here to pick up.'
          else if items.length is 1
            # if only one item, try to pick it up
            item = items[0]
            if @_player.pickupItems([0])
              Game.sendMessage @_player, 'You pick up %s.', [item.describeA()]
            else
              Game.sendMessage @_player, 'Your inventory is full! Nothing was picked up.'
          else
            # show the pickup screen if there are any items
            Game.Screen.pickupScreen.setup @_player, items
            @setSubScreen Game.Screen.pickupScreen
            return
        else # not a valid key
          return
        # unlock the engine
        @_map.getEngine().unlock()
    return

  move: (dX, dY, dZ) ->
    newX = @_player.getX() + dX
    newY = @_player.getY() + dY
    newZ = @_player.getZ() + dZ
    # try to move to the new cell
    @_player.tryMove newX, newY, newZ, @_map
    return

  setGameEnded: (gameEnded) ->
    @_gameEnded = gameEnded
    return

  setSubScreen: (subScreen) ->
    @_subScreen = subScreen
    # refresh screen on changing subscreen
    Game.refresh()
    return

# win screen
Game.Screen.winScreen =
  enter: ->
    console.log "Entered win screen."
    return

  exit: ->
    console.log "Exited win screen."
    return

  render: (display) ->
    # NOT SURE ABOUT THIS LOOP
    for i in [0..23]
      r = Math.round Math.random() * 255
      g = Math.round Math.random() * 255
      b = Math.round Math.random() * 255
      # NOT SURE ABOUT THIS LINE
      background = ROT.Color.toRGB [r, g, b]
      display.drawText 2, i + 1, "%b{#{background}}You win!"
    return

  handleInput: (inputType, inputData) ->
    # nothing to do
    return

# lose screen
Game.Screen.loseScreen = 
  enter: ->
    console.log "Entered lose screen."
    return

  exit: ->
    console.log "Exited lose screen."
    return

  render: (display) ->
    for i in [0:23]
      display.drawText 2, i+1, "%b{red}You lose! :("
    return

  handleInput: (inputType, inputData) ->
    # nothing
    return

Game.Screen.ItemListScreen = (template) ->
  # set up based on the template
  @_caption = template['caption']
  @_okFunction = template['ok']
  # whether the user can select items at all
  @_canSelectItem = template['canSelect']
  # whether the user can select multiple items
  @_canSelectMultipleItems = template['canSelectMultipleItems']
  return

Game.Screen.ItemListScreen::setup = (player, items) ->
  @_player = player
  # should be called before switching to the screen
  @_items = items
  # clean set of selected indices
  @_selectedIndices = {}
  return

Game.Screen.ItemListScreen::render = (display) ->
  numbers = '1234567890'
  # render caption in top row
  display.drawText(0, 0, @_caption)
  row = 0
  i = 0
  while i < @_items.length
    # if we have an item, we want to render it
    if @_items[i]
      # get number matching item's index
      number = numbers.substring(i, i + 1)
      # if we selected an item, show a +, otherwise show a - between
      # the number and the item's name
      selectionState = (if (@_canSelectItem and @_canSelectMultipleItems and @_selectedIndices[i]) then '+' else '-')
      # render at correct row and add 2
      display.drawText 0, 2 + row, number + ' ' + selectionState + ' ' + @_items[i].describe()
      row++
    i++
  return

Game.Screen.ItemListScreen::executeOkFunction = ->
  
  # Gather the selected items.
  selectedItems = {}
  for key of @_selectedIndices
    selectedItems[key] = @_items[key]
  
  # Switch back to the play screen.
  Game.Screen.playScreen.setSubScreen `undefined`
  
  # Call the OK function and end the player's turn if it return true.
  @_player.getMap().getEngine().unlock()  if @_okFunction(selectedItems)
  return

Game.Screen.ItemListScreen::handleInput = (inputType, inputData) ->
  if inputType is "keydown"
    
    # If the user hit escape, hit enter and can't select an item, or hit
    # enter without any items selected, simply cancel out
    if inputData.keyCode is ROT.VK_ESCAPE or (inputData.keyCode is ROT.VK_RETURN and (not @_canSelectItem or Object.keys(@_selectedIndices).length is 0))
      Game.Screen.playScreen.setSubScreen `undefined`
    
    # Handle pressing return when items are selected
    else if inputData.keyCode is ROT.VK_RETURN
      @executeOkFunction()
    
    # Handle pressing a letter if we can select
    else if @_canSelectItem and inputData.keyCode >= ROT.VK_1 and inputData.keyCode <= ROT.VK_9
      
      # Check if it maps to a valid item by subtracting 'a' from the character
      # to know what letter of the alphabet we used.
      index = inputData.keyCode - ROT.VK_1
      if @_items[index]
        
        # If multiple selection is allowed, toggle the selection status, else
        # select the item and exit the screen
        if @_canSelectMultipleItems
          if @_selectedIndices[index]
            delete @_selectedIndices[index]
          else
            @_selectedIndices[index] = true
          
          # Redraw screen
          Game.refresh()
        else
          @_selectedIndices[index] = true
          @executeOkFunction()
  return

Game.Screen.inventoryScreen = new Game.Screen.ItemListScreen(
  caption: "Inventory"
  canSelect: false
)
Game.Screen.pickupScreen = new Game.Screen.ItemListScreen(
  caption: "Choose the items you wish to pickup"
  canSelect: true
  canSelectMultipleItems: true
  ok: (selectedItems) ->
    
    # Try to pick up all items, messaging the player if they couldn't all be
    # picked up.
    Game.sendMessage @_player, "Your inventory is full! Not all items were picked up."  unless @_player.pickupItems(Object.keys(selectedItems))
    true
)
Game.Screen.dropScreen = new Game.Screen.ItemListScreen(
  caption: "Choose the item you wish to drop"
  canSelect: true
  canSelectMultipleItems: false
  ok: (selectedItems) ->
    
    # Drop the selected item
    @_player.dropItem Object.keys(selectedItems)[0]
    true
)


