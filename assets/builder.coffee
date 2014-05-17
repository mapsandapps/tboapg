Game.Builder = (width, height, depth) ->
  @_width = width
  @_height = height
  @_depth = depth
  @_tiles = new Array(depth)
  @_regions = new Array(depth)
  # instantiate the arrays to be multi-dimension
  z = 0
  while z < depth
    # create a new cave at each level
    @_tiles[z] = @_generateLevel()
    # set up regions array for each depth
    @_regions[z] = new Array(width)
    x = 0
    while x < width
      @_regions[z][x] = new Array(height)
      # fill with zeros
      y = 0
      while y < height
        @_regions[z][x][y] = 0
        y++
      x++
    z++
  return

# helper function to generate a single level:
Game.Builder::_generateLevel = ->
  # create empty map
  map = new Array(@_width)
  w = 0
  while w < @_width
    map[w] = new Array(@_height)
    w++
  # set up map generator
  generator = new ROT.Map.Uniform(@_width, @_height)

  # smoothen a last time and update
  generator.create (x, y, v) ->
    if v is 0
      map[x][y] = Game.Tile.floorTile
    else
      map[x][y] = Game.Tile.wallTile
    return

  return map

Game.Builder::getTiles = ->
  @_tiles

Game.Builder::getDepth = ->
  @_depth

Game.Builder::getWidth = ->
  @_width

Game.Builder::getHeight = ->
  @_height
