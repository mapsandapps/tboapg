Game.Entity = (properties) ->
  properties = properties or {}
  # call the glyph's constructor with set of properties
  Game.Glyph.call this, properties
  # instantiate properties from passed object
  @_name = properties['name'] or ''
  @_x = properties['x'] or 0
  @_y = properties['y'] or 0
  @_z = properties['z'] or 0
  @_map = null
  # create an object which will keep track of the mixins
  # attached to the entity based on the name property
  @_attachedMixins = {}
  # create a similar object for groups
  @_attachedMixinGroups = {}
  # set up the object's mixins
  mixins = properties['mixins'] or []
  i = 0
  while i < mixins.length
    # copy properties from mixin unless name or init
    # don't override properties that already exist on entity
    for key of mixins[i]
      if key isnt 'init' and key isnt 'name' and not @hasOwnProperty(key)
        this[key] = mixins[i][key]
    # add the name of the mixin to our attached mixins
    @_attachedMixins[mixins[i].name] = true

    # if a group name is present, add it
    @_attachedMixinGroups[mixins[i].groupName] = true  if mixins[i].groupName
    
    # call init function if there is one
    if mixins[i].init
      mixins[i].init.call this, properties
    i++
  return

# make entities inherit all functionality from glyphs
Game.Entity.extend Game.Glyph

Game.Entity::hasMixin = (obj) ->
  # allow passing the mixin itself or the name / group name as a string
  if typeof obj is 'object'
    @_attachedMixins[obj.name]
  else
    @_attachedMixins[obj] or @_attachedMixinGroups[obj]

Game.Entity::setName = (name) ->
  @_name = name
  return

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

Game.Entity::getName = ->
  @_name

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