Game.Item = (properties) ->
  properties = properties or {}
  
  # Call the glyph's construtor with our set of properties
  Game.Glyph.call this, properties
  
  # Instantiate any properties from the passed object
  @_name = properties['name'] or ''
  return

# Make items inherit all the functionality from glyphs
Game.Item.extend Game.Glyph

Game.Item::describe = ->
  @_name

Game.Item::describeA = (capitalize) ->
  prefixes = (if capitalize then [
    'A'
    'An'
  ] else [
    'a'
    'an'
  ])
  string = @describe()
  firstLetter = string.charAt(0).toLowerCase()
  prefix = (if 'aeiou'.indexOf(firstLetter) >= 0 then 1 else 0)
  prefixes[prefix] + ' ' + string
