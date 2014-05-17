Game.Tile = (properties) ->
  properties = properties or {}
  # call glyph constructor with our properties
  Game.Glyph.call this, properties
  @_isWalkable = properties['isWalkable'] or false
  @_isDiggable = properties['isDiggable'] or false
  return

# make tiles inherit the functionality from glyphs
Game.Tile.extend(Game.Glyph)

Game.Tile::isWalkable = ->
  @_isWalkable

Game.Tile::isDiggable = ->
  @_isDiggable

Game.Tile.nullTile = new Game.Tile({})
Game.Tile.floorTile = new Game.Tile(
  character: '.'
  isWalkable: true
)
Game.Tile.wallTile = new Game.Tile(
  character: '#'
  foreground: 'goldenrod'
  isDiggable: true
)
