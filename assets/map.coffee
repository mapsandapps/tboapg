downLoc = []
upLoc = []
Game.Map = (tiles, player) ->
  @_tiles = tiles;
  # cache width & height based on length of 
  # dimensions of tiles array
  @_depth = tiles.length
  @_width = tiles[0].length
  @_height = tiles[0][0].length
  # set up the field of vision
  @_fov = []
  @setupFov()
  # create a table that will hold the entities
  @_entities = {}
  # create a table to hold items
  @_items = {}

  # create the engine and scheduler
  @_scheduler = new ROT.Scheduler.Simple()
  @_engine = new ROT.Engine(@_scheduler)

  # add the player
  @addEntityAtRandomPosition player, 0

  # add random stairs
  z = 0
  while z < @_depth - 1
    downPos = @getRandomFloorPosition z
    @_tiles[z][downPos.x][downPos.y] = Game.Tile.stairsDownTile
    downLoc.push(
      z: z
      x: downPos.x
      y: downPos.y
    )
    z++

  z = 1
  while z < @_depth
    upPos = @getRandomFloorPosition z
    @_tiles[z][upPos.x][upPos.y] = Game.Tile.stairsUpTile
    upLoc.push(
      z: z
      x: upPos.x
      y: upPos.y
    )
    z++

  # automate this
  items = [
    'bug'
    'sun'
    'umbrella'
    'key'
    'extinguisher'
  ]
  items = items.randomize()
  bosses = [
    'plant'
    'moon'
    'cloud'
    'lock'
    'fire'
  ]
  bosses = bosses.randomize()
  # Add random entities and items to each floor.
  z = 0

  while z < @_depth
    
    # 15 entities per floor
    i = 0

    while i < 15
      
      # Add a random entity
      @addEntityAtRandomPosition Game.EntityRepository.createRandom(), z
      i++
    
    # 1 item per floor
    item = items[z]
    @addItemAtRandomPosition Game.ItemRepository.create(item), z

    # 1 boss per floor
    boss = bosses[z]
    @addEntityAtRandomPosition Game.BossRepository.create(boss), z
    z++

  # set up the explored array
  @_explored = new Array(@_depth)
  @_setupExploredArray()
  return

Game.Map::_setupExploredArray = ->
  z = 0
  while z < @_depth
    @_explored[z] = new Array(@_width)
    x = 0

    while x < @_width
      @_explored[z][x] = new Array(@_height)
      y = 0
    
      while y < @_height
        @_explored[z][x][y] = false
        y++
      x++
    z++
  return

Game.Map::getWidth = ->
  @_width

Game.Map::getHeight = ->
  @_height

Game.Map::getDepth = ->
  @_depth

# gets the tile for given coords
Game.Map::getTile = (x, y, z) ->
  # make sure we're inside bounds
  if x < 0 or x >= @_width or 
     y < 0 or y >= @_height or 
     z < 0 or z >= @_depth
    Game.Tile.nullTile
  else
    @_tiles[z][x][y] or Game.Tile.nullTile

Game.Map::isEmptyFloor = (x, y, z) ->
  # check if the tile is floor and has no entity
  @getTile(x, y, z) is Game.Tile.floorTile and not @getEntityAt(x, y, z)

Game.Map::setExplored = (x, y, z, state) ->
  # only update if tile is within bounds
  @_explored[z][x][y] = state  if @getTile(x, y, z) isnt Game.Tile.nullTile
  return

Game.Map::isExplored = (x, y, z) ->
  # only return value if in bounds
  if @getTile(x, y, z) isnt Game.Tile.nullTile
    @_explored[z][x][y]
  else
    false

Game.Map::setupFov = ->
  # keep this in 'map' variable so we don't lose it
  map = this
  # iterate through each depth level, setting up fov
  z = 0
  while z < @_depth
    # we have to put the following in its own scope to prevent
    # depth variable from being hoisted
    ( ->
      # for each depth, create callback to determine
      # if light can pass through tile
      depth = z
      map._fov.push new ROT.FOV.DiscreteShadowcasting((x, y) ->
        not map.getTile(x, y, depth).isBlockingLight()
      ,
        topology: 4
      )
      return
    )()
    z++
  return

