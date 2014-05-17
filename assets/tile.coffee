Game.Tile = (properties) ->
  properties = properties or {}
  # call glyph constructor with our properties
  Game.Glyph.call this, properties
  @_isWalkable = properties['isWalkable'] or false
  # @_isDiggable = properties['isDiggable'] or false
  return

# make tiles inherit the functionality from glyphs
Game.Tile.extend(Game.Glyph)

Game.Tile::isWalkable = ->
  @_isWalkable

# Game.Tile::isDiggable = ->
#   @_isDiggable

Game.Tile.nullTile = new Game.Tile({})
Game.Tile.floorTile = new Game.Tile(
  background: 'indigo'
  isWalkable: true
)
Game.Tile.wallTile = new Game.Tile(
  background: 'black'
  # isDiggable: true
)

Game.Tile.stairsUpTile = new Game.Tile(
  character: ''
  foreground: 'white'
  isWalkable: true
)

Game.Tile.stairsDownTile = new Game.Tile(
  character: ''
  foreground: 'white'
  isWalkable: true
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

  
