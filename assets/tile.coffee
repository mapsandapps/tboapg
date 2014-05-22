Game.Tile = (properties) ->
  properties = properties or {}
  # call glyph constructor with our properties
  Game.Glyph.call this, properties
  @_walkable = properties['walkable'] or false
  @_blocksLight = (if (properties["blocksLight"] isnt `undefined`) then properties["blocksLight"] else true)
  return

# make tiles inherit the functionality from glyphs
Game.Tile.extend(Game.Glyph)

Game.Tile::isWalkable = ->
  @_walkable

Game.Tile::isBlockingLight = ->
  @_blocksLight

Game.Tile.nullTile = new Game.Tile({})
Game.Tile.floorTile = new Game.Tile(
  background: 'indigo'
  walkable: true
  blocksLight: false
)

Game.Tile.wallTile = new Game.Tile(
  background: 'black'
  blocksLight: true
)

Game.Tile.stairsUpTile = new Game.Tile(
  character: ''
  foreground: 'goldenrod'
  walkable: true
  blocksLight: false
)

Game.Tile.stairsDownTile = new Game.Tile(
  character: ''
  foreground: 'goldenrod'
  walkable: true
  blocksLight: false
)

# helper function
# not sure if i'll use this
Game.getNeighborPositions = (x, y) ->
  tiles = []
  # generate all possible offsets
  dX = -1

  while dX < 2
    dY = -1

    while dY < 2
      # make sure it isn't the same tile
      continue if dX is 0 and dY is 0
      tiles.push
        x: x + dX
        y: y + dY

      dY++
    dX++
  tiles.randomize()

  
