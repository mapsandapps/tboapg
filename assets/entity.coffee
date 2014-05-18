Game.Entity = (properties) ->
  properties = properties or {}
  # call the dynamic glyph's constructor with our set of properties
  Game.DynamicGlyph.call this, properties
  # instantiate properties from passed object
  @_x = properties['x'] or 0
  @_y = properties['y'] or 0
  @_z = properties['z'] or 0
  @_map = null
  @_alive = true
  return

# make entities inherit all functionality from dynamic glyphs
Game.Entity.extend Game.DynamicGlyph

Game.Entity::setX = (x) ->
  @_x = x
  return

Game.Entity::setY = (y) ->
  @_y = y
  return

Game.Entity::setZ = (z) ->
  @_z = z
  return

Game.Entity::setMap = (map) ->
  @_map = map
  return

Game.Entity::setPosition = (x, y, z) ->
  oldX = @_x
  oldY = @_y
  oldZ = @_z
  # update position
  @_x = x
  @_y = y
  @_z = z
  # if the entity is on a map, notify the map the entity has moved
  @_map.updateEntityPosition(this, oldX, oldY, oldZ)  if @_map

Game.Entity::getX = ->
  @_x

Game.Entity::getY = ->
  @_y

Game.Entity::getZ = ->
  @_z

Game.Entity::getMap = ->
  @_map

Game.Entity::tryMove = (x, y, z, map) ->
  map = @getMap()
  # must use starting z
  tile = map.getTile(x, y, @getZ())
  currentTile = map.getTile(@getX(), @getY(), @getZ())
  target = map.getEntityAt(x, y, @getZ())
  # if our z level changed, check if we are on stair
  if z < @getZ()
    unless currentTile is Game.Tile.stairsUpTile
      Game.sendMessage this, "You can't go up here!"
    else
      Game.sendMessage this, "You ascend to level %d!", [z + 1]
      @setPosition x, y, z

  else if z > @getZ()
    unless currentTile is Game.Tile.stairsDownTile
      Game.sendMessage this, "You can't go down here!"
    else
      @setPosition(x, y, z)
      Game.sendMessage this, "You descend to level %d!", [z + 1]

  # if an entity was at the tile
  else if target
    # an entity can only attack if the entity has the Attacker mixin and
    # either the entity or the target is the player
    if @hasMixin("Attacker") and (@hasMixin(Game.EntityMixins.PlayerActor) or target.hasMixin(Game.EntityMixins.PlayerActor))
      @attack target
      return true
    # can't move to the tile
    return false 

  # check if tile is stairs, if so, let player know what to do
  else if tile is Game.Tile.stairsDownTile or tile is Game.Tile.stairsUpTile
    Game.sendMessage this, "Press 'u' to go upstairs or 'd' to go downstairs."
    @setPosition x, y, z
    return true

  # check if we can walk on the tile
  else if tile.isWalkable()
    # update the entity's position
    @setPosition x, y, z
    # notify the entity that there are items here
    items = @getMap().getItemsAt(x, y, z)
    if items
      if items.length is 1
        Game.sendMessage(this, 'You see %s.', [items[0].describeA()])
      else
        Game.sendMessage(this, 'There are several objects here')
    return true
  false

Game.Entity::isAlive = ->
  @_alive

Game.Entity::kill = (message) ->
  # only kill once!
  return  unless @_alive
  @_alive = false
  if message
    Game.sendMessage this, message
  else
    Game.sendMessage this, 'You have died!'

  # check if player has died, if so call their act method to prompt the user
  if @hasMixin(Game.EntityMixins.PlayerActor)
    @act()
  else
    @getMap().removeEntity this
  return
