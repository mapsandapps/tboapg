Game.DynamicGlyph = (properties) ->
  properties = properties or {}
  
  # Call the glyph's construtor with our set of properties
  Game.Glyph.call this, properties
  
  # Instantiate any properties from the passed object
  @_name = properties['name'] or ''
  
  # Create an object which will keep track what mixins we have
  # attached to this entity based on the name property
  @_attachedMixins = {}
  
  # Create a similar object for groups
  @_attachedMixinGroups = {}
  
  # Setup the object's mixins
  mixins = properties['mixins'] or []
  i = 0

  while i < mixins.length
    
    # Copy over all properties from each mixin as long
    # as it's not the name or the init property. We
    # also make sure not to override a property that
    # already exists on the entity.
    for key of mixins[i]
      this[key] = mixins[i][key]  if key isnt 'init' and key isnt 'name' and not @hasOwnProperty(key)
    
    # Add the name of this mixin to our attached mixins
    @_attachedMixins[mixins[i].name] = true
    
    # If a group name is present, add it
    @_attachedMixinGroups[mixins[i].groupName] = true  if mixins[i].groupName
    
    # Finally call the init function if there is one
    mixins[i].init.call this, properties  if mixins[i].init
    i++
  return


# Make dynamic glyphs inherit all the functionality from glyphs
Game.DynamicGlyph.extend Game.Glyph
Game.DynamicGlyph::hasMixin = (obj) ->
  
  # Allow passing the mixin itself or the name / group name as a string
  if typeof obj is 'object'
    @_attachedMixins[obj.name]
  else
    @_attachedMixins[obj] or @_attachedMixinGroups[obj]

Game.DynamicGlyph::setName = (name) ->
  @_name = name
  return

Game.DynamicGlyph::getName = ->
  @_name

Game.DynamicGlyph::describe = ->
  @_name

Game.DynamicGlyph::describeA = (capitalize) ->
  
  # Optional parameter to capitalize the a/an.
  prefixes = (if capitalize then [
    'A'
    'An'
  ] else [
    'a'
    'an'
  ])
  string = @describe()
  firstLetter = string.charAt(0).toLowerCase()
  
  # If word starts by a vowel, use an, else use a. Note that this is not perfect.
  prefix = (if 'aeiou'.indexOf(firstLetter) >= 0 then 1 else 0)
  prefixes[prefix] + ' ' + string

Game.DynamicGlyph::describeThe = (capitalize) ->
  prefix = (if capitalize then 'The' else 'the')
  prefix + ' ' + @describe()