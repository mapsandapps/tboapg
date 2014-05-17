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
  # create a list that will hold the entities
  @_entities = []

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

  # add random fungi
  z = 0
  while z < @_depth
    i = 0
    while i < 10
      @addEntityAtRandomPosition new Game.Entity(Game.FungusTemplate), z
      i++
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
  # iterate through all entities searching for one with
  # matching position
  i = 0
  while i < @_entities.length
    return @_entities[i] if @_entities[i].getX() is x and @_entities[i].getY() is y and
                            @_entities[i].getZ() is z
    i++
  return false

Game.Map::getEntitiesWithinRadius = (centerX, centerY, centerZ, radius) ->
  results = []
  # determine bounds
  leftX = centerX - radius
  rightX = centerX + radius
  topY = centerY - radius
  bottomY = centerY + radius
  # iterate through entities, adding any within bounds
  i = 0
  while i < @_entities.length
    if @_entities[i].getX() >= leftX and
       @_entities[i].getX() <= rightX and
       @_entities[i].getY() >= topY and
       @_entities[i].getY() <= bottomY and
       @_entities[i].getZ() is centerZ
      results.push(@_entities[i])
    i++
  return results

Game.Map::addEntity = (entity) ->
  # make sure entity's position is within bounds
  if entity.getX() < 0 or entity.getX() >= @_width or 
     entity.getY() < 0 or entity.getY() >= @_height or
     entity.getZ() < 0 or entity.getZ() >= @_depth
    throw new Error('Adding entity out of bounds.')
  # update the entity's map
  entity.setMap this
  # add entity to list of entities
  @_entities.push entity
  # check if entity is actor, if so, add to scheduler
  if entity.hasMixin('Actor')
    @_scheduler.add entity, true

Game.Map::addEntityAtRandomPosition = (entity, z) ->
  position = @getRandomFloorPosition(z)
  entity.setX position.x
  entity.setY position.y
  entity.setZ position.z
  @addEntity entity
  return

Game.Map::removeEntity = (entity) ->
  # find the entity in the list of entities
  i = 0
  while i < @_entities.length
    if @_entities[i] is entity
      @_entities.splice i, 1
      break
    i++
  # if the entity is an actor, remove them from scheduler
  @_scheduler.remove entity if entity.hasMixin('Actor')
  return



