Game.Entity = (properties) ->
  properties = properties or {}
  # call the glyph's constructor with set of properties
  Game.Glyph.call this, properties
  # instantiate properties from passed object
  @_name = properties['name'] or ''
  @_x = properties['x'] or 0
  @_y = properties['y'] or 0
  @_z = properties['z'] or 0
  @_map = null
  # create an object which will keep track of the mixins
  # attached to the entity based on the name property
  @_attachedMixins = {}
  # create a similar object for groups
  @_attachedMixinGroups = {}
  # set up the object's mixins
  mixins = properties['mixins'] or []
  i = 0
  while i < mixins.length
    # copy properties from mixin unless name or init
    # don't override properties that already exist on entity
    for key of mixins[i]
      if key isnt 'init' and key isnt 'name' and not @hasOwnProperty(key)
        this[key] = mixins[i][key]
    # add the name of the mixin to our attached mixins
    @_attachedMixins[mixins[i].name] = true

    # if a group name is present, add it
    @_attachedMixinGroups[mixins[i].groupName] = true  if mixins[i].groupName
    
    # call init function if there is one
    if mixins[i].init
      mixins[i].init.call this, properties
    i++
  return

# make entities inherit all functionality from glyphs
Game.Entity.extend Game.Glyph

Game.Entity::hasMixin = (obj) ->
  # allow passing the mixin itself or the name / group name as a string
  if typeof obj is 'object'
    @_attachedMixins[obj.name]
  else
    @_attachedMixins[obj] or @_attachedMixinGroups[obj]

Game.Entity::setName = (name) ->
  @_name = name
  return

Game.Entity::setX = (x) ->
  @_x = x
  return

Game.Entity::setY = (y) ->
  @_y = y
  return

Game.Entity::setZ = (z) ->
  @_z = z
  return

Game.Entity::setMap = (map) ->
  @_map = map
  return

Game.Entity::setPosition = (x, y, z) ->
  @_x = x
  @_y = y
  @_z = z

Game.Entity::getName = ->
  @_name

Game.Entity::getX = ->
  @_x

Game.Entity::getY = ->
  @_y

Game.Entity::getZ = ->
  @_z

Game.Entity::getMap = ->
  @_map

