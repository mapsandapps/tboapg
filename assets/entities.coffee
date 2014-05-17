# create or mixins namespace
Game.Mixins = {}

# define our moveable mixin
Game.Mixins.Moveable = 
  name: 'Moveable'
  tryMove: (x, y, map) ->
    tile = map.getTile(x, y)
    target = map.getEntityAt(x, y)
    # if an entity was at the tile, we can't move there
    if target
      return false 
    else if tile.isWalkable()
      # update the entity's position
      @_x = x
      @_y = y
      return true
    # check if the tile is diggable and if so, try to dig
    else if tile.isDiggable()
      map.dig x, y
      return true
    false

# main player's actor mixin
Game.Mixins.PlayerActor = 
  name: 'PlayerActor'
  groupName: 'Actor'
  act: ->
    # re-render screen
    Game.refresh()
    # lock engine and wait for player to press a key
    @getMap().getEngine().lock()

Game.Mixins.FungusActor =
  name: 'FungusActor'
  groupName: 'Actor'
  act: ->

# player template
Game.PlayerTemplate = 
  character: ''
  foreground: 'white'
  mixins: [Game.Mixins.Moveable, Game.Mixins.PlayerActor]

Game.FungusTemplate = 
  character: 'F'
  foreground: 'green'
  mixins: [Game.Mixins.FungusActor]
