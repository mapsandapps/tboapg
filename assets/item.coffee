Game.Item = (properties) ->
  properties = properties or {}
  
  # Call the glyph's construtor with our set of properties
  Game.Glyph.call this, properties
  
  # Instantiate any properties from the passed object
  @_name = properties['name'] or ''
  return


# Make items inherit all the functionality from glyphs
Game.Item.extend Game.Glyph