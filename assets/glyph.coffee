Game.Glyph = (properties) ->
  properties = properties or {}
  @_char = properties['character'] or ' '
  @_foreground = properties['foreground'] or 'white'
  @_background = properties['background'] or 'indigo'
  return

Game.Glyph::getChar = ->
  @_char

Game.Glyph::getBackground = ->
  @_background

Game.Glyph::getForeground = ->
  @_foreground