Game.Map::getFov = (depth) ->
  @_fov[depth]

Game.Map::getRandomFloorPosition = (z) ->
  # randomly generate a tile which is a floor
  x = undefined
  y = undefined
  loop
    x = Math.floor(Math.random() * @_width)
    y = Math.floor(Math.random() * @_height)
    break unless not @isEmptyFloor(x, y, z)
  x: x
  y: y
  z: z

Game.Map::getEngine = ->
  @_engine

Game.Map::getEntities = ->
  @_entities

Game.Map::getEntityAt = (x, y, z) ->
  # get the entity based on position key
  @_entities[x + ',' + y + ',' + z]

Game.Map::getEntitiesWithinRadius = (centerX, centerY, centerZ, radius) ->
  results = []
  # determine bounds
  leftX = centerX - radius
  rightX = centerX + radius
  topY = centerY - radius
  bottomY = centerY + radius
  # iterate through entities, adding any within bounds
  for key of @_entities
    entity = @_entities[key]
    results.push entity  if entity.getX() >= leftX and 
                            entity.getX() <= rightX and 
                            entity.getY() >= topY and 
                            entity.getY() <= bottomY and 
                            entity.getZ() is centerZ
  results

Game.Map::addEntityAtRandomPosition = (entity, z) ->
  position = @getRandomFloorPosition(z)
  entity.setX position.x
  entity.setY position.y
  entity.setZ position.z
  @addEntity entity
  return

Game.Map::addEntity = (entity) ->
  # update the entity's map
  entity.setMap this
  # update map with the entity's position
  @updateEntityPosition(entity)
  # check if entity is actor, if so, add to scheduler
  if entity.hasMixin('Actor')
    @_scheduler.add entity, true

Game.Map::removeEntity = (entity) ->
  # remove the entity from the map
  key = entity.getX() + ',' + entity.getY() + ',' + entity.getZ()
  delete @_entities[key]  if @_entities[key] is entity
  # if the entity is an actor, remove them from scheduler
  @_scheduler.remove entity if entity.hasMixin('Actor')
  return

Game.Map::updateEntityPosition = (entity, oldX, oldY, oldZ) ->
  # delete the old key if it is the same entity and we have old positions
  if typeof oldX is 'number'
    oldKey = oldX + ',' + oldY + ',' + oldZ
    delete @_entities[oldKey]  if @_entities[oldKey] is entity
  # make sure the entity's position is within bounds
  throw new Error("Entity's position is out of bounds.")  if entity.getX() < 0 or entity.getX() >= @_width or
     entity.getY() < 0 or entity.getY() >= @_height or
     entity.getZ() < 0 or entity.getZ() >= @_depth
    
  # sanity check to make sure there is no entity at the new position
  key = entity.getX() + ',' + entity.getY() + ',' + entity.getZ()
  throw new Error('Tried to add an entity at an occupied position.')  if @_entities[key]
    
  # add entity to table of entities
  @_entities[key] = entity
  return

Game.Map::getItemsAt = (x, y, z) ->
  @_items[x + ',' + y + ',' + z]

Game.Map::setItemsAt = (x, y, z, items) ->
  # if items array is empty, delete key from table
  key = x + ',' + y + ',' + z
  if items.length is 0
    delete @_items[key]  if @_items[key]
  else
    # simply update items at that key
    @_items[key] = items
  return

Game.Map::addItem = (x, y, z, item) ->
  # if we already have items at that position, append item to the list of items
  key = x + ',' + y + ',' + z
  if @_items[key]
    @_items[key].push(item)
  else
    @_items[key] = [item]
  return

Game.Map::addItemAtRandomPosition = (item, z) ->
  position = @getRandomFloorPosition(z)
  @addItem position.x, position.y, position.z, item
  return

